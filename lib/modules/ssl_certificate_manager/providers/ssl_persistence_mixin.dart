import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/services/persistence_service.dart';
import '../../../core/utils/logger.dart';
import '../models/ssl_models.dart';
import '../services/openssl_command_service.dart';
import 'ssl_issue_mixin.dart';
import 'ssl_provider_base.dart';

/// Persistence, snapshot, storage initialization, root CA setup, validation,
/// and controller ↔ template synchronisation.
mixin SslPersistenceMixin on SslProviderBase, SslIssueMixin {
  // ────────────────── initialization ──────────────────

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    AppLogger.info('[SSL] initialize start');
    try {
      final persistence = PersistenceService();
      await persistence.ensureReady();

      template = SslIssueTemplate.defaults();
      configData = const SslManagerConfig(
        initialized: false,
        storagePath: '',
        rootCAName: '',
        rootCAPassword: '',
        importRootCA: false,
        rootCACertPath: '',
        rootCAKeyPath: '',
        defaultCnfPath: '',
      );
      _applyTemplateToControllers(template);
      _applyConfigToControllers(configData);

      await _loadSnapshotFromPersistence(persistence);
      await _loadSnapshotFromDiskIfAvailable();

      isInitialized = configData.initialized;
      infoMessage = isInitialized ? '已加载 SSL 证书管理配置。' : '请先完成初始化配置。';
      await ensureCnfLoaded();
      if (snapshotNeedsRepair) {
        await persistAll();
        snapshotNeedsRepair = false;
      }
      AppLogger.info(
        '[SSL] initialize done, initialized=$isInitialized, storagePath=${configData.storagePath}',
      );
    } catch (e) {
      infoMessage = '初始化失败: $e';
      AppLogger.error('[SSL] initialize failed', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeInitialization() async {
    isLoading = true;
    notifyListeners();
    AppLogger.info('[SSL] completeInitialization start');
    try {
      syncControllersToTemplate();

      final storagePath = storagePathController.text.trim();
      if (storagePath.isEmpty) {
        throw Exception('存储路径不能为空');
      }
      final rootCaName = rootCANameController.text.trim();
      if (rootCaName.isEmpty) {
        throw Exception('根 CA 名称不能为空');
      }

      if (importRootCA) {
        AppLogger.info('[SSL] validation for imported root CA started');
        final validation = await inspectImportedRootCA();
        if (!validation.isValid) {
          AppLogger.warning(
            '[SSL] validation for imported root CA failed: ${validation.message}',
          );
          throw Exception(validation.message);
        }
        AppLogger.info('[SSL] validation for imported root CA passed');
      }

      await _initializeStorageLayout(storagePath);
      await _writeDefaultCnf(storagePath);
      await _setupRootCaFiles(storagePath);

      configData = configData.copyWith(
        initialized: true,
        storagePath: storagePath,
        rootCAName: rootCaName,
        rootCAPassword: rootCAPasswordController.text,
        importRootCA: importRootCA,
        rootCACertPath: rootCACertPathController.text.trim(),
        rootCAKeyPath: rootCAKeyPathController.text.trim(),
        defaultCnfPath: p.join(
          storagePath,
          'openssl_config',
          SslProviderBase.defaultCnfFileName,
        ),
      );
      isInitialized = true;
      infoMessage = '初始化完成，可开始签发和管理证书。';
      AppLogger.info(
        '[SSL] completeInitialization success, importRootCA=$importRootCA, storagePath=$storagePath',
      );

      await persistAll();
      await ensureCnfLoaded();
    } catch (e) {
      infoMessage = '初始化失败: $e';
      AppLogger.error('[SSL] completeInitialization failed', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<RootCaValidationResult> inspectImportedRootCA() async {
    final certSource = rootCACertPathController.text.trim();
    final keySource = rootCAKeyPathController.text.trim();
    final keyPassword = rootCAPasswordController.text;
    final rootName = rootCANameController.text.trim();

    if (certSource.isEmpty || keySource.isEmpty) {
      AppLogger.warning('[SSL] root CA import path missing');
      return RootCaValidationResult.invalid('导入模式下必须提供根证书与私钥路径。');
    }

    final certNameValid = _isAllowedImportFileName(certSource, isCert: true);
    if (!certNameValid) {
      AppLogger.warning(
        '[SSL] root cert filename rejected: ${p.basename(certSource)}',
      );
      return RootCaValidationResult.invalid(
        '根证书文件名不符合规范，仅允许字母/数字/._- 且扩展名为 .crt 或 .pem。',
      );
    }
    final keyNameValid = _isAllowedImportFileName(keySource, isCert: false);
    if (!keyNameValid) {
      AppLogger.warning(
        '[SSL] root key filename rejected: ${p.basename(keySource)}',
      );
      return RootCaValidationResult.invalid(
        '根私钥文件名不符合规范，仅允许字母/数字/._- 且扩展名为 .key 或 .pem。',
      );
    }

    final certFile = File(certSource);
    final keyFile = File(keySource);
    if (!await certFile.exists()) {
      AppLogger.warning('[SSL] root cert file not found: $certSource');
      return RootCaValidationResult.invalid('根证书文件不存在: $certSource');
    }
    if (!await keyFile.exists()) {
      AppLogger.warning('[SSL] root key file not found: $keySource');
      return RootCaValidationResult.invalid('根私钥文件不存在: $keySource');
    }

    final certContent = await certFile.readAsString();
    final keyContent = await keyFile.readAsString();
    if (!_looksLikeCertificatePem(certContent)) {
      return RootCaValidationResult.invalid('无法识别根证书内容，请确认是 PEM 格式 X.509 证书。');
    }
    if (!_looksLikePrivateKeyPem(keyContent)) {
      return RootCaValidationResult.invalid('无法识别根私钥内容，请确认是 PEM 格式私钥。');
    }

    final keyCheck =
        await OpenSslCommandService.verifyImportedPrivateKeyPassword(
          keySource,
          keyPassword,
        );
    if (!keyCheck.isValid) {
      AppLogger.warning(
        '[SSL] root key password verify failed: ${keyCheck.message}',
      );
      return RootCaValidationResult.invalid(keyCheck.message);
    }
    AppLogger.info(
      '[SSL] root key password verify passed, encrypted=${keyCheck.isEncrypted}',
    );

    final opensslInfo =
        await OpenSslCommandService.readCertificateMetaByOpenSsl(certSource);
    if (opensslInfo == null || opensslInfo.isEmpty) {
      AppLogger.warning('[SSL] root cert metadata parse failed');
      return RootCaValidationResult.invalid(
        '无法正确读取导入根证书的信息，请检查证书是否有效或本机是否可用 openssl。',
      );
    }

    final keyMatch = await OpenSslCommandService.verifyCertificateKeyMatch(
      certPath: certSource,
      keyPath: keySource,
      usePassword: keyCheck.isEncrypted,
      password: keyPassword,
    );
    if (keyMatch == null) {
      AppLogger.warning(
        '[SSL] cert-key match verify failed due to openssl/runtime',
      );
      return RootCaValidationResult.invalid(
        '无法校验证书与私钥是否匹配，请检查 openssl 环境或文件格式。',
      );
    }
    if (!keyMatch) {
      AppLogger.warning('[SSL] cert-key mismatch');
      return RootCaValidationResult.invalid('导入失败：根证书与私钥不匹配。');
    }
    AppLogger.info('[SSL] imported root cert and key match verified');

    final details = <String, String>{
      '根证书名称': rootName,
      '证书路径': certSource,
      '私钥路径': keySource,
      '私钥加密': keyCheck.isEncrypted ? '是' : '否',
      '私钥密码校验': '通过',
      ...opensslInfo,
    };
    return RootCaValidationResult.valid(details);
  }

  // ────────────────── storage path change ──────────────────

  Future<void> changeStoragePath(String newPath) async {
    if (newPath.trim().isEmpty) return;
    storagePathController.text = newPath.trim();
    configData = configData.copyWith(
      storagePath: newPath.trim(),
      defaultCnfPath: p.join(
        newPath.trim(),
        'openssl_config',
        SslProviderBase.defaultCnfFileName,
      ),
    );
    notifyListeners();
  }

  // ────────────────── persistence (implements abstract) ──────────────────

  @override
  Future<void> persistAll() async {
    final persistence = PersistenceService();
    await persistence.ensureReady();
    final snapshot = SslManagerStateSnapshot(
      config: configData,
      template: template,
      certificates: certificateRecords,
      pinnedIssueFieldKeys: pinnedIssueFieldValues.keys.toList()..sort(),
      pinnedIssueFieldValues: Map<String, String>.fromEntries(
        pinnedIssueFieldValues.entries.toList()
          ..sort((left, right) => left.key.compareTo(right.key)),
      ),
      crlState: crlStateInternal,
      auditLog: auditLogInternal,
    );

    await persistence.setModuleData(
      SslProviderBase.moduleName,
      SslProviderBase.snapshotKey,
      snapshot.toJson(),
    );

    final storagePath = configData.storagePath.trim();
    if (storagePath.isNotEmpty && await Directory(storagePath).exists()) {
      final file = File(p.join(storagePath, SslProviderBase.snapshotFileName));
      await file.parent.create(recursive: true);
      await file.writeAsString(snapshot.toPrettyJson());
      AppLogger.debug('[SSL] snapshot persisted to disk');
    } else {
      AppLogger.debug(
        '[SSL] snapshot persisted to app storage only, disk snapshot skipped',
      );
    }
    AppLogger.debug('[SSL] snapshot persisted');
  }

  // ────────────────── snapshot loading ──────────────────

  Future<void> _loadSnapshotFromPersistence(
    PersistenceService persistence,
  ) async {
    final raw = persistence.getModuleData<dynamic>(
      SslProviderBase.moduleName,
      SslProviderBase.snapshotKey,
    );
    if (raw is! Map) return;
    final snapshot = SslManagerStateSnapshot.fromJson(
      Map<String, dynamic>.from(raw),
    );
    _applySnapshot(snapshot);
  }

  Future<void> _loadSnapshotFromDiskIfAvailable() async {
    final file = File(
      p.join(configData.storagePath, SslProviderBase.snapshotFileName),
    );
    if (!await file.exists()) return;
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return;
    final decoded = json.decode(raw);
    if (decoded is! Map<String, dynamic>) return;
    final snapshot = SslManagerStateSnapshot.fromJson(decoded);
    _applySnapshot(snapshot);
  }

  void _applySnapshot(SslManagerStateSnapshot snapshot) {
    final sanitizedTemplate = _sanitizeLegacyTemplate(snapshot.template);
    final migratedPinnedValues = snapshot.pinnedIssueFieldValues.isNotEmpty
        ? snapshot.pinnedIssueFieldValues
        : _migrateLegacyPinnedIssueFieldValues(
            snapshot.pinnedIssueFieldKeys,
            sanitizedTemplate,
          );
    final sanitizedPinnedValues = _sanitizePinnedIssueFieldValues(
      migratedPinnedValues,
    );
    snapshotNeedsRepair =
        snapshotNeedsRepair ||
        !_sameTemplate(snapshot.template, sanitizedTemplate) ||
        !_samePinnedIssueFieldValues(
          snapshot.pinnedIssueFieldValues,
          sanitizedPinnedValues,
        );
    configData = snapshot.config;
    template = mergePinnedIssueFieldValuesIntoTemplate(
      sanitizedTemplate,
      pinnedValues: sanitizedPinnedValues,
    );
    certificateRecords
      ..clear()
      ..addAll(snapshot.certificates);
    pinnedIssueFieldValues
      ..clear()
      ..addAll(sanitizedPinnedValues);
    crlStateInternal = snapshot.crlState;
    auditLogInternal
      ..clear()
      ..addAll(snapshot.auditLog);
    isInitialized = configData.initialized;
    importRootCA = configData.importRootCA;
    _applyTemplateToControllers(template);
    _applyConfigToControllers(configData);
  }

  // ────────────────── controller ↔ template sync ──────────────────

  void _applyTemplateToControllers(SslIssueTemplate tpl) {
    domainController.text = tpl.domain;
    commonNameController.text = tpl.commonName;
    countryNameController.text = tpl.countryName;
    stateNameController.text = tpl.stateName;
    localityNameController.text = tpl.localityName;
    organizationNameController.text = tpl.organizationName;
    organizationalUnitNameController.text = tpl.organizationalUnitName;
    emailAddressController.text = tpl.emailAddress;
    explicitTextController.text = tpl.explicitText;
    challengePasswordController.text = tpl.challengePassword;
    unstructuredNameController.text = tpl.unstructuredName;
    ocspDomainController.text = tpl.ocspDomain;
    rootCAFileNameController.text = tpl.rootCAFileName;
    validDaysController.text = tpl.validDays > 0
        ? tpl.validDays.toString()
        : '';
    crlDistributionUrlController.text = tpl.crlDistributionUrl;
    ocspCaIssuersUrlController.text = tpl.ocspCaIssuersUrl;
    ocspResponderUrlController.text = tpl.ocspResponderUrl;
  }

  void _applyConfigToControllers(SslManagerConfig cfg) {
    storagePathController.text = cfg.storagePath;
    rootCANameController.text = cfg.rootCAName;
    rootCAPasswordController.text = cfg.rootCAPassword;
    rootCACertPathController.text = cfg.rootCACertPath;
    rootCAKeyPathController.text = cfg.rootCAKeyPath;
    importRootCA = cfg.importRootCA;
  }

  @override
  void syncControllersToTemplate() {
    template = template.copyWith(
      domain: resolvedIssueFieldText('domain', domainController.text),
      commonName: resolvedIssueFieldText(
        'commonName',
        commonNameController.text,
      ),
      countryName: resolvedIssueFieldText(
        'countryName',
        countryNameController.text,
      ),
      stateName: resolvedIssueFieldText('stateName', stateNameController.text),
      localityName: resolvedIssueFieldText(
        'localityName',
        localityNameController.text,
      ),
      organizationName: resolvedIssueFieldText(
        'organizationName',
        organizationNameController.text,
      ),
      organizationalUnitName: resolvedIssueFieldText(
        'organizationalUnitName',
        organizationalUnitNameController.text,
      ),
      emailAddress: resolvedIssueFieldText(
        'emailAddress',
        emailAddressController.text,
      ),
      explicitText: resolvedIssueFieldText(
        'explicitText',
        explicitTextController.text,
      ),
      challengePassword: resolvedIssueFieldText(
        'challengePassword',
        challengePasswordController.text,
      ),
      unstructuredName: resolvedIssueFieldText(
        'unstructuredName',
        unstructuredNameController.text,
      ),
      ocspDomain: resolvedIssueFieldText(
        'ocspDomain',
        ocspDomainController.text,
      ),
      rootCAFileName: rootCAFileNameController.text.trim().isNotEmpty
          ? rootCAFileNameController.text.trim()
          : rootCANameController.text.trim(),
      crlDistributionUrl: resolvedIssueFieldText(
        'crlDistributionUrl',
        crlDistributionUrlController.text,
      ),
      ocspCaIssuersUrl: resolvedIssueFieldText(
        'ocspCaIssuersUrl',
        ocspCaIssuersUrlController.text,
      ),
      ocspResponderUrl: resolvedIssueFieldText(
        'ocspResponderUrl',
        ocspResponderUrlController.text,
      ),
      validDays: resolvedValidDays(),
      altNames: resolvedAltNames(),
      tsaPolicies: template.tsaPolicies
          .where((e) => e.name.trim().isNotEmpty && e.oid.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  // ────────────────── snapshot sanitisation ──────────────────

  bool _sameTemplate(SslIssueTemplate a, SslIssueTemplate b) {
    return json.encode(a.toJson()) == json.encode(b.toJson());
  }

  SslIssueTemplate _sanitizeLegacyTemplate(SslIssueTemplate tpl) {
    final legacyAltNames =
        tpl.altNames.length == SslProviderBase.legacyDefaultAltNames.length &&
        List.generate(SslProviderBase.legacyDefaultAltNames.length, (index) {
          final current = tpl.altNames[index];
          final legacy = SslProviderBase.legacyDefaultAltNames[index];
          return current.type == legacy.type && current.value == legacy.value;
        }).every((matched) => matched);

    final matchCount = [
      tpl.domain == 'your-domain.com',
      tpl.commonName == 'Common Name',
      tpl.countryName == 'DE',
      tpl.stateName == 'Bayern',
      tpl.localityName == 'Munich',
      tpl.organizationName == 'OwOTeam',
      tpl.organizationalUnitName == 'Server Management',
      tpl.emailAddress == 'support@owoblog.com',
      tpl.explicitText == 'Issued by OwOTeam',
      tpl.challengePassword == 'password',
      tpl.unstructuredName == 'OwOTeam',
      tpl.ocspDomain == 'ssl.your-domain.com',
      tpl.rootCAFileName == 'YourDomain_Root_CA',
      tpl.validDays == 825,
      legacyAltNames,
    ].where((matched) => matched).length;

    if (matchCount < 3) {
      return tpl;
    }

    return tpl.copyWith(
      domain: tpl.domain == 'your-domain.com' ? '' : tpl.domain,
      commonName: tpl.commonName == 'Common Name' ? '' : tpl.commonName,
      countryName: tpl.countryName == 'DE' ? '' : tpl.countryName,
      stateName: tpl.stateName == 'Bayern' ? '' : tpl.stateName,
      localityName: tpl.localityName == 'Munich' ? '' : tpl.localityName,
      organizationName: tpl.organizationName == 'OwOTeam'
          ? ''
          : tpl.organizationName,
      organizationalUnitName: tpl.organizationalUnitName == 'Server Management'
          ? ''
          : tpl.organizationalUnitName,
      emailAddress: tpl.emailAddress == 'support@owoblog.com'
          ? ''
          : tpl.emailAddress,
      explicitText: tpl.explicitText == 'Issued by OwOTeam'
          ? ''
          : tpl.explicitText,
      challengePassword: tpl.challengePassword == 'password'
          ? ''
          : tpl.challengePassword,
      unstructuredName: tpl.unstructuredName == 'OwOTeam'
          ? ''
          : tpl.unstructuredName,
      ocspDomain: tpl.ocspDomain == 'ssl.your-domain.com' ? '' : tpl.ocspDomain,
      rootCAFileName: tpl.rootCAFileName == 'YourDomain_Root_CA'
          ? ''
          : tpl.rootCAFileName,
      altNames: legacyAltNames ? [] : tpl.altNames,
      validDays: tpl.validDays == 825 ? 0 : tpl.validDays,
    );
  }

  bool _samePinnedIssueFieldValues(
    Map<String, String> a,
    Map<String, String> b,
  ) {
    return json.encode(
          Map<String, String>.fromEntries(
            a.entries.toList()
              ..sort((left, right) => left.key.compareTo(right.key)),
          ),
        ) ==
        json.encode(
          Map<String, String>.fromEntries(
            b.entries.toList()
              ..sort((left, right) => left.key.compareTo(right.key)),
          ),
        );
  }

  Map<String, String> _sanitizePinnedIssueFieldValues(
    Map<String, String> fieldValues,
  ) {
    final sanitized = <String, String>{};
    for (final entry in fieldValues.entries) {
      final fieldKey = entry.key;
      final value = entry.value;
      if (!_isSupportedIssueFieldKey(fieldKey) || value.trim().isEmpty) {
        continue;
      }
      sanitized[fieldKey] = value;
    }
    return sanitized;
  }

  Map<String, String> _migrateLegacyPinnedIssueFieldValues(
    Iterable<String> fieldKeys,
    SslIssueTemplate tpl,
  ) {
    final migrated = <String, String>{};
    for (final fieldKey in fieldKeys) {
      if (!_isSupportedIssueFieldKey(fieldKey)) {
        continue;
      }
      final value = currentIssueFieldValue(fieldKey, templateOverride: tpl);
      if (value.trim().isEmpty) {
        continue;
      }
      migrated[fieldKey] = value;
    }
    return migrated;
  }

  bool _isSupportedIssueFieldKey(String fieldKey) {
    if (SslProviderBase.requiredIssueFieldKeys.contains(fieldKey)) {
      return true;
    }
    return {
          'challengePassword',
          'stateName',
          'localityName',
          'organizationalUnitName',
          'emailAddress',
          'explicitText',
          'unstructuredName',
          'ocspDomain',
        }.contains(fieldKey) ||
        fieldKey.startsWith('altName_');
  }

  // ────────────────── storage layout ──────────────────

  Future<void> _initializeStorageLayout(String storagePath) async {
    final requiredDirs = [
      storagePath,
      p.join(storagePath, 'CAcerts'),
      p.join(storagePath, 'csr'),
      p.join(storagePath, 'newcerts'),
      p.join(storagePath, 'private'),
      p.join(storagePath, 'pfx'),
      p.join(storagePath, 'openssl_config'),
      p.join(storagePath, '_files'),
    ];
    for (final dirPath in requiredDirs) {
      await Directory(dirPath).create(recursive: true);
    }

    await _writeIfNotExists(p.join(storagePath, '_files', 'index.txt'), '');
    await _writeIfNotExists(p.join(storagePath, '_files', 'serial'), '01\n');
    await _writeIfNotExists(p.join(storagePath, '_files', 'crlnumber'), '01\n');
  }

  Future<void> _setupRootCaFiles(String storagePath) async {
    await OpenSslCommandService.ensureOpenSslAvailable();
    final rootName = rootCANameController.text.trim();
    final certTarget = p.join(storagePath, 'CAcerts', '$rootName.crt');
    final keyTarget = p.join(storagePath, 'CAcerts', '$rootName.key');

    if (importRootCA) {
      final certSource = rootCACertPathController.text.trim();
      final keySource = rootCAKeyPathController.text.trim();
      if (certSource.isEmpty || keySource.isEmpty) {
        throw Exception('导入模式下必须提供根证书与私钥路径');
      }
      await File(certSource).copy(certTarget);
      await File(keySource).copy(keyTarget);
    } else {
      final cnfPath = p.join(
        storagePath,
        'openssl_config',
        SslProviderBase.defaultCnfFileName,
      );
      await OpenSslCommandService.runOpenSslOrThrow(
        [
          'genpkey',
          if (rootCAPasswordController.text.isNotEmpty) ...[
            '-aes256',
            '-pass',
            'pass:${rootCAPasswordController.text}',
          ],
          '-algorithm',
          'RSA',
          '-pkeyopt',
          'rsa_keygen_bits:4096',
          '-out',
          keyTarget,
        ],
        action: '生成根私钥',
        timeout: const Duration(seconds: 30),
      );

      final rootReqArgs = <String>[
        'req',
        '-x509',
        '-new',
        '-sha256',
        '-days',
        '3650',
        '-batch',
        '-key',
        keyTarget,
        '-out',
        certTarget,
        '-config',
        cnfPath,
        '-extensions',
        'v3_ca',
        '-subj',
        buildDistinguishedName(commonName: rootName),
      ];
      if (rootCAPasswordController.text.isNotEmpty) {
        rootReqArgs.addAll([
          '-passin',
          'pass:${rootCAPasswordController.text}',
        ]);
      }

      await OpenSslCommandService.runOpenSslOrThrow(
        rootReqArgs,
        action: '生成根证书',
        workingDirectory: storagePath,
        timeout: const Duration(seconds: 30),
      );
    }

    rootCACertPathController.text = certTarget;
    rootCAKeyPathController.text = keyTarget;
  }

  Future<void> _writeDefaultCnf(String storagePath) async {
    final cnfPath = p.join(
      storagePath,
      'openssl_config',
      SslProviderBase.defaultCnfFileName,
    );
    final cnfContent = buildRenderedCnfContent();
    await File(cnfPath).writeAsString(cnfContent);
    cnfEditorController.text = cnfContent;
    savedCnfContent = cnfContent;
  }

  @override
  Future<void> ensureCnfLoaded() async {
    if (configData.defaultCnfPath.trim().isEmpty) {
      return;
    }
    final file = File(configData.defaultCnfPath);
    if (await file.exists()) {
      final content = await file.readAsString();
      cnfEditorController.text = content;
      savedCnfContent = content;
    }
  }

  Future<void> _writeIfNotExists(String filePath, String content) async {
    final file = File(filePath);
    if (!await file.exists()) {
      await file.writeAsString(content);
    }
  }

  // ────────────────── storage recovery ──────────────────

  @override
  Future<bool> ensureStorageAvailableOrRecover({
    bool allowAutoRecover = true,
  }) async {
    if (!isInitialized) {
      return false;
    }
    final storagePath = configData.storagePath.trim();
    if (storagePath.isEmpty) {
      await _markStorageLost('检测到存储路径为空，已回退到初始化状态，请重新初始化。');
      return false;
    }

    final exists = await Directory(storagePath).exists();
    if (exists) {
      return true;
    }

    if (!allowAutoRecover) {
      await _markStorageLost('检测到存储目录已丢失，请重新初始化。');
      return false;
    }

    if (isRecoveringStorage) {
      return false;
    }
    isRecoveringStorage = true;
    try {
      AppLogger.warning(
        '[SSL] storage missing, auto reinitialize start: $storagePath',
      );
      await _markStorageLost('检测到存储目录已丢失，正在自动重新初始化...');
      await completeInitialization();
      final recovered = await Directory(configData.storagePath).exists();
      if (!isInitialized || !recovered) {
        await _markStorageLost('自动重新初始化失败，请检查配置后手动初始化。');
        return false;
      }
      infoMessage = '检测到存储目录丢失，已自动重新初始化。';
      AppLogger.info('[SSL] storage auto reinitialize success');
      return true;
    } catch (e, st) {
      await _markStorageLost('自动重新初始化失败: $e');
      AppLogger.error('[SSL] storage auto reinitialize failed', e, st);
      return false;
    } finally {
      isRecoveringStorage = false;
    }
  }

  Future<void> _markStorageLost(String message) async {
    isInitialized = false;
    configData = configData.copyWith(initialized: false);
    certificateRecords.clear();
    selectedCertId = null;
    infoMessage = message;
    notifyListeners();
  }

  // ────────────────── PEM / filename validation ──────────────────

  bool _looksLikeCertificatePem(String content) {
    return content.contains('-----BEGIN CERTIFICATE-----') &&
        content.contains('-----END CERTIFICATE-----');
  }

  bool _looksLikePrivateKeyPem(String content) {
    final hasBegin = RegExp(
      r'-----BEGIN [A-Z ]*PRIVATE KEY-----',
    ).hasMatch(content);
    final hasEnd = RegExp(
      r'-----END [A-Z ]*PRIVATE KEY-----',
    ).hasMatch(content);
    return hasBegin && hasEnd;
  }

  bool _isAllowedImportFileName(String filePath, {required bool isCert}) {
    final fileName = p.basename(filePath);
    final pattern = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$');
    if (!pattern.hasMatch(fileName)) {
      return false;
    }
    final lower = fileName.toLowerCase();
    if (isCert) {
      return lower.endsWith('.crt') || lower.endsWith('.pem');
    }
    return lower.endsWith('.key') || lower.endsWith('.pem');
  }
}

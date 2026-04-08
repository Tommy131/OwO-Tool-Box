import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/services/persistence_service.dart';
import '../../../core/utils/logger.dart';
import '../models/ssl_models.dart';
import '../services/default_openssl_template.dart';

class OpenSslCnfCodeController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = (style ?? const TextStyle()).copyWith(
      fontFamily: 'monospace',
      fontSize: 12,
      height: 1.4,
    );
    if (withComposing &&
        value.composing.isValid &&
        !value.composing.isCollapsed) {
      // 输入法合成阶段退回系统渲染，避免中间插入/删除时文本错位。
      return super.buildTextSpan(
        context: context,
        style: baseStyle,
        withComposing: withComposing,
      );
    }
    final lines = text.split('\n');
    final children = <InlineSpan>[];
    for (int i = 0; i < lines.length; i++) {
      children.add(_highlightLine(lines[i], baseStyle));
      if (i != lines.length - 1) {
        children.add(TextSpan(text: '\n', style: baseStyle));
      }
    }
    return TextSpan(style: baseStyle, children: children);
  }

  TextSpan _highlightLine(String line, TextStyle baseStyle) {
    final trimmed = line.trimLeft();
    final commentColor = Colors.green.shade700;
    final sectionColor = Colors.purple.shade700;
    final keyColor = Colors.blue.shade700;
    final valueColor = Colors.orange.shade800;

    if (trimmed.startsWith('#')) {
      return TextSpan(
        text: line,
        style: baseStyle.copyWith(color: commentColor),
      );
    }
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      return TextSpan(
        text: line,
        style: baseStyle.copyWith(
          color: sectionColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    final eqIndex = line.indexOf('=');
    if (eqIndex > 0) {
      final keyArea = line.substring(0, eqIndex);
      final keyTextEnd = keyArea.replaceFirst(RegExp(r'[\t ]+$'), '').length;
      final key = keyArea.substring(0, keyTextEnd);
      final gap = keyArea.substring(keyTextEnd);
      final sep = line.substring(eqIndex, eqIndex + 1);
      final value = line.substring(eqIndex + 1);
      return TextSpan(
        children: [
          TextSpan(
            text: key,
            style: baseStyle.copyWith(color: keyColor),
          ),
          TextSpan(text: gap, style: baseStyle),
          TextSpan(text: sep, style: baseStyle),
          TextSpan(
            text: value,
            style: baseStyle.copyWith(color: valueColor),
          ),
        ],
      );
    }
    return TextSpan(text: line, style: baseStyle);
  }
}

class SslIssueExecutionResult {
  const SslIssueExecutionResult({
    required this.success,
    required this.message,
    this.record,
  });

  final bool success;
  final String message;
  final SslCertificateRecord? record;
}

class SslCertificateManagerProvider with ChangeNotifier {
  static const String moduleName = 'ssl_certificate_manager';
  static const String _snapshotKey = 'snapshot';
  static const String _snapshotFileName = 'ssl_certificate_manager_state.json';
  static const String _defaultCnfFileName = 'default_openssl.cnf';
  static const Set<String> _requiredIssueFieldKeys = {
    'domain',
    'commonName',
    'validDays',
    'countryName',
    'organizationName',
    'crlDistributionUrl',
    'ocspCaIssuersUrl',
    'ocspResponderUrl',
  };
  static const List<AltNameEntry> _legacyDefaultAltNames = [
    AltNameEntry(type: AltNameType.dns, value: 'your-domain.com'),
    AltNameEntry(type: AltNameType.dns, value: 'www.your-domain.com'),
    AltNameEntry(type: AltNameType.ip, value: '192.168.1.100'),
  ];

  final domainController = TextEditingController();
  final commonNameController = TextEditingController();
  final countryNameController = TextEditingController();
  final stateNameController = TextEditingController();
  final localityNameController = TextEditingController();
  final organizationNameController = TextEditingController();
  final organizationalUnitNameController = TextEditingController();
  final emailAddressController = TextEditingController();
  final explicitTextController = TextEditingController();
  final challengePasswordController = TextEditingController();
  final unstructuredNameController = TextEditingController();
  final ocspDomainController = TextEditingController();
  final rootCAFileNameController = TextEditingController();
  final validDaysController = TextEditingController();
  final ocspCaIssuersUrlController = TextEditingController();
  final ocspResponderUrlController = TextEditingController();
  final crlDistributionUrlController = TextEditingController();

  final storagePathController = TextEditingController();
  final rootCANameController = TextEditingController();
  final rootCAPasswordController = TextEditingController();
  final rootCACertPathController = TextEditingController();
  final rootCAKeyPathController = TextEditingController();
  final revokeReasonController = TextEditingController();
  final cnfEditorController = OpenSslCnfCodeController();

  bool isLoading = false;
  bool isInitialized = false;
  bool importRootCA = false;
  String infoMessage = '';
  String savedCnfContent = '';
  bool _isRecoveringStorage = false;

  late SslIssueTemplate _template;
  late SslManagerConfig _config;
  final List<SslCertificateRecord> _certificates = [];
  int selectedNavIndex = 0;
  String? selectedCertId;

  List<AltNameEntry> get altNames => List.unmodifiable(_template.altNames);
  List<TsaPolicyEntry> get tsaPolicies =>
      List.unmodifiable(_template.tsaPolicies);
  List<SslCertificateRecord> get certificates =>
      List.unmodifiable(_certificates);
  SslManagerConfig get config => _config;
  List<String> get selectedKeyUsageTypes =>
      List.unmodifiable(_selectedKeyUsageTypes);
  List<String> get selectedExtendedKeyUsageTypes =>
      List.unmodifiable(_selectedExtendedKeyUsageTypes);

  static const List<String> availableKeyUsageTypes = [
    'digitalSignature',
    'nonRepudiation',
    'keyEncipherment',
    'dataEncipherment',
    'keyAgreement',
    'keyCertSign',
    'cRLSign',
    'encipherOnly',
    'decipherOnly',
  ];

  static const List<String> availableExtendedKeyUsageTypes = [
    'serverAuth',
    'clientAuth',
    'codeSigning',
    'emailProtection',
    'timeStamping',
    'OCSPSigning',
    'ipsecIKE',
    'msCodeInd',
    'msCodeCom',
    'msCTLSign',
    'msEFS',
    'nsSGC',
  ];

  final List<String> _selectedKeyUsageTypes = [];
  final List<String> _selectedExtendedKeyUsageTypes = [];
  final Map<String, String> _pinnedIssueFieldValues = <String, String>{};
  bool _snapshotNeedsRepair = false;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    AppLogger.info('[SSL] initialize start');
    try {
      final persistence = PersistenceService();
      await persistence.ensureReady();

      _template = SslIssueTemplate.defaults();
      _config = const SslManagerConfig(
        initialized: false,
        storagePath: '',
        rootCAName: '',
        rootCAPassword: '',
        importRootCA: false,
        rootCACertPath: '',
        rootCAKeyPath: '',
        defaultCnfPath: '',
      );
      _applyTemplateToControllers(_template);
      _applyConfigToControllers(_config);

      await _loadSnapshotFromPersistence(persistence);
      await _loadSnapshotFromDiskIfAvailable();

      isInitialized = _config.initialized;
      infoMessage = isInitialized ? '已加载 SSL 证书管理配置。' : '请先完成初始化配置。';
      await _ensureCnfLoaded();
      if (_snapshotNeedsRepair) {
        await _persistAll();
        _snapshotNeedsRepair = false;
      }
      AppLogger.info(
        '[SSL] initialize done, initialized=$isInitialized, storagePath=${_config.storagePath}',
      );
    } catch (e) {
      infoMessage = '初始化失败: $e';
      AppLogger.error('[SSL] initialize failed', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectNav(int index) {
    selectedNavIndex = index;
    notifyListeners();
  }

  void setImportRootCA(bool value) {
    importRootCA = value;
    notifyListeners();
  }

  void updateAltNameType(int index, AltNameType type) {
    final current = [..._template.altNames];
    if (index < 0 || index >= current.length) return;
    current[index] = AltNameEntry(type: type, value: current[index].value);
    _template = _template.copyWith(altNames: current);
    notifyListeners();
  }

  void updateAltNameValue(int index, String value) {
    final current = [..._template.altNames];
    if (index < 0 || index >= current.length) return;
    current[index] = AltNameEntry(
      type: current[index].type,
      value: value.trim(),
    );
    _template = _template.copyWith(altNames: current);
    notifyListeners();
  }

  void addAltName() {
    _template = _template.copyWith(
      altNames: [
        ..._template.altNames,
        const AltNameEntry(type: AltNameType.dns, value: ''),
      ],
    );
    notifyListeners();
  }

  void removeAltName(int index) {
    final current = [..._template.altNames];
    if (index < 0 || index >= current.length) return;
    final previousLength = current.length;
    current.removeAt(index);
    _template = _template.copyWith(altNames: current);
    _reindexAltNamePinnedKeysAfterRemoval(
      removedIndex: index,
      previousLength: previousLength,
    );
    notifyListeners();
  }

  void togglePolicyEnabled(int index, bool enabled) {
    final current = [..._template.tsaPolicies];
    if (index < 0 || index >= current.length) return;
    current[index] = current[index].copyWith(enabled: enabled);
    _template = _template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  void updatePolicyName(int index, String name) {
    final current = [..._template.tsaPolicies];
    if (index < 0 || index >= current.length) return;
    current[index] = current[index].copyWith(name: name.trim());
    _template = _template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  void updatePolicyOid(int index, String oid) {
    final current = [..._template.tsaPolicies];
    if (index < 0 || index >= current.length) return;
    current[index] = current[index].copyWith(oid: oid.trim());
    _template = _template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  void addPolicy() {
    final current = [..._template.tsaPolicies];
    current.add(const TsaPolicyEntry(name: '', oid: '', description: ''));
    _template = _template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  void removePolicy(int index) {
    final current = [..._template.tsaPolicies];
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    _template = _template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  Future<void> completeInitialization() async {
    isLoading = true;
    notifyListeners();
    AppLogger.info('[SSL] completeInitialization start');
    try {
      _syncControllersToTemplate();

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

      _config = _config.copyWith(
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
          _defaultCnfFileName,
        ),
      );
      isInitialized = true;
      infoMessage = '初始化完成，可开始签发和管理证书。';
      AppLogger.info(
        '[SSL] completeInitialization success, importRootCA=$importRootCA, storagePath=$storagePath',
      );

      await _persistAll();
      await _ensureCnfLoaded();
    } catch (e) {
      infoMessage = '初始化失败: $e';
      AppLogger.error('[SSL] completeInitialization failed', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool get isRootPasswordEmpty => rootCAPasswordController.text.trim().isEmpty;

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

    final keyCheck = await _verifyImportedPrivateKeyPassword(
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

    final opensslInfo = await _readCertificateMetaByOpenSsl(certSource);
    if (opensslInfo == null || opensslInfo.isEmpty) {
      AppLogger.warning('[SSL] root cert metadata parse failed');
      return RootCaValidationResult.invalid(
        '无法正确读取导入根证书的信息，请检查证书是否有效或本机是否可用 openssl。',
      );
    }

    final keyMatch = await _verifyCertificateKeyMatch(
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

  String buildDraftCnfPreview() {
    return _buildRenderedCnfContent();
  }

  Future<SslIssueExecutionResult> issueCertificate() async {
    if (!isInitialized) {
      infoMessage = '请先完成初始化。';
      AppLogger.warning('[SSL] issueCertificate blocked: not initialized');
      notifyListeners();
      return const SslIssueExecutionResult(success: false, message: '请先完成初始化。');
    }
    if (!await _ensureStorageAvailableOrRecover()) {
      notifyListeners();
      return SslIssueExecutionResult(success: false, message: infoMessage);
    }

    isLoading = true;
    notifyListeners();
    SslIssueExecutionResult result = const SslIssueExecutionResult(
      success: false,
      message: '签发失败：未知错误',
    );
    try {
      _syncControllersToTemplate();
      final requiredFieldsError = _validateRequiredIssueFields();
      if (requiredFieldsError != null) {
        throw Exception(requiredFieldsError);
      }
      await _ensureOpenSslAvailable();
      final domain = _template.domain.trim();
      if (domain.isEmpty) {
        throw Exception('域名不能为空');
      }
      AppLogger.info('[SSL] issueCertificate start, domain=$domain');

      final now = DateTime.now();
      final safeName = _sanitizeFileStem(domain);
      final fileToken = '${safeName}_${now.millisecondsSinceEpoch}';

      final configPath = p.join(
        _config.storagePath,
        'openssl_config',
        '$fileToken.cnf',
      );
      final keyPath = p.join(_config.storagePath, 'private', '$fileToken.key');
      final csrPath = p.join(_config.storagePath, 'csr', '$fileToken.csr');
      final certPath = p.join(
        _config.storagePath,
        'newcerts',
        '$fileToken.crt',
      );

      // 生成每次签发的独立配置文件，便于审计和复现。
      final renderedCnf = _buildRenderedCnfContent();
      await File(configPath).writeAsString(renderedCnf);

      await _runOpenSslOrThrow(
        [
          'genpkey',
          '-algorithm',
          'RSA',
          '-pkeyopt',
          'rsa_keygen_bits:2048',
          '-out',
          keyPath,
        ],
        action: '生成证书私钥',
        timeout: const Duration(seconds: 20),
      );

      await _runOpenSslOrThrow(
        [
          'req',
          '-new',
          '-sha256',
          '-batch',
          '-key',
          keyPath,
          '-out',
          csrPath,
          '-config',
          configPath,
          '-reqexts',
          'v3_req',
          '-subj',
          _buildDistinguishedName(commonName: _template.commonName),
        ],
        action: '生成证书请求',
        workingDirectory: _config.storagePath,
        timeout: const Duration(seconds: 20),
      );

      final rootCertPath = rootCACertPathController.text.trim();
      final rootKeyPath = rootCAKeyPathController.text.trim();
      if (rootCertPath.isEmpty || rootKeyPath.isEmpty) {
        throw Exception('未找到可用的根证书或根私钥，请重新初始化。');
      }
      final caSerialPath = p.join(
        _config.storagePath,
        '_files',
        'issued_cert.srl',
      );
      final signArgs = <String>[
        'x509',
        '-req',
        '-in',
        csrPath,
        '-CA',
        rootCertPath,
        '-CAkey',
        rootKeyPath,
        '-out',
        certPath,
        '-days',
        '${_template.validDays}',
        '-sha256',
        '-extfile',
        configPath,
        '-extensions',
        'v3_req',
        '-CAserial',
        caSerialPath,
      ];
      if (!await File(caSerialPath).exists()) {
        signArgs.add('-CAcreateserial');
      }
      if (rootCAPasswordController.text.isNotEmpty) {
        signArgs.addAll(['-passin', 'pass:${rootCAPasswordController.text}']);
      }

      await _runOpenSslOrThrow(
        signArgs,
        action: '签发证书',
        workingDirectory: _config.storagePath,
        timeout: const Duration(seconds: 20),
      );

      final certMeta = await _readIssuedCertificateMeta(certPath);
      if (certMeta == null) {
        throw Exception('证书已生成，但无法读取签发结果，请检查 openssl 输出。');
      }

      final newRecord = SslCertificateRecord(
        id: fileToken,
        domain: domain,
        commonName: _template.commonName,
        issuer: certMeta.issuer,
        serialNumber: certMeta.serialNumber,
        issuedAt: certMeta.issuedAt,
        expiresAt: certMeta.expiresAt,
        status: SslCertStatus.issued,
        altNames: _template.altNames,
        configFilePath: configPath,
        certFilePath: certPath,
        keyFilePath: keyPath,
        csrFilePath: csrPath,
      );
      _certificates.insert(0, newRecord);
      selectedCertId = newRecord.id;
      infoMessage = '证书已根据 OpenSSL 配置完成真实签发。';
      AppLogger.info(
        '[SSL] issueCertificate success, serial=${certMeta.serialNumber}',
      );

      await _persistAll();
      result = SslIssueExecutionResult(
        success: true,
        message: infoMessage,
        record: newRecord,
      );
    } catch (e) {
      infoMessage = '签发失败: $e';
      AppLogger.error('[SSL] issueCertificate failed', e);
      result = SslIssueExecutionResult(success: false, message: infoMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return result;
  }

  Future<void> revokeCertificate(String certificateId) async {
    if (!await _ensureStorageAvailableOrRecover()) {
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    AppLogger.info('[SSL] revokeCertificate start, id=$certificateId');
    try {
      final index = _certificates.indexWhere((e) => e.id == certificateId);
      if (index < 0) return;

      final reason = revokeReasonController.text.trim().isEmpty
          ? '用户手动撤销'
          : revokeReasonController.text.trim();
      _certificates[index] = _certificates[index].copyWith(
        status: SslCertStatus.revoked,
        revokeReason: reason,
      );
      final revokeLog = File(p.join(_config.storagePath, 'revoke.log'));
      await revokeLog.writeAsString(
        '[${DateTime.now().toIso8601String()}] revoke serial=${_certificates[index].serialNumber}, reason=$reason\n',
        mode: FileMode.append,
      );
      infoMessage = '证书已撤销。';
      AppLogger.info('[SSL] revokeCertificate success, id=$certificateId');
      await _persistAll();
    } catch (e) {
      infoMessage = '撤销失败: $e';
      AppLogger.error('[SSL] revokeCertificate failed', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _reindexAltNamePinnedKeysAfterRemoval({
    required int removedIndex,
    required int previousLength,
  }) {
    final nextPinnedFieldValues = <String, String>{};
    for (final entry in _pinnedIssueFieldValues.entries) {
      final fieldKey = entry.key;
      if (!fieldKey.startsWith('altName_')) {
        nextPinnedFieldValues[fieldKey] = entry.value;
        continue;
      }
      final index = int.tryParse(fieldKey.substring('altName_'.length));
      if (index == null || index < 0 || index >= previousLength) {
        continue;
      }
      if (index == removedIndex) {
        continue;
      }
      nextPinnedFieldValues[altNameFieldKey(
            index > removedIndex ? index - 1 : index,
          )] =
          entry.value;
    }
    _pinnedIssueFieldValues
      ..clear()
      ..addAll(nextPinnedFieldValues);
  }

  String? _validateRequiredIssueFields() {
    final missingLabels = <String>[];
    if (_template.domain.trim().isEmpty) {
      missingLabels.add('域名');
    }
    if (_template.commonName.trim().isEmpty) {
      missingLabels.add('通用名称');
    }
    if (_template.validDays <= 0) {
      missingLabels.add('有效期');
    }
    if (_template.countryName.trim().isEmpty) {
      missingLabels.add('国家');
    }
    if (_template.organizationName.trim().isEmpty) {
      missingLabels.add('组织');
    }
    if (_template.crlDistributionUrl.trim().isEmpty) {
      missingLabels.add('CRL Distribution URL');
    }
    if (_template.ocspCaIssuersUrl.trim().isEmpty) {
      missingLabels.add('OCSP CA Issuers URL');
    }
    if (_template.ocspResponderUrl.trim().isEmpty) {
      missingLabels.add('OCSP Responder URL');
    }
    if (missingLabels.isEmpty) {
      return null;
    }
    return '请先填写必填项：${missingLabels.join('、')}';
  }

  Future<void> deleteCertificate(String certificateId) async {
    if (!await _ensureStorageAvailableOrRecover()) {
      notifyListeners();
      return;
    }
    AppLogger.info('[SSL] deleteCertificate start, id=$certificateId');
    final index = _certificates.indexWhere((e) => e.id == certificateId);
    if (index < 0) return;

    final item = _certificates[index];
    _certificates.removeAt(index);
    if (selectedCertId == certificateId) {
      selectedCertId = null;
    }
    infoMessage = '证书记录已删除。';

    await _deleteIfExists(item.configFilePath);
    await _deleteIfExists(item.certFilePath);
    await _deleteIfExists(item.keyFilePath);
    await _deleteIfExists(item.csrFilePath);
    await _persistAll();
    AppLogger.info('[SSL] deleteCertificate success, id=$certificateId');
    notifyListeners();
  }

  Future<void> saveDefaultCnf() async {
    try {
      if (!await _ensureStorageAvailableOrRecover()) {
        notifyListeners();
        return;
      }
      final cnfPath = _config.defaultCnfPath;
      if (cnfPath.trim().isEmpty) {
        throw Exception('未找到默认配置路径');
      }
      await File(cnfPath).writeAsString(cnfEditorController.text);
      savedCnfContent = cnfEditorController.text;
      infoMessage = '默认 openssl.cnf 已保存。';
      AppLogger.info('[SSL] saveDefaultCnf success, path=$cnfPath');
      notifyListeners();
    } catch (e) {
      infoMessage = '保存失败: $e';
      AppLogger.error('[SSL] saveDefaultCnf failed', e);
      notifyListeners();
    }
  }

  Future<void> regenerateDefaultCnf() async {
    cnfEditorController.text = _buildRenderedCnfContent();
    await saveDefaultCnf();
  }

  void toggleKeyUsageType(String usage, bool enabled) {
    if (!availableKeyUsageTypes.contains(usage)) return;
    if (enabled) {
      if (!_selectedKeyUsageTypes.contains(usage)) {
        _selectedKeyUsageTypes.add(usage);
      }
    } else {
      _selectedKeyUsageTypes.remove(usage);
    }
    notifyListeners();
  }

  void toggleExtendedKeyUsageType(String usage, bool enabled) {
    if (!availableExtendedKeyUsageTypes.contains(usage)) return;
    if (enabled) {
      if (!_selectedExtendedKeyUsageTypes.contains(usage)) {
        _selectedExtendedKeyUsageTypes.add(usage);
      }
    } else {
      _selectedExtendedKeyUsageTypes.remove(usage);
    }
    notifyListeners();
  }

  String? issueFieldKeyForController(TextEditingController controller) {
    if (identical(controller, domainController)) return 'domain';
    if (identical(controller, commonNameController)) return 'commonName';
    if (identical(controller, challengePasswordController)) {
      return 'challengePassword';
    }
    if (identical(controller, validDaysController)) return 'validDays';
    if (identical(controller, countryNameController)) return 'countryName';
    if (identical(controller, stateNameController)) return 'stateName';
    if (identical(controller, localityNameController)) return 'localityName';
    if (identical(controller, organizationNameController)) {
      return 'organizationName';
    }
    if (identical(controller, organizationalUnitNameController)) {
      return 'organizationalUnitName';
    }
    if (identical(controller, emailAddressController)) return 'emailAddress';
    if (identical(controller, explicitTextController)) return 'explicitText';
    if (identical(controller, unstructuredNameController)) {
      return 'unstructuredName';
    }
    if (identical(controller, ocspDomainController)) return 'ocspDomain';
    if (identical(controller, crlDistributionUrlController)) {
      return 'crlDistributionUrl';
    }
    if (identical(controller, ocspCaIssuersUrlController)) {
      return 'ocspCaIssuersUrl';
    }
    if (identical(controller, ocspResponderUrlController)) {
      return 'ocspResponderUrl';
    }
    return null;
  }

  String altNameFieldKey(int index) => 'altName_$index';

  bool isIssueFieldPinned(String fieldKey) {
    return _pinnedIssueFieldValues.containsKey(fieldKey);
  }

  bool isIssueFieldRequired(String fieldKey) {
    return _requiredIssueFieldKeys.contains(fieldKey);
  }

  bool canPinIssueField(String fieldKey) {
    return _currentDraftIssueFieldValue(fieldKey).trim().isNotEmpty;
  }

  Future<void> toggleIssueFieldPinned(String fieldKey) async {
    final isPinned = isIssueFieldPinned(fieldKey);
    if (!isPinned && !canPinIssueField(fieldKey)) {
      return;
    }
    if (isPinned) {
      _pinnedIssueFieldValues.remove(fieldKey);
    } else {
      _pinnedIssueFieldValues[fieldKey] = _currentDraftIssueFieldValue(
        fieldKey,
      );
      _applyPinnedDraftValue(fieldKey);
    }
    _syncControllersToTemplate();
    await _persistAll();
    notifyListeners();
  }

  Future<void> resetUnpinnedIssueFields() async {
    final issueControllers = <TextEditingController>[
      domainController,
      commonNameController,
      challengePasswordController,
      validDaysController,
      countryNameController,
      stateNameController,
      localityNameController,
      organizationNameController,
      organizationalUnitNameController,
      emailAddressController,
      explicitTextController,
      unstructuredNameController,
      ocspDomainController,
      crlDistributionUrlController,
      ocspCaIssuersUrlController,
      ocspResponderUrlController,
    ];

    for (final controller in issueControllers) {
      final fieldKey = issueFieldKeyForController(controller);
      if (fieldKey == null || isIssueFieldPinned(fieldKey)) {
        continue;
      }
      controller.clear();
    }

    final preservedAltNames = <AltNameEntry>[];
    final nextPinnedFieldValues = <String, String>{};
    for (int index = 0; index < _template.altNames.length; index++) {
      final fieldKey = altNameFieldKey(index);
      final altName = _template.altNames[index];
      if (!isIssueFieldPinned(fieldKey) || altName.value.trim().isEmpty) {
        continue;
      }
      nextPinnedFieldValues[altNameFieldKey(preservedAltNames.length)] =
          _pinnedIssueFieldValues[fieldKey] ?? altName.value;
      preservedAltNames.add(altName);
    }

    final pinnedNonAltFields = Map<String, String>.fromEntries(
      _pinnedIssueFieldValues.entries.where(
        (entry) => !entry.key.startsWith('altName_'),
      ),
    );
    _pinnedIssueFieldValues
      ..clear()
      ..addAll(pinnedNonAltFields)
      ..addAll(nextPinnedFieldValues);

    _template = _template.copyWith(altNames: preservedAltNames);
    _syncControllersToTemplate();
    await _persistAll();
    notifyListeners();
  }

  String _buildRenderedCnfContent() {
    _syncControllersToTemplate();
    final keyUsageLine = _selectedKeyUsageTypes.join(', ');
    final extendedLine = _selectedExtendedKeyUsageTypes.join(', ');
    final caIssuersUri = ocspCaIssuersUrlController.text.trim();
    final ocspUri = ocspResponderUrlController.text.trim();
    final crlUri = crlDistributionUrlController.text.trim();

    final templateForRender = _template.copyWith(
      altNames: _template.altNames
          .where((e) => e.value.trim().isNotEmpty)
          .toList(growable: false),
    );

    var content = DefaultOpenSslTemplate.buildTemplate(templateForRender);
    content = content.replaceFirst(
      RegExp(r'^\s*keyUsage\s*=.*$', multiLine: true),
      keyUsageLine.isEmpty
          ? '# keyUsage omitted'
          : 'keyUsage              = $keyUsageLine',
    );
    content = content.replaceFirst(
      RegExp(r'^\s*extendedKeyUsage\s*=.*$', multiLine: true),
      extendedLine.isEmpty
          ? '# extendedKeyUsage omitted'
          : 'extendedKeyUsage      = $extendedLine',
    );
    content = content.replaceFirst(
      RegExp(r'^\s*caIssuers;URI\.0\s*=.*$', multiLine: true),
      caIssuersUri.isEmpty
          ? '# caIssuers;URI.0 omitted'
          : 'caIssuers;URI.0       = $caIssuersUri',
    );
    content = content.replaceFirst(
      RegExp(r'^\s*OCSP;URI\.0\s*=.*$', multiLine: true),
      ocspUri.isEmpty
          ? '# OCSP;URI.0 omitted'
          : 'OCSP;URI.0            = $ocspUri',
    );
    content = content.replaceFirst(
      RegExp(r'^\s*URI\.0\s*=.*$', multiLine: true),
      crlUri.isEmpty ? '# URI.0 omitted' : 'URI.0                 = $crlUri',
    );
    content = content.replaceFirst(
      RegExp(
        r'(\[\s*v3_req\s*\][\s\S]*?basicConstraints\s*=\s*)CA:TRUE',
        multiLine: true,
      ),
      r'CA:FALSE',
    );
    return content;
  }

  Future<void> changeStoragePath(String newPath) async {
    if (newPath.trim().isEmpty) return;
    storagePathController.text = newPath.trim();
    _config = _config.copyWith(
      storagePath: newPath.trim(),
      defaultCnfPath: p.join(
        newPath.trim(),
        'openssl_config',
        _defaultCnfFileName,
      ),
    );
    notifyListeners();
  }

  void selectCertificate(String? certificateId) {
    selectedCertId = certificateId;
    notifyListeners();
  }

  SslCertificateRecord? get selectedCertificate {
    if (selectedCertId == null) return null;
    for (final cert in _certificates) {
      if (cert.id == selectedCertId) return cert;
    }
    return null;
  }

  @override
  void dispose() {
    domainController.dispose();
    commonNameController.dispose();
    countryNameController.dispose();
    stateNameController.dispose();
    localityNameController.dispose();
    organizationNameController.dispose();
    organizationalUnitNameController.dispose();
    emailAddressController.dispose();
    explicitTextController.dispose();
    challengePasswordController.dispose();
    unstructuredNameController.dispose();
    ocspDomainController.dispose();
    rootCAFileNameController.dispose();
    validDaysController.dispose();
    ocspCaIssuersUrlController.dispose();
    ocspResponderUrlController.dispose();
    crlDistributionUrlController.dispose();
    storagePathController.dispose();
    rootCANameController.dispose();
    rootCAPasswordController.dispose();
    rootCACertPathController.dispose();
    rootCAKeyPathController.dispose();
    revokeReasonController.dispose();
    cnfEditorController.dispose();
    super.dispose();
  }

  Future<void> _loadSnapshotFromPersistence(
    PersistenceService persistence,
  ) async {
    final raw = persistence.getModuleData<dynamic>(moduleName, _snapshotKey);
    if (raw is! Map) return;
    final snapshot = SslManagerStateSnapshot.fromJson(
      Map<String, dynamic>.from(raw),
    );
    _applySnapshot(snapshot);
  }

  Future<void> _loadSnapshotFromDiskIfAvailable() async {
    final file = File(p.join(_config.storagePath, _snapshotFileName));
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
    _snapshotNeedsRepair =
        _snapshotNeedsRepair ||
        !_sameTemplate(snapshot.template, sanitizedTemplate) ||
        !_samePinnedIssueFieldValues(
          snapshot.pinnedIssueFieldValues,
          sanitizedPinnedValues,
        );
    _config = snapshot.config;
    _template = _mergePinnedIssueFieldValuesIntoTemplate(
      sanitizedTemplate,
      pinnedValues: sanitizedPinnedValues,
    );
    _certificates
      ..clear()
      ..addAll(snapshot.certificates);
    _pinnedIssueFieldValues
      ..clear()
      ..addAll(sanitizedPinnedValues);
    isInitialized = _config.initialized;
    importRootCA = _config.importRootCA;
    _applyTemplateToControllers(_template);
    _applyConfigToControllers(_config);
  }

  void _applyTemplateToControllers(SslIssueTemplate template) {
    domainController.text = template.domain;
    commonNameController.text = template.commonName;
    countryNameController.text = template.countryName;
    stateNameController.text = template.stateName;
    localityNameController.text = template.localityName;
    organizationNameController.text = template.organizationName;
    organizationalUnitNameController.text = template.organizationalUnitName;
    emailAddressController.text = template.emailAddress;
    explicitTextController.text = template.explicitText;
    challengePasswordController.text = template.challengePassword;
    unstructuredNameController.text = template.unstructuredName;
    ocspDomainController.text = template.ocspDomain;
    rootCAFileNameController.text = template.rootCAFileName;
    validDaysController.text = template.validDays > 0
        ? template.validDays.toString()
        : '';
    crlDistributionUrlController.text = template.crlDistributionUrl;
    ocspCaIssuersUrlController.text = template.ocspCaIssuersUrl;
    ocspResponderUrlController.text = template.ocspResponderUrl;
  }

  void _applyConfigToControllers(SslManagerConfig config) {
    storagePathController.text = config.storagePath;
    rootCANameController.text = config.rootCAName;
    rootCAPasswordController.text = config.rootCAPassword;
    rootCACertPathController.text = config.rootCACertPath;
    rootCAKeyPathController.text = config.rootCAKeyPath;
    importRootCA = config.importRootCA;
  }

  void _syncControllersToTemplate() {
    _template = _template.copyWith(
      domain: _resolvedIssueFieldText('domain', domainController.text),
      commonName: _resolvedIssueFieldText(
        'commonName',
        commonNameController.text,
      ),
      countryName: _resolvedIssueFieldText(
        'countryName',
        countryNameController.text,
      ),
      stateName: _resolvedIssueFieldText('stateName', stateNameController.text),
      localityName: _resolvedIssueFieldText(
        'localityName',
        localityNameController.text,
      ),
      organizationName: _resolvedIssueFieldText(
        'organizationName',
        organizationNameController.text,
      ),
      organizationalUnitName: _resolvedIssueFieldText(
        'organizationalUnitName',
        organizationalUnitNameController.text,
      ),
      emailAddress: _resolvedIssueFieldText(
        'emailAddress',
        emailAddressController.text,
      ),
      explicitText: _resolvedIssueFieldText(
        'explicitText',
        explicitTextController.text,
      ),
      challengePassword: _resolvedIssueFieldText(
        'challengePassword',
        challengePasswordController.text,
      ),
      unstructuredName: _resolvedIssueFieldText(
        'unstructuredName',
        unstructuredNameController.text,
      ),
      ocspDomain: _resolvedIssueFieldText(
        'ocspDomain',
        ocspDomainController.text,
      ),
      rootCAFileName: rootCAFileNameController.text.trim().isNotEmpty
          ? rootCAFileNameController.text.trim()
          : rootCANameController.text.trim(),
      crlDistributionUrl: _resolvedIssueFieldText(
        'crlDistributionUrl',
        crlDistributionUrlController.text,
      ),
      ocspCaIssuersUrl: _resolvedIssueFieldText(
        'ocspCaIssuersUrl',
        ocspCaIssuersUrlController.text,
      ),
      ocspResponderUrl: _resolvedIssueFieldText(
        'ocspResponderUrl',
        ocspResponderUrlController.text,
      ),
      validDays: _resolvedValidDays(),
      altNames: _resolvedAltNames(),
      tsaPolicies: _template.tsaPolicies
          .where((e) => e.name.trim().isNotEmpty && e.oid.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  bool _sameTemplate(SslIssueTemplate a, SslIssueTemplate b) {
    return json.encode(a.toJson()) == json.encode(b.toJson());
  }

  SslIssueTemplate _sanitizeLegacyTemplate(SslIssueTemplate template) {
    final legacyAltNames =
        template.altNames.length == _legacyDefaultAltNames.length &&
        List.generate(_legacyDefaultAltNames.length, (index) {
          final current = template.altNames[index];
          final legacy = _legacyDefaultAltNames[index];
          return current.type == legacy.type && current.value == legacy.value;
        }).every((matched) => matched);

    final matchCount = [
      template.domain == 'your-domain.com',
      template.commonName == 'Common Name',
      template.countryName == 'DE',
      template.stateName == 'Bayern',
      template.localityName == 'Munich',
      template.organizationName == 'OwOTeam',
      template.organizationalUnitName == 'Server Management',
      template.emailAddress == 'support@owoblog.com',
      template.explicitText == 'Issued by OwOTeam',
      template.challengePassword == 'password',
      template.unstructuredName == 'OwOTeam',
      template.ocspDomain == 'ssl.your-domain.com',
      template.rootCAFileName == 'YourDomain_Root_CA',
      template.validDays == 825,
      legacyAltNames,
    ].where((matched) => matched).length;

    if (matchCount < 3) {
      return template;
    }

    return template.copyWith(
      domain: template.domain == 'your-domain.com' ? '' : template.domain,
      commonName: template.commonName == 'Common Name'
          ? ''
          : template.commonName,
      countryName: template.countryName == 'DE' ? '' : template.countryName,
      stateName: template.stateName == 'Bayern' ? '' : template.stateName,
      localityName: template.localityName == 'Munich'
          ? ''
          : template.localityName,
      organizationName: template.organizationName == 'OwOTeam'
          ? ''
          : template.organizationName,
      organizationalUnitName:
          template.organizationalUnitName == 'Server Management'
          ? ''
          : template.organizationalUnitName,
      emailAddress: template.emailAddress == 'support@owoblog.com'
          ? ''
          : template.emailAddress,
      explicitText: template.explicitText == 'Issued by OwOTeam'
          ? ''
          : template.explicitText,
      challengePassword: template.challengePassword == 'password'
          ? ''
          : template.challengePassword,
      unstructuredName: template.unstructuredName == 'OwOTeam'
          ? ''
          : template.unstructuredName,
      ocspDomain: template.ocspDomain == 'ssl.your-domain.com'
          ? ''
          : template.ocspDomain,
      rootCAFileName: template.rootCAFileName == 'YourDomain_Root_CA'
          ? ''
          : template.rootCAFileName,
      altNames: legacyAltNames ? [] : template.altNames,
      validDays: template.validDays == 825 ? 0 : template.validDays,
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
    SslIssueTemplate template,
  ) {
    final migrated = <String, String>{};
    for (final fieldKey in fieldKeys) {
      if (!_isSupportedIssueFieldKey(fieldKey)) {
        continue;
      }
      final value = _currentIssueFieldValue(fieldKey, template: template);
      if (value.trim().isEmpty) {
        continue;
      }
      migrated[fieldKey] = value;
    }
    return migrated;
  }

  bool _isSupportedIssueFieldKey(String fieldKey) {
    if (_requiredIssueFieldKeys.contains(fieldKey)) {
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

  String _currentIssueFieldValue(
    String fieldKey, {
    SslIssueTemplate? template,
  }) {
    final source = template ?? _template;
    switch (fieldKey) {
      case 'domain':
        return source.domain;
      case 'commonName':
        return source.commonName;
      case 'challengePassword':
        return source.challengePassword;
      case 'validDays':
        return source.validDays > 0 ? source.validDays.toString() : '';
      case 'countryName':
        return source.countryName;
      case 'stateName':
        return source.stateName;
      case 'localityName':
        return source.localityName;
      case 'organizationName':
        return source.organizationName;
      case 'organizationalUnitName':
        return source.organizationalUnitName;
      case 'emailAddress':
        return source.emailAddress;
      case 'explicitText':
        return source.explicitText;
      case 'unstructuredName':
        return source.unstructuredName;
      case 'ocspDomain':
        return source.ocspDomain;
      case 'crlDistributionUrl':
        return source.crlDistributionUrl;
      case 'ocspCaIssuersUrl':
        return source.ocspCaIssuersUrl;
      case 'ocspResponderUrl':
        return source.ocspResponderUrl;
      default:
        if (fieldKey.startsWith('altName_')) {
          final index = int.tryParse(fieldKey.substring('altName_'.length));
          if (index == null || index < 0 || index >= source.altNames.length) {
            return '';
          }
          return source.altNames[index].value;
        }
        return '';
    }
  }

  String _currentDraftIssueFieldValue(String fieldKey) {
    switch (fieldKey) {
      case 'domain':
        return domainController.text;
      case 'commonName':
        return commonNameController.text;
      case 'challengePassword':
        return challengePasswordController.text;
      case 'validDays':
        return validDaysController.text;
      case 'countryName':
        return countryNameController.text;
      case 'stateName':
        return stateNameController.text;
      case 'localityName':
        return localityNameController.text;
      case 'organizationName':
        return organizationNameController.text;
      case 'organizationalUnitName':
        return organizationalUnitNameController.text;
      case 'emailAddress':
        return emailAddressController.text;
      case 'explicitText':
        return explicitTextController.text;
      case 'unstructuredName':
        return unstructuredNameController.text;
      case 'ocspDomain':
        return ocspDomainController.text;
      case 'crlDistributionUrl':
        return crlDistributionUrlController.text;
      case 'ocspCaIssuersUrl':
        return ocspCaIssuersUrlController.text;
      case 'ocspResponderUrl':
        return ocspResponderUrlController.text;
      default:
        return _currentIssueFieldValue(fieldKey);
    }
  }

  String _resolvedIssueFieldText(String fieldKey, String draftValue) {
    final pinnedValue = _pinnedIssueFieldValues[fieldKey];
    return (pinnedValue ?? draftValue).trim();
  }

  int _resolvedValidDays() {
    final pinnedValue = _pinnedIssueFieldValues['validDays'];
    final source = pinnedValue ?? validDaysController.text;
    return int.tryParse(source.trim()) ?? 0;
  }

  List<AltNameEntry> _resolvedAltNames() {
    final nextAltNames = <AltNameEntry>[];
    for (int index = 0; index < _template.altNames.length; index++) {
      final altName = _template.altNames[index];
      final pinnedValue = _pinnedIssueFieldValues[altNameFieldKey(index)];
      if (pinnedValue == null) {
        nextAltNames.add(altName);
        continue;
      }
      nextAltNames.add(
        AltNameEntry(type: altName.type, value: pinnedValue.trim()),
      );
    }
    return nextAltNames;
  }

  SslIssueTemplate _mergePinnedIssueFieldValuesIntoTemplate(
    SslIssueTemplate template, {
    Map<String, String>? pinnedValues,
  }) {
    final source = pinnedValues ?? _pinnedIssueFieldValues;
    final nextAltNames = <AltNameEntry>[];
    for (int index = 0; index < template.altNames.length; index++) {
      final altName = template.altNames[index];
      final pinnedValue = source[altNameFieldKey(index)];
      nextAltNames.add(
        pinnedValue == null
            ? altName
            : AltNameEntry(type: altName.type, value: pinnedValue.trim()),
      );
    }
    return template.copyWith(
      domain: (source['domain'] ?? template.domain).trim(),
      commonName: (source['commonName'] ?? template.commonName).trim(),
      countryName: (source['countryName'] ?? template.countryName).trim(),
      stateName: (source['stateName'] ?? template.stateName).trim(),
      localityName: (source['localityName'] ?? template.localityName).trim(),
      organizationName:
          (source['organizationName'] ?? template.organizationName).trim(),
      organizationalUnitName:
          (source['organizationalUnitName'] ?? template.organizationalUnitName)
              .trim(),
      emailAddress: (source['emailAddress'] ?? template.emailAddress).trim(),
      explicitText: (source['explicitText'] ?? template.explicitText).trim(),
      challengePassword:
          (source['challengePassword'] ?? template.challengePassword).trim(),
      unstructuredName:
          (source['unstructuredName'] ?? template.unstructuredName).trim(),
      ocspDomain: (source['ocspDomain'] ?? template.ocspDomain).trim(),
      crlDistributionUrl:
          (source['crlDistributionUrl'] ?? template.crlDistributionUrl).trim(),
      ocspCaIssuersUrl:
          (source['ocspCaIssuersUrl'] ?? template.ocspCaIssuersUrl).trim(),
      ocspResponderUrl:
          (source['ocspResponderUrl'] ?? template.ocspResponderUrl).trim(),
      validDays:
          int.tryParse(
            (source['validDays'] ?? '${template.validDays}').trim(),
          ) ??
          template.validDays,
      altNames: nextAltNames,
    );
  }

  void _applyPinnedDraftValue(String fieldKey) {
    final pinnedValue = _pinnedIssueFieldValues[fieldKey];
    if (pinnedValue == null) {
      return;
    }
    switch (fieldKey) {
      case 'domain':
        domainController.text = pinnedValue;
        return;
      case 'commonName':
        commonNameController.text = pinnedValue;
        return;
      case 'challengePassword':
        challengePasswordController.text = pinnedValue;
        return;
      case 'validDays':
        validDaysController.text = pinnedValue;
        return;
      case 'countryName':
        countryNameController.text = pinnedValue;
        return;
      case 'stateName':
        stateNameController.text = pinnedValue;
        return;
      case 'localityName':
        localityNameController.text = pinnedValue;
        return;
      case 'organizationName':
        organizationNameController.text = pinnedValue;
        return;
      case 'organizationalUnitName':
        organizationalUnitNameController.text = pinnedValue;
        return;
      case 'emailAddress':
        emailAddressController.text = pinnedValue;
        return;
      case 'explicitText':
        explicitTextController.text = pinnedValue;
        return;
      case 'unstructuredName':
        unstructuredNameController.text = pinnedValue;
        return;
      case 'ocspDomain':
        ocspDomainController.text = pinnedValue;
        return;
      case 'crlDistributionUrl':
        crlDistributionUrlController.text = pinnedValue;
        return;
      case 'ocspCaIssuersUrl':
        ocspCaIssuersUrlController.text = pinnedValue;
        return;
      case 'ocspResponderUrl':
        ocspResponderUrlController.text = pinnedValue;
        return;
    }
  }

  Future<void> _persistAll() async {
    final persistence = PersistenceService();
    await persistence.ensureReady();
    final snapshot = SslManagerStateSnapshot(
      config: _config,
      template: _template,
      certificates: _certificates,
      pinnedIssueFieldKeys: _pinnedIssueFieldValues.keys.toList()..sort(),
      pinnedIssueFieldValues: Map<String, String>.fromEntries(
        _pinnedIssueFieldValues.entries.toList()
          ..sort((left, right) => left.key.compareTo(right.key)),
      ),
    );

    await persistence.setModuleData(
      moduleName,
      _snapshotKey,
      snapshot.toJson(),
    );

    final storagePath = _config.storagePath.trim();
    if (storagePath.isNotEmpty && await Directory(storagePath).exists()) {
      final file = File(p.join(storagePath, _snapshotFileName));
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
    await _ensureOpenSslAvailable();
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
        _defaultCnfFileName,
      );
      await _runOpenSslOrThrow(
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
        _buildDistinguishedName(commonName: rootName),
      ];
      if (rootCAPasswordController.text.isNotEmpty) {
        rootReqArgs.addAll([
          '-passin',
          'pass:${rootCAPasswordController.text}',
        ]);
      }

      await _runOpenSslOrThrow(
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
    final cnfPath = p.join(storagePath, 'openssl_config', _defaultCnfFileName);
    final cnfContent = _buildRenderedCnfContent();
    await File(cnfPath).writeAsString(cnfContent);
    cnfEditorController.text = cnfContent;
    savedCnfContent = cnfContent;
  }

  Future<void> _ensureCnfLoaded() async {
    if (_config.defaultCnfPath.trim().isEmpty) {
      return;
    }
    final file = File(_config.defaultCnfPath);
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

  Future<void> _deleteIfExists(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

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

  Future<Map<String, String>?> _readCertificateMetaByOpenSsl(
    String certPath,
  ) async {
    try {
      final result = await _runOpenSsl([
        'x509',
        '-in',
        certPath,
        '-noout',
        '-subject',
        '-issuer',
        '-serial',
        '-startdate',
        '-enddate',
        '-fingerprint',
        '-sha256',
      ]);
      if (result == null || result.exitCode != 0) {
        return null;
      }

      final details = <String, String>{};
      final lines = result.stdout.toString().split('\n');
      for (final raw in lines) {
        final line = raw.trim();
        if (line.isEmpty) continue;
        if (line.startsWith('subject=')) {
          details['Subject'] = line.substring('subject='.length).trim();
        } else if (line.startsWith('issuer=')) {
          details['Issuer'] = line.substring('issuer='.length).trim();
        } else if (line.startsWith('serial=')) {
          details['Serial'] = line.substring('serial='.length).trim();
        } else if (line.startsWith('notBefore=')) {
          details['Not Before'] = line.substring('notBefore='.length).trim();
        } else if (line.startsWith('notAfter=')) {
          details['Not After'] = line.substring('notAfter='.length).trim();
        } else if (line.startsWith('sha256 Fingerprint=')) {
          details['SHA256 Fingerprint'] = line
              .substring('sha256 Fingerprint='.length)
              .trim();
        }
      }

      if (!details.containsKey('Subject') ||
          !details.containsKey('Not After')) {
        return null;
      }
      return details;
    } catch (e, st) {
      AppLogger.error('[SSL] read cert metadata failed', e, st);
      return null;
    }
  }

  Future<_IssuedCertificateMeta?> _readIssuedCertificateMeta(
    String certPath,
  ) async {
    final details = await _readCertificateMetaByOpenSsl(certPath);
    if (details == null || details.isEmpty) {
      return null;
    }

    final issuedAt = _parseOpenSslDate(details['Not Before']);
    final expiresAt = _parseOpenSslDate(details['Not After']);
    final serialNumber = (details['Serial'] ?? '').trim();
    if (issuedAt == null || expiresAt == null || serialNumber.isEmpty) {
      return null;
    }

    final issuerLine = (details['Issuer'] ?? '').trim();
    return _IssuedCertificateMeta(
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      serialNumber: serialNumber,
      issuer: _extractCommonName(issuerLine) ?? issuerLine,
    );
  }

  Future<PrivateKeyPasswordCheckResult> _verifyImportedPrivateKeyPassword(
    String keyPath,
    String password,
  ) async {
    try {
      // 使用空密码参数避免 openssl 进入交互阻塞。
      final plainRead = await _runOpenSsl([
        'pkey',
        '-in',
        keyPath,
        '-noout',
        '-passin',
        'pass:',
      ]);
      if (plainRead != null && plainRead.exitCode == 0) {
        AppLogger.debug('[SSL] private key can be read without password');
        return PrivateKeyPasswordCheckResult.valid(isEncrypted: false);
      }

      if (password.trim().isEmpty) {
        return PrivateKeyPasswordCheckResult.invalid('私钥疑似已加密，请填写正确的私钥密码后再继续。');
      }

      final passRead = await _runOpenSsl([
        'pkey',
        '-in',
        keyPath,
        '-noout',
        '-passin',
        'pass:$password',
      ]);
      if (passRead == null || passRead.exitCode != 0) {
        AppLogger.warning('[SSL] private key password incorrect');
        return PrivateKeyPasswordCheckResult.invalid('私钥密码错误，无法解锁该私钥。');
      }
      AppLogger.debug('[SSL] private key unlocked by provided password');
      return PrivateKeyPasswordCheckResult.valid(isEncrypted: true);
    } catch (e, st) {
      AppLogger.error(
        '[SSL] openssl unavailable when verifying private key',
        e,
        st,
      );
      return PrivateKeyPasswordCheckResult.invalid(
        '无法调用 openssl 校验私钥密码，请确认 openssl 已正确安装。',
      );
    }
  }

  Future<bool> _ensureStorageAvailableOrRecover({
    bool allowAutoRecover = true,
  }) async {
    if (!isInitialized) {
      return false;
    }
    final storagePath = _config.storagePath.trim();
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

    if (_isRecoveringStorage) {
      return false;
    }
    _isRecoveringStorage = true;
    try {
      AppLogger.warning(
        '[SSL] storage missing, auto reinitialize start: $storagePath',
      );
      await _markStorageLost('检测到存储目录已丢失，正在自动重新初始化...');
      await completeInitialization();
      final recovered = await Directory(_config.storagePath).exists();
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
      _isRecoveringStorage = false;
    }
  }

  Future<void> _markStorageLost(String message) async {
    isInitialized = false;
    _config = _config.copyWith(initialized: false);
    _certificates.clear();
    selectedCertId = null;
    infoMessage = message;
    notifyListeners();
  }

  Future<bool?> _verifyCertificateKeyMatch({
    required String certPath,
    required String keyPath,
    required bool usePassword,
    required String password,
  }) async {
    try {
      final certPub = await _runOpenSsl([
        'x509',
        '-in',
        certPath,
        '-pubkey',
        '-noout',
      ]);
      if (certPub == null || certPub.exitCode != 0) {
        return null;
      }

      final keyArgs = <String>['pkey', '-in', keyPath, '-pubout'];
      if (usePassword) {
        keyArgs.addAll(['-passin', 'pass:$password']);
      } else {
        // 非交互模式读取，防止 openssl 等待终端输入导致界面无响应。
        keyArgs.addAll(['-passin', 'pass:']);
      }
      final keyPub = await _runOpenSsl(keyArgs);
      if (keyPub == null || keyPub.exitCode != 0) {
        return null;
      }

      final certNormalized = certPub.stdout.toString().replaceAll(
        RegExp(r'\s+'),
        '',
      );
      final keyNormalized = keyPub.stdout.toString().replaceAll(
        RegExp(r'\s+'),
        '',
      );
      if (certNormalized.isEmpty || keyNormalized.isEmpty) {
        return null;
      }
      return certNormalized == keyNormalized;
    } catch (e, st) {
      AppLogger.error('[SSL] verify cert-key match failed', e, st);
      return null;
    }
  }

  Future<ProcessResult?> _runOpenSsl(
    List<String> args, {
    String? workingDirectory,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final result = await Process.run(
        'openssl',
        args,
        workingDirectory: workingDirectory,
      ).timeout(timeout);
      return result;
    } on TimeoutException {
      AppLogger.error(
        '[SSL] openssl command timeout: openssl ${_sanitizeOpenSslArgs(args)}',
      );
      return null;
    } catch (e, st) {
      AppLogger.error(
        '[SSL] openssl command failed: openssl ${_sanitizeOpenSslArgs(args)}',
        e,
        st,
      );
      return null;
    }
  }

  Future<void> _ensureOpenSslAvailable() async {
    final result = await _runOpenSsl(['version']);
    if (result == null || result.exitCode != 0) {
      throw Exception('未检测到可用的 openssl，请先安装并确保命令行可直接执行 openssl。');
    }
  }

  Future<ProcessResult> _runOpenSslOrThrow(
    List<String> args, {
    required String action,
    String? workingDirectory,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final result = await _runOpenSsl(
      args,
      workingDirectory: workingDirectory,
      timeout: timeout,
    );
    if (result == null) {
      throw Exception('$action失败：无法调用 openssl，请确认已安装且可在 PATH 中找到。');
    }
    if (result.exitCode != 0) {
      throw Exception('$action失败：${_extractOpenSslFailure(result)}');
    }
    return result;
  }

  String _extractOpenSslFailure(ProcessResult result) {
    final stderrText = result.stderr.toString().trim();
    final stdoutText = result.stdout.toString().trim();
    final message = stderrText.isNotEmpty ? stderrText : stdoutText;
    if (message.isEmpty) {
      return 'openssl 退出码 ${result.exitCode}';
    }
    return message
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(' | ');
  }

  String _sanitizeOpenSslArgs(List<String> args) {
    final sanitized = <String>[];
    for (int i = 0; i < args.length; i++) {
      final current = args[i];
      sanitized.add(current);
      if ((current == '-passin' ||
              current == '-passout' ||
              current == '-pass') &&
          i + 1 < args.length) {
        sanitized.add('***');
        i++;
      }
    }
    return sanitized.join(' ');
  }

  String _sanitizeFileStem(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return sanitized.isEmpty ? 'certificate' : sanitized;
  }

  String _buildDistinguishedName({required String commonName}) {
    final entries = <MapEntry<String, String>>[
      MapEntry('C', _template.countryName.trim()),
      MapEntry('ST', _template.stateName.trim()),
      MapEntry('L', _template.localityName.trim()),
      MapEntry('O', _template.organizationName.trim()),
      MapEntry('OU', _template.organizationalUnitName.trim()),
      MapEntry('CN', commonName.trim()),
      MapEntry('emailAddress', _template.emailAddress.trim()),
    ];

    final buffer = StringBuffer();
    for (final entry in entries) {
      if (entry.value.isEmpty) continue;
      buffer.write(
        '/${entry.key}=${_escapeDistinguishedNameValue(entry.value)}',
      );
    }
    return buffer.isEmpty
        ? '/CN=${_escapeDistinguishedNameValue(commonName)}'
        : buffer.toString();
  }

  String _escapeDistinguishedNameValue(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('/', r'\/')
        .replaceAll('"', r'\"')
        .replaceAll('+', r'\+')
        .replaceAll(',', r'\,')
        .replaceAll(';', r'\;')
        .replaceAll('<', r'\<')
        .replaceAll('>', r'\>')
        .replaceAll('=', r'\=');
  }

  DateTime? _parseOpenSslDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final normalized = raw.trim();
    final match = RegExp(
      r'^([A-Za-z]{3})\s+(\d{1,2})\s+(\d\d):(\d\d):(\d\d)\s+(\d{4})\s+GMT$',
    ).firstMatch(normalized);
    if (match == null) {
      return DateTime.tryParse(normalized)?.toLocal();
    }

    const months = <String, int>{
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final month = months[match.group(1)];
    if (month == null) {
      return null;
    }
    return DateTime.utc(
      int.parse(match.group(6)!),
      month,
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
    ).toLocal();
  }

  String? _extractCommonName(String issuerText) {
    final compact = issuerText.trim();
    final slashMatch = RegExp(r'(?:^|/)CN\s*=\s*([^/]+)').firstMatch(compact);
    if (slashMatch != null) {
      return slashMatch.group(1)?.trim();
    }
    final commaMatch = RegExp(r'CN\s*=\s*([^,]+)').firstMatch(compact);
    return commaMatch?.group(1)?.trim();
  }
}

class _IssuedCertificateMeta {
  const _IssuedCertificateMeta({
    required this.issuedAt,
    required this.expiresAt,
    required this.serialNumber,
    required this.issuer,
  });

  final DateTime issuedAt;
  final DateTime expiresAt;
  final String serialNumber;
  final String issuer;
}

class RootCaValidationResult {
  const RootCaValidationResult._({
    required this.isValid,
    required this.message,
    required this.details,
  });

  final bool isValid;
  final String message;
  final Map<String, String> details;

  factory RootCaValidationResult.valid(Map<String, String> details) {
    return RootCaValidationResult._(
      isValid: true,
      message: '校验成功',
      details: details,
    );
  }

  factory RootCaValidationResult.invalid(String message) {
    return RootCaValidationResult._(
      isValid: false,
      message: message,
      details: const <String, String>{},
    );
  }
}

class PrivateKeyPasswordCheckResult {
  const PrivateKeyPasswordCheckResult._({
    required this.isValid,
    required this.isEncrypted,
    required this.message,
  });

  final bool isValid;
  final bool isEncrypted;
  final String message;

  factory PrivateKeyPasswordCheckResult.valid({required bool isEncrypted}) {
    return PrivateKeyPasswordCheckResult._(
      isValid: true,
      isEncrypted: isEncrypted,
      message: '校验成功',
    );
  }

  factory PrivateKeyPasswordCheckResult.invalid(String message) {
    return PrivateKeyPasswordCheckResult._(
      isValid: false,
      isEncrypted: false,
      message: message,
    );
  }
}

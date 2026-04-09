import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/utils/logger.dart';
import '../models/ssl_models.dart';
import '../services/default_openssl_template.dart';
import '../services/openssl_command_service.dart';
import 'ssl_provider_base.dart';

/// Certificate issuance, renewal, CSR signing, template management, field
/// pinning, alt names, key usage, TSA policies and CNF rendering.
mixin SslIssueMixin on SslProviderBase {
  // ────────────────── alt names ──────────────────

  void updateAltNameType(int index, AltNameType type) {
    final current = [...template.altNames];
    if (index < 0 || index >= current.length) return;
    current[index] = AltNameEntry(type: type, value: current[index].value);
    template = template.copyWith(altNames: current);
    notifyListeners();
  }

  void updateAltNameValue(int index, String value) {
    final current = [...template.altNames];
    if (index < 0 || index >= current.length) return;
    current[index] = AltNameEntry(
      type: current[index].type,
      value: value.trim(),
    );
    template = template.copyWith(altNames: current);
    notifyListeners();
  }

  void addAltName() {
    template = template.copyWith(
      altNames: [
        ...template.altNames,
        const AltNameEntry(type: AltNameType.dns, value: ''),
      ],
    );
    notifyListeners();
  }

  void removeAltName(int index) {
    final current = [...template.altNames];
    if (index < 0 || index >= current.length) return;
    final previousLength = current.length;
    current.removeAt(index);
    template = template.copyWith(altNames: current);
    _reindexAltNamePinnedKeysAfterRemoval(
      removedIndex: index,
      previousLength: previousLength,
    );
    notifyListeners();
  }

  // ────────────────── TSA policies ──────────────────

  void togglePolicyEnabled(int index, bool enabled) {
    final current = [...template.tsaPolicies];
    if (index < 0 || index >= current.length) return;
    current[index] = current[index].copyWith(enabled: enabled);
    template = template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  void updatePolicyName(int index, String name) {
    final current = [...template.tsaPolicies];
    if (index < 0 || index >= current.length) return;
    current[index] = current[index].copyWith(name: name.trim());
    template = template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  void updatePolicyOid(int index, String oid) {
    final current = [...template.tsaPolicies];
    if (index < 0 || index >= current.length) return;
    current[index] = current[index].copyWith(oid: oid.trim());
    template = template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  void addPolicy() {
    final current = [...template.tsaPolicies];
    current.add(const TsaPolicyEntry(name: '', oid: '', description: ''));
    template = template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  void removePolicy(int index) {
    final current = [...template.tsaPolicies];
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    template = template.copyWith(tsaPolicies: current);
    notifyListeners();
  }

  // ────────────────── key usage ──────────────────

  void toggleKeyUsageType(String usage, bool enabled) {
    if (!SslProviderBase.availableKeyUsageTypes.contains(usage)) return;
    if (enabled) {
      if (!selectedKeyUsageTypesInternal.contains(usage)) {
        selectedKeyUsageTypesInternal.add(usage);
      }
    } else {
      selectedKeyUsageTypesInternal.remove(usage);
    }
    notifyListeners();
  }

  void toggleExtendedKeyUsageType(String usage, bool enabled) {
    if (!SslProviderBase.availableExtendedKeyUsageTypes.contains(usage)) return;
    if (enabled) {
      if (!selectedExtendedKeyUsageTypesInternal.contains(usage)) {
        selectedExtendedKeyUsageTypesInternal.add(usage);
      }
    } else {
      selectedExtendedKeyUsageTypesInternal.remove(usage);
    }
    notifyListeners();
  }

  // ────────────────── field key helpers ──────────────────

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

  // ────────────────── field pinning ──────────────────

  bool isIssueFieldPinned(String fieldKey) {
    return pinnedIssueFieldValues.containsKey(fieldKey);
  }

  bool isIssueFieldRequired(String fieldKey) {
    return SslProviderBase.requiredIssueFieldKeys.contains(fieldKey);
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
      pinnedIssueFieldValues.remove(fieldKey);
    } else {
      pinnedIssueFieldValues[fieldKey] = _currentDraftIssueFieldValue(
        fieldKey,
      );
      _applyPinnedDraftValue(fieldKey);
    }
    syncControllersToTemplate();
    await persistAll();
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
    for (int index = 0; index < template.altNames.length; index++) {
      final fieldKey = altNameFieldKey(index);
      final altName = template.altNames[index];
      if (!isIssueFieldPinned(fieldKey) || altName.value.trim().isEmpty) {
        continue;
      }
      nextPinnedFieldValues[altNameFieldKey(preservedAltNames.length)] =
          pinnedIssueFieldValues[fieldKey] ?? altName.value;
      preservedAltNames.add(altName);
    }

    final pinnedNonAltFields = Map<String, String>.fromEntries(
      pinnedIssueFieldValues.entries.where(
        (entry) => !entry.key.startsWith('altName_'),
      ),
    );
    pinnedIssueFieldValues
      ..clear()
      ..addAll(pinnedNonAltFields)
      ..addAll(nextPinnedFieldValues);

    template = template.copyWith(altNames: preservedAltNames);
    syncControllersToTemplate();
    await persistAll();
    notifyListeners();
  }

  // ────────────────── CNF preview / save ──────────────────

  String buildDraftCnfPreview() {
    return buildRenderedCnfContent();
  }

  Future<void> saveDefaultCnf() async {
    try {
      if (!await ensureStorageAvailableOrRecover()) {
        notifyListeners();
        return;
      }
      final cnfPath = configData.defaultCnfPath;
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
    cnfEditorController.text = buildRenderedCnfContent();
    await saveDefaultCnf();
  }

  // ────────────────── certificate issuance ──────────────────

  Future<SslIssueExecutionResult> issueCertificate() async {
    if (!isInitialized) {
      infoMessage = '请先完成初始化。';
      AppLogger.warning('[SSL] issueCertificate blocked: not initialized');
      notifyListeners();
      return const SslIssueExecutionResult(success: false, message: '请先完成初始化。');
    }
    if (!await ensureStorageAvailableOrRecover()) {
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
      syncControllersToTemplate();
      final requiredFieldsError = _validateRequiredIssueFields();
      if (requiredFieldsError != null) {
        throw Exception(requiredFieldsError);
      }
      await OpenSslCommandService.ensureOpenSslAvailable();
      final domain = template.domain.trim();
      if (domain.isEmpty) {
        throw Exception('域名不能为空');
      }
      final duplicatedDomainCert = _findBlockingCertificateByDomain(domain);
      if (duplicatedDomainCert != null) {
        throw Exception(
          '域名 "$domain" 已存在未过期的已签发证书（序列号：${duplicatedDomainCert.serialNumber}），禁止重复签发。',
        );
      }
      AppLogger.info('[SSL] issueCertificate start, domain=$domain');

      final now = DateTime.now();
      final safeName = _sanitizeFileStem(domain);
      final fileToken = '${safeName}_${now.millisecondsSinceEpoch}';

      final configPath = p.join(
        configData.storagePath,
        'openssl_config',
        '$fileToken.cnf',
      );
      final keyPath = p.join(configData.storagePath, 'private', '$fileToken.key');
      final csrPath = p.join(configData.storagePath, 'csr', '$fileToken.csr');
      final certPath = p.join(
        configData.storagePath,
        'newcerts',
        '$fileToken.crt',
      );

      // 生成每次签发的独立配置文件，便于审计和复现。
      final renderedCnf = buildRenderedCnfContent();
      await File(configPath).writeAsString(renderedCnf);

      await OpenSslCommandService.runOpenSslOrThrow(
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

      await OpenSslCommandService.runOpenSslOrThrow(
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
          buildDistinguishedName(commonName: template.commonName),
        ],
        action: '生成证书请求',
        workingDirectory: configData.storagePath,
        timeout: const Duration(seconds: 20),
      );

      final rootCertPath = rootCACertPathController.text.trim();
      final rootKeyPath = rootCAKeyPathController.text.trim();
      if (rootCertPath.isEmpty || rootKeyPath.isEmpty) {
        throw Exception('未找到可用的根证书或根私钥，请重新初始化。');
      }
      final caSerialPath = p.join(
        configData.storagePath,
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
        '${template.validDays}',
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

      await OpenSslCommandService.runOpenSslOrThrow(
        signArgs,
        action: '签发证书',
        workingDirectory: configData.storagePath,
        timeout: const Duration(seconds: 20),
      );

      final certMeta = await OpenSslCommandService.readIssuedCertificateMeta(
        certPath,
      );
      if (certMeta == null) {
        throw Exception('证书已生成，但无法读取签发结果，请检查 openssl 输出。');
      }

      final newRecord = SslCertificateRecord(
        id: fileToken,
        domain: domain,
        commonName: template.commonName,
        issuer: certMeta.issuer,
        serialNumber: certMeta.serialNumber,
        issuedAt: certMeta.issuedAt,
        expiresAt: certMeta.expiresAt,
        status: SslCertStatus.issued,
        altNames: template.altNames,
        configFilePath: configPath,
        certFilePath: certPath,
        keyFilePath: keyPath,
        csrFilePath: csrPath,
      );
      certificateRecords.insert(0, newRecord);
      selectedCertId = newRecord.id;
      infoMessage = '证书已根据 OpenSSL 配置完成真实签发。';
      addAuditEntry(
        AuditAction.issue,
        '签发: $domain (SN: ${certMeta.serialNumber})',
      );
      AppLogger.info(
        '[SSL] issueCertificate success, serial=${certMeta.serialNumber}',
      );

      await persistAll();
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

  // ────────────────── CSR signing ──────────────────

  Future<SslIssueExecutionResult> signExternalCsr({
    required String csrFilePath,
    required int validDays,
  }) async {
    if (!isInitialized) {
      return const SslIssueExecutionResult(success: false, message: '请先完成初始化。');
    }
    if (!await ensureStorageAvailableOrRecover()) {
      notifyListeners();
      return SslIssueExecutionResult(success: false, message: infoMessage);
    }
    isLoading = true;
    notifyListeners();
    try {
      await OpenSslCommandService.ensureOpenSslAvailable();

      final csrFile = File(csrFilePath);
      if (!await csrFile.exists()) {
        throw Exception('CSR 文件不存在: $csrFilePath');
      }

      // Read CSR subject to extract domain/CN
      final csrInfo = await OpenSslCommandService.runOpenSsl([
        'req',
        '-in',
        csrFilePath,
        '-noout',
        '-subject',
      ]);
      if (csrInfo == null || csrInfo.exitCode != 0) {
        throw Exception('无法读取 CSR 信息，请检查文件格式。');
      }
      final subjectLine = csrInfo.stdout.toString().trim();
      final cn =
          OpenSslCommandService.extractCommonName(subjectLine) ??
          'external-csr';
      final duplicatedDomainCert = _findBlockingCertificateByDomain(cn);
      if (duplicatedDomainCert != null) {
        throw Exception(
          '域名 "$cn" 已存在未过期的已签发证书（序列号：${duplicatedDomainCert.serialNumber}），禁止重复签发。',
        );
      }

      final now = DateTime.now();
      final safeName = _sanitizeFileStem(cn);
      final fileToken = 'csr_${safeName}_${now.millisecondsSinceEpoch}';
      final certPath = p.join(
        configData.storagePath,
        'newcerts',
        '$fileToken.crt',
      );
      final rootCertPath = rootCACertPathController.text.trim();
      final rootKeyPath = rootCAKeyPathController.text.trim();
      if (rootCertPath.isEmpty || rootKeyPath.isEmpty) {
        throw Exception('未找到可用的根证书或根私钥。');
      }

      final caSerialPath = p.join(
        configData.storagePath,
        '_files',
        'issued_cert.srl',
      );
      final signArgs = <String>[
        'x509',
        '-req',
        '-in',
        csrFilePath,
        '-CA',
        rootCertPath,
        '-CAkey',
        rootKeyPath,
        '-out',
        certPath,
        '-days',
        '$validDays',
        '-sha256',
        '-CAserial',
        caSerialPath,
      ];
      if (!await File(caSerialPath).exists()) {
        signArgs.add('-CAcreateserial');
      }
      if (rootCAPasswordController.text.isNotEmpty) {
        signArgs.addAll(['-passin', 'pass:${rootCAPasswordController.text}']);
      }

      await OpenSslCommandService.runOpenSslOrThrow(
        signArgs,
        action: '签发外部 CSR',
        timeout: const Duration(seconds: 20),
      );

      final certMeta = await OpenSslCommandService.readIssuedCertificateMeta(
        certPath,
      );
      if (certMeta == null) {
        throw Exception('证书已生成，但无法读取签发结果。');
      }

      final newRecord = SslCertificateRecord(
        id: fileToken,
        domain: cn,
        commonName: cn,
        issuer: certMeta.issuer,
        serialNumber: certMeta.serialNumber,
        issuedAt: certMeta.issuedAt,
        expiresAt: certMeta.expiresAt,
        status: SslCertStatus.issued,
        altNames: const [],
        configFilePath: '',
        certFilePath: certPath,
        keyFilePath: '',
        csrFilePath: csrFilePath,
      );
      certificateRecords.insert(0, newRecord);
      selectedCertId = newRecord.id;

      addAuditEntry(
        AuditAction.importCsr,
        'CSR 签发: $cn (SN: ${certMeta.serialNumber})',
      );
      infoMessage = '外部 CSR 签发成功。';
      AppLogger.info(
        '[SSL] signExternalCsr success, cn=$cn, serial=${certMeta.serialNumber}',
      );
      await persistAll();
      return SslIssueExecutionResult(
        success: true,
        message: infoMessage,
        record: newRecord,
      );
    } catch (e) {
      infoMessage = 'CSR 签发失败: $e';
      AppLogger.error('[SSL] signExternalCsr failed', e);
      return SslIssueExecutionResult(success: false, message: infoMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ────────────────── renewal ──────────────────

  void prepareRenewalFromCertificate(String certificateId) {
    final record = certificateRecords.firstWhere(
      (c) => c.id == certificateId,
      orElse: () => throw Exception('Certificate not found'),
    );
    domainController.text = record.domain;
    commonNameController.text = record.commonName;
    template = template.copyWith(
      domain: record.domain,
      commonName: record.commonName,
      altNames: record.altNames,
    );
    renewingCertId = certificateId;
    selectNav(1);
    notifyListeners();
  }

  Future<void> completeRenewalWithRevocation(String oldCertId) async {
    renewingCertId = null;
    await (this as dynamic).revokeCertificate(oldCertId);
  }

  // ────────────────── CNF rendering (implements abstract) ──────────────────

  @override
  String buildRenderedCnfContent() {
    syncControllersToTemplate();
    final keyUsageLine = selectedKeyUsageTypesInternal.join(', ');
    final extendedLine = selectedExtendedKeyUsageTypesInternal.join(', ');
    final caIssuersUri = ocspCaIssuersUrlController.text.trim();
    final ocspUri = ocspResponderUrlController.text.trim();
    final crlUri = crlDistributionUrlController.text.trim();

    final templateForRender = template.copyWith(
      altNames: template.altNames
          .where((e) => e.value.trim().isNotEmpty)
          .toList(growable: false),
    );
    final hasAltNames = templateForRender.altNames.isNotEmpty;

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
      RegExp(r'^\s*subjectAltName\s*=.*$', multiLine: true),
      hasAltNames
          ? 'subjectAltName        = @alt_names'
          : '# subjectAltName omitted',
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

  // ────────────────── private helpers ──────────────────

  String? _validateRequiredIssueFields() {
    final missingLabels = <String>[];
    if (template.domain.trim().isEmpty) {
      missingLabels.add('域名');
    }
    if (template.commonName.trim().isEmpty) {
      missingLabels.add('通用名称');
    }
    if (template.validDays <= 0) {
      missingLabels.add('有效期');
    }
    if (template.countryName.trim().isEmpty) {
      missingLabels.add('国家');
    }
    if (template.organizationName.trim().isEmpty) {
      missingLabels.add('组织');
    }
    if (template.crlDistributionUrl.trim().isEmpty) {
      missingLabels.add('CRL Distribution URL');
    }
    if (template.ocspCaIssuersUrl.trim().isEmpty) {
      missingLabels.add('OCSP CA Issuers URL');
    }
    if (template.ocspResponderUrl.trim().isEmpty) {
      missingLabels.add('OCSP Responder URL');
    }
    if (missingLabels.isEmpty) {
      return null;
    }
    return '请先填写必填项：${missingLabels.join('、')}';
  }

  void _reindexAltNamePinnedKeysAfterRemoval({
    required int removedIndex,
    required int previousLength,
  }) {
    final nextPinnedFieldValues = <String, String>{};
    for (final entry in pinnedIssueFieldValues.entries) {
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
    pinnedIssueFieldValues
      ..clear()
      ..addAll(nextPinnedFieldValues);
  }

  String _normalizeDomainKey(String raw) => raw.trim().toLowerCase();

  SslCertificateRecord? _findBlockingCertificateByDomain(String domain) {
    final normalized = _normalizeDomainKey(domain);
    if (normalized.isEmpty) {
      return null;
    }
    for (final cert in certificateRecords) {
      final sameDomain = _normalizeDomainKey(cert.domain) == normalized;
      final isBlocking = cert.status == SslCertStatus.issued && !cert.isExpired;
      if (sameDomain && isBlocking) {
        return cert;
      }
    }
    return null;
  }

  String _sanitizeFileStem(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return sanitized.isEmpty ? 'certificate' : sanitized;
  }

  // ────────────────── resolved field helpers ──────────────────

  String resolvedIssueFieldText(String fieldKey, String draftValue) {
    final pinnedValue = pinnedIssueFieldValues[fieldKey];
    return (pinnedValue ?? draftValue).trim();
  }

  int resolvedValidDays() {
    final pinnedValue = pinnedIssueFieldValues['validDays'];
    final source = pinnedValue ?? validDaysController.text;
    return int.tryParse(source.trim()) ?? 0;
  }

  List<AltNameEntry> resolvedAltNames() {
    final nextAltNames = <AltNameEntry>[];
    for (int index = 0; index < template.altNames.length; index++) {
      final altName = template.altNames[index];
      final pinnedValue = pinnedIssueFieldValues[altNameFieldKey(index)];
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

  String currentIssueFieldValue(
    String fieldKey, {
    SslIssueTemplate? templateOverride,
  }) {
    final source = templateOverride ?? template;
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
        return currentIssueFieldValue(fieldKey);
    }
  }

  SslIssueTemplate mergePinnedIssueFieldValuesIntoTemplate(
    SslIssueTemplate tpl, {
    Map<String, String>? pinnedValues,
  }) {
    final source = pinnedValues ?? pinnedIssueFieldValues;
    final nextAltNames = <AltNameEntry>[];
    for (int index = 0; index < tpl.altNames.length; index++) {
      final altName = tpl.altNames[index];
      final pinnedValue = source[altNameFieldKey(index)];
      nextAltNames.add(
        pinnedValue == null
            ? altName
            : AltNameEntry(type: altName.type, value: pinnedValue.trim()),
      );
    }
    return tpl.copyWith(
      domain: (source['domain'] ?? tpl.domain).trim(),
      commonName: (source['commonName'] ?? tpl.commonName).trim(),
      countryName: (source['countryName'] ?? tpl.countryName).trim(),
      stateName: (source['stateName'] ?? tpl.stateName).trim(),
      localityName: (source['localityName'] ?? tpl.localityName).trim(),
      organizationName:
          (source['organizationName'] ?? tpl.organizationName).trim(),
      organizationalUnitName:
          (source['organizationalUnitName'] ?? tpl.organizationalUnitName)
              .trim(),
      emailAddress: (source['emailAddress'] ?? tpl.emailAddress).trim(),
      explicitText: (source['explicitText'] ?? tpl.explicitText).trim(),
      challengePassword:
          (source['challengePassword'] ?? tpl.challengePassword).trim(),
      unstructuredName:
          (source['unstructuredName'] ?? tpl.unstructuredName).trim(),
      ocspDomain: (source['ocspDomain'] ?? tpl.ocspDomain).trim(),
      crlDistributionUrl:
          (source['crlDistributionUrl'] ?? tpl.crlDistributionUrl).trim(),
      ocspCaIssuersUrl:
          (source['ocspCaIssuersUrl'] ?? tpl.ocspCaIssuersUrl).trim(),
      ocspResponderUrl:
          (source['ocspResponderUrl'] ?? tpl.ocspResponderUrl).trim(),
      validDays:
          int.tryParse(
            (source['validDays'] ?? '${tpl.validDays}').trim(),
          ) ??
          tpl.validDays,
      altNames: nextAltNames,
    );
  }

  void _applyPinnedDraftValue(String fieldKey) {
    final pinnedValue = pinnedIssueFieldValues[fieldKey];
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

  String buildDistinguishedName({required String commonName}) {
    final entries = <MapEntry<String, String>>[
      MapEntry('C', template.countryName.trim()),
      MapEntry('ST', template.stateName.trim()),
      MapEntry('L', template.localityName.trim()),
      MapEntry('O', template.organizationName.trim()),
      MapEntry('OU', template.organizationalUnitName.trim()),
      MapEntry('CN', commonName.trim()),
      MapEntry('emailAddress', template.emailAddress.trim()),
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
}

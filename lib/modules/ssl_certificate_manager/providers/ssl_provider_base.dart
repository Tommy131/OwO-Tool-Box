import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/utils/logger.dart';
import '../models/ssl_models.dart';
import '../services/openssl_command_service.dart';
import 'ssl_cnf_code_controller.dart';

/// Base class for [SslCertificateManagerProvider].
///
/// Holds all state variables, controllers, constants, getters, and lightweight
/// methods that do not belong to issuance, revocation or persistence concerns.
///
/// Fields are intentionally non-private so that mixins (which use
/// `on SslProviderBase`) can access them directly.
abstract class SslProviderBase with ChangeNotifier {
  // ────────────────── constants ──────────────────

  static const String moduleName = 'ssl_certificate_manager';
  static const String snapshotKey = 'snapshot';
  static const String snapshotFileName = 'ssl_certificate_manager_state.json';
  static const String defaultCnfFileName = 'default_openssl.cnf';
  static const Set<String> requiredIssueFieldKeys = {
    'domain',
    'commonName',
    'validDays',
    'countryName',
    'organizationName',
    'crlDistributionUrl',
    'ocspCaIssuersUrl',
    'ocspResponderUrl',
  };
  static const List<AltNameEntry> legacyDefaultAltNames = [
    AltNameEntry(type: AltNameType.dns, value: 'your-domain.com'),
    AltNameEntry(type: AltNameType.dns, value: 'www.your-domain.com'),
    AltNameEntry(type: AltNameType.ip, value: '192.168.1.100'),
  ];

  // ────────────────── controllers ──────────────────

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

  // ────────────────── flags ──────────────────

  bool isLoading = false;
  bool isInitialized = false;
  bool importRootCA = false;
  String infoMessage = '';
  String savedCnfContent = '';
  @protected
  bool isRecoveringStorage = false;

  // ────────────────── core state ──────────────────

  @protected
  late SslIssueTemplate template;
  @protected
  late SslManagerConfig configData;
  @protected
  final List<SslCertificateRecord> certificateRecords = [];
  int selectedNavIndex = 0;
  String? selectedCertId;

  // ────────────────── key usage ──────────────────

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

  @protected
  final List<String> selectedKeyUsageTypesInternal = [];
  @protected
  final List<String> selectedExtendedKeyUsageTypesInternal = [];
  @protected
  final Map<String, String> pinnedIssueFieldValues = <String, String>{};
  @protected
  bool snapshotNeedsRepair = false;

  // ────────────────── CRL state ──────────────────

  @protected
  CrlState crlStateInternal = const CrlState();
  CrlState get crlState => crlStateInternal;

  // ────────────────── search / filter state ──────────────────

  final searchController = TextEditingController();
  @protected
  String searchQuery = '';
  @protected
  final Set<SslCertStatus> statusFilterSet = {};
  @protected
  bool filterExpiringSoonFlag = false;

  // ────────────────── renewal tracking ──────────────────

  String? renewingCertId;

  // ────────────────── batch operations ──────────────────

  @protected
  bool batchModeInternal = false;
  @protected
  final Set<String> batchSelectedIdsInternal = {};
  bool get batchMode => batchModeInternal;
  Set<String> get batchSelectedIds =>
      Set.unmodifiable(batchSelectedIdsInternal);

  // ────────────────── audit log ──────────────────

  @protected
  final List<AuditLogEntry> auditLogInternal = [];
  List<AuditLogEntry> get auditLog => List.unmodifiable(auditLogInternal);

  // ────────────────── CSR import ──────────────────

  final csrFilePathController = TextEditingController();
  final csrValidDaysController = TextEditingController();

  // ────────────────── public getters ──────────────────

  List<AltNameEntry> get altNames => List.unmodifiable(template.altNames);
  List<TsaPolicyEntry> get tsaPolicies =>
      List.unmodifiable(template.tsaPolicies);
  List<SslCertificateRecord> get certificatesList =>
      List.unmodifiable(certificateRecords);
  SslManagerConfig get configSnapshot => configData;
  List<String> get selectedKeyUsageTypes =>
      List.unmodifiable(selectedKeyUsageTypesInternal);
  List<String> get selectedExtendedKeyUsageTypes =>
      List.unmodifiable(selectedExtendedKeyUsageTypesInternal);

  // ────────────────── stats ──────────────────

  int get totalCertCount => certificateRecords.length;
  int get issuedCertCount => certificateRecords
      .where((c) => c.status == SslCertStatus.issued && !c.isExpired)
      .length;
  int get revokedCertCount =>
      certificateRecords.where((c) => c.status == SslCertStatus.revoked).length;
  int get expiringSoonCount =>
      certificateRecords.where((c) => c.isExpiringSoon).length;

  bool get isRootPasswordEmpty => rootCAPasswordController.text.trim().isEmpty;

  // ────────────────── filtered certificates ──────────────────

  List<SslCertificateRecord> get filteredCertificates {
    var result = List<SslCertificateRecord>.from(certificateRecords);
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((c) {
        return c.domain.toLowerCase().contains(query) ||
            c.commonName.toLowerCase().contains(query) ||
            c.serialNumber.toLowerCase().contains(query);
      }).toList();
    }
    if (statusFilterSet.isNotEmpty) {
      result = result.where((c) => statusFilterSet.contains(c.status)).toList();
    }
    if (filterExpiringSoonFlag) {
      result = result.where((c) => c.isExpiringSoon).toList();
    }
    return result;
  }

  Set<SslCertStatus> get statusFilter => Set.unmodifiable(statusFilterSet);
  bool get filterExpiringSoon => filterExpiringSoonFlag;

  // ────────────────── search / filter methods ──────────────────

  void updateSearchQuery(String query) {
    searchQuery = query.trim();
    notifyListeners();
  }

  void toggleStatusFilter(SslCertStatus status) {
    if (statusFilterSet.contains(status)) {
      statusFilterSet.remove(status);
    } else {
      statusFilterSet.add(status);
    }
    filterExpiringSoonFlag = false;
    notifyListeners();
  }

  void setFilterExpiringSoon(bool value) {
    filterExpiringSoonFlag = value;
    statusFilterSet.clear();
    notifyListeners();
  }

  void clearFilters() {
    searchQuery = '';
    statusFilterSet.clear();
    filterExpiringSoonFlag = false;
    searchController.clear();
    notifyListeners();
  }

  // ────────────────── navigation ──────────────────

  void selectNav(int index) {
    selectedNavIndex = index;
    notifyListeners();
  }

  void setImportRootCA(bool value) {
    importRootCA = value;
    notifyListeners();
  }

  void selectCertificate(String? certificateId) {
    selectedCertId = certificateId;
    notifyListeners();
  }

  SslCertificateRecord? get selectedCertificate {
    if (selectedCertId == null) return null;
    for (final cert in certificateRecords) {
      if (cert.id == selectedCertId) return cert;
    }
    return null;
  }

  // ────────────────── certificate details ──────────────────

  Future<CertificateDetailInfo?> fetchCertificateDetails(
    String certFilePath,
  ) async {
    try {
      final textResult = await OpenSslCommandService.runOpenSsl([
        'x509',
        '-text',
        '-noout',
        '-in',
        certFilePath,
      ]);
      if (textResult == null || textResult.exitCode != 0) return null;

      final fpResult = await OpenSslCommandService.runOpenSsl([
        'x509',
        '-fingerprint',
        '-sha256',
        '-noout',
        '-in',
        certFilePath,
      ]);
      String? fingerprint;
      if (fpResult != null && fpResult.exitCode == 0) {
        final fpLine = fpResult.stdout.toString().trim();
        final idx = fpLine.indexOf('=');
        fingerprint = idx > 0 ? fpLine.substring(idx + 1).trim() : fpLine;
      }

      return CertificateDetailInfo.fromOpenSslText(
        textResult.stdout.toString(),
        fingerprint: fingerprint,
      );
    } catch (e) {
      AppLogger.error('[SSL] fetchCertificateDetails failed', e);
      return null;
    }
  }

  // ────────────────── certificate export ──────────────────

  Future<String?> exportCertificatePkcs12(
    String certificateId,
    String pfxPassword,
  ) async {
    if (!isInitialized) return null;
    try {
      await OpenSslCommandService.ensureOpenSslAvailable();
      final record = certificateRecords.firstWhere(
        (c) => c.id == certificateId,
        orElse: () => throw Exception('Certificate not found'),
      );
      final pfxPath = p.join(configData.storagePath, 'pfx', '${record.id}.pfx');
      final rootCertPath = rootCACertPathController.text.trim();

      final args = <String>[
        'pkcs12',
        '-export',
        '-out',
        pfxPath,
        '-inkey',
        record.keyFilePath,
        '-in',
        record.certFilePath,
        '-passout',
        'pass:$pfxPassword',
      ];
      if (rootCertPath.isNotEmpty) {
        args.addAll(['-certfile', rootCertPath]);
      }

      await OpenSslCommandService.runOpenSslOrThrow(
        args,
        action: '导出 PKCS#12',
        timeout: const Duration(seconds: 15),
      );

      infoMessage = '证书已导出至 $pfxPath';
      addAuditEntry(AuditAction.export, '导出 PFX: ${record.domain} → $pfxPath');
      AppLogger.info('[SSL] exportPkcs12 success, path=$pfxPath');
      notifyListeners();
      return pfxPath;
    } catch (e) {
      infoMessage = '导出失败: $e';
      AppLogger.error('[SSL] exportPkcs12 failed', e);
      notifyListeners();
      return null;
    }
  }

  // ────────────────── certificate chain verification ──────────────────

  Future<({bool valid, String message})> verifyCertificateChain(
    String certificateId,
  ) async {
    try {
      final record = certificateRecords.firstWhere(
        (c) => c.id == certificateId,
        orElse: () => throw Exception('Certificate not found'),
      );
      final rootCertPath = rootCACertPathController.text.trim();
      if (rootCertPath.isEmpty) {
        return (valid: false, message: '未找到根证书路径');
      }

      final result = await OpenSslCommandService.runOpenSsl([
        'verify',
        '-CAfile',
        rootCertPath,
        record.certFilePath,
      ]);
      if (result == null) {
        return (valid: false, message: '无法调用 openssl');
      }
      final output = result.stdout.toString().trim();
      final isValid = result.exitCode == 0 && output.contains(': OK');
      return (valid: isValid, message: isValid ? '证书链验证通过' : output);
    } catch (e) {
      return (valid: false, message: '验证失败: $e');
    }
  }

  // ────────────────── audit log ──────────────────

  @protected
  void addAuditEntry(AuditAction action, String detail) {
    auditLogInternal.insert(
      0,
      AuditLogEntry(timestamp: DateTime.now(), action: action, detail: detail),
    );
    // Keep max 200 entries
    if (auditLogInternal.length > 200) {
      auditLogInternal.removeRange(200, auditLogInternal.length);
    }
  }

  void clearAuditLog() {
    auditLogInternal.clear();
    persistAll();
    notifyListeners();
  }

  // ────────────────── abstract hooks for mixins ──────────────────

  /// Persist all state to storage. Implemented by [SslPersistenceMixin].
  @protected
  Future<void> persistAll();

  /// Ensure CNF file is loaded. Implemented by [SslPersistenceMixin].
  @protected
  Future<void> ensureCnfLoaded();

  /// Sync text controllers to template. Implemented by [SslPersistenceMixin].
  @protected
  void syncControllersToTemplate();

  /// Ensure storage directory is available, auto-recover if missing.
  /// Implemented by [SslPersistenceMixin].
  @protected
  Future<bool> ensureStorageAvailableOrRecover({bool allowAutoRecover = true});

  /// Build rendered CNF content from current template state.
  /// Implemented by [SslIssueMixin].
  @protected
  String buildRenderedCnfContent();

  // ────────────────── dispose ──────────────────

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
    searchController.dispose();
    csrFilePathController.dispose();
    csrValidDaysController.dispose();
    super.dispose();
  }
}

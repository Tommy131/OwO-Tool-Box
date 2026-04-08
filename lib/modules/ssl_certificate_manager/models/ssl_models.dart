import 'dart:convert';

enum SslCertStatus { issued, revoked }

enum AltNameType { dns, ip }

class AltNameEntry {
  const AltNameEntry({required this.type, required this.value});

  final AltNameType type;
  final String value;

  Map<String, dynamic> toJson() => {'type': type.name, 'value': value};

  factory AltNameEntry.fromJson(Map<String, dynamic> json) {
    return AltNameEntry(
      type: AltNameType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AltNameType.dns,
      ),
      value: (json['value'] ?? '').toString(),
    );
  }
}

class TsaPolicyEntry {
  const TsaPolicyEntry({
    required this.name,
    required this.oid,
    required this.description,
    this.enabled = false,
  });

  final String name;
  final String oid;
  final String description;
  final bool enabled;

  TsaPolicyEntry copyWith({
    String? name,
    String? oid,
    String? description,
    bool? enabled,
  }) {
    return TsaPolicyEntry(
      name: name ?? this.name,
      oid: oid ?? this.oid,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'oid': oid,
    'description': description,
    'enabled': enabled,
  };

  factory TsaPolicyEntry.fromJson(Map<String, dynamic> json) {
    return TsaPolicyEntry(
      name: (json['name'] ?? '').toString(),
      oid: (json['oid'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      enabled: json['enabled'] == true,
    );
  }
}

class SslIssueTemplate {
  const SslIssueTemplate({
    required this.domain,
    required this.commonName,
    required this.countryName,
    required this.stateName,
    required this.localityName,
    required this.organizationName,
    required this.organizationalUnitName,
    required this.emailAddress,
    required this.explicitText,
    required this.challengePassword,
    required this.unstructuredName,
    required this.ocspDomain,
    required this.rootCAFileName,
    required this.crlDistributionUrl,
    required this.ocspCaIssuersUrl,
    required this.ocspResponderUrl,
    required this.altNames,
    required this.tsaPolicies,
    this.validDays = 0,
  });

  final String domain;
  final String commonName;
  final String countryName;
  final String stateName;
  final String localityName;
  final String organizationName;
  final String organizationalUnitName;
  final String emailAddress;
  final String explicitText;
  final String challengePassword;
  final String unstructuredName;
  final String ocspDomain;
  final String rootCAFileName;
  final String crlDistributionUrl;
  final String ocspCaIssuersUrl;
  final String ocspResponderUrl;
  final List<AltNameEntry> altNames;
  final List<TsaPolicyEntry> tsaPolicies;
  final int validDays;

  SslIssueTemplate copyWith({
    String? domain,
    String? commonName,
    String? countryName,
    String? stateName,
    String? localityName,
    String? organizationName,
    String? organizationalUnitName,
    String? emailAddress,
    String? explicitText,
    String? challengePassword,
    String? unstructuredName,
    String? ocspDomain,
    String? rootCAFileName,
    String? crlDistributionUrl,
    String? ocspCaIssuersUrl,
    String? ocspResponderUrl,
    List<AltNameEntry>? altNames,
    List<TsaPolicyEntry>? tsaPolicies,
    int? validDays,
  }) {
    return SslIssueTemplate(
      domain: domain ?? this.domain,
      commonName: commonName ?? this.commonName,
      countryName: countryName ?? this.countryName,
      stateName: stateName ?? this.stateName,
      localityName: localityName ?? this.localityName,
      organizationName: organizationName ?? this.organizationName,
      organizationalUnitName:
          organizationalUnitName ?? this.organizationalUnitName,
      emailAddress: emailAddress ?? this.emailAddress,
      explicitText: explicitText ?? this.explicitText,
      challengePassword: challengePassword ?? this.challengePassword,
      unstructuredName: unstructuredName ?? this.unstructuredName,
      ocspDomain: ocspDomain ?? this.ocspDomain,
      rootCAFileName: rootCAFileName ?? this.rootCAFileName,
      crlDistributionUrl: crlDistributionUrl ?? this.crlDistributionUrl,
      ocspCaIssuersUrl: ocspCaIssuersUrl ?? this.ocspCaIssuersUrl,
      ocspResponderUrl: ocspResponderUrl ?? this.ocspResponderUrl,
      altNames: altNames ?? this.altNames,
      tsaPolicies: tsaPolicies ?? this.tsaPolicies,
      validDays: validDays ?? this.validDays,
    );
  }

  Map<String, dynamic> toJson() => {
    'domain': domain,
    'commonName': commonName,
    'countryName': countryName,
    'stateName': stateName,
    'localityName': localityName,
    'organizationName': organizationName,
    'organizationalUnitName': organizationalUnitName,
    'emailAddress': emailAddress,
    'explicitText': explicitText,
    'challengePassword': challengePassword,
    'unstructuredName': unstructuredName,
    'ocspDomain': ocspDomain,
    'rootCAFileName': rootCAFileName,
    'crlDistributionUrl': crlDistributionUrl,
    'ocspCaIssuersUrl': ocspCaIssuersUrl,
    'ocspResponderUrl': ocspResponderUrl,
    'altNames': altNames.map((e) => e.toJson()).toList(),
    'tsaPolicies': tsaPolicies.map((e) => e.toJson()).toList(),
    'validDays': validDays,
  };

  factory SslIssueTemplate.fromJson(Map<String, dynamic> json) {
    return SslIssueTemplate(
      domain: (json['domain'] ?? '').toString(),
      commonName: (json['commonName'] ?? '').toString(),
      countryName: (json['countryName'] ?? '').toString(),
      stateName: (json['stateName'] ?? '').toString(),
      localityName: (json['localityName'] ?? '').toString(),
      organizationName: (json['organizationName'] ?? '').toString(),
      organizationalUnitName: (json['organizationalUnitName'] ?? '').toString(),
      emailAddress: (json['emailAddress'] ?? '').toString(),
      explicitText: (json['explicitText'] ?? '').toString(),
      challengePassword: (json['challengePassword'] ?? '').toString(),
      unstructuredName: (json['unstructuredName'] ?? '').toString(),
      ocspDomain: (json['ocspDomain'] ?? '').toString(),
      rootCAFileName: (json['rootCAFileName'] ?? '').toString(),
      crlDistributionUrl: (json['crlDistributionUrl'] ?? '').toString(),
      ocspCaIssuersUrl: (json['ocspCaIssuersUrl'] ?? '').toString(),
      ocspResponderUrl: (json['ocspResponderUrl'] ?? '').toString(),
      altNames: ((json['altNames'] as List?) ?? [])
          .map((e) => AltNameEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      tsaPolicies: ((json['tsaPolicies'] as List?) ?? [])
          .map((e) => TsaPolicyEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      validDays: json['validDays'] is int
          ? json['validDays'] as int
          : int.tryParse('${json['validDays']}') ?? 0,
    );
  }

  static SslIssueTemplate defaults() {
    return const SslIssueTemplate(
      domain: '',
      commonName: '',
      countryName: '',
      stateName: '',
      localityName: '',
      organizationName: '',
      organizationalUnitName: '',
      emailAddress: '',
      explicitText: '',
      challengePassword: '',
      unstructuredName: '',
      ocspDomain: '',
      rootCAFileName: '',
      crlDistributionUrl: '',
      ocspCaIssuersUrl: '',
      ocspResponderUrl: '',
      altNames: [],
      tsaPolicies: [],
      validDays: 0,
    );
  }
}

class SslManagerConfig {
  const SslManagerConfig({
    required this.initialized,
    required this.storagePath,
    required this.rootCAName,
    required this.rootCAPassword,
    required this.importRootCA,
    required this.rootCACertPath,
    required this.rootCAKeyPath,
    required this.defaultCnfPath,
  });

  final bool initialized;
  final String storagePath;
  final String rootCAName;
  final String rootCAPassword;
  final bool importRootCA;
  final String rootCACertPath;
  final String rootCAKeyPath;
  final String defaultCnfPath;

  SslManagerConfig copyWith({
    bool? initialized,
    String? storagePath,
    String? rootCAName,
    String? rootCAPassword,
    bool? importRootCA,
    String? rootCACertPath,
    String? rootCAKeyPath,
    String? defaultCnfPath,
  }) {
    return SslManagerConfig(
      initialized: initialized ?? this.initialized,
      storagePath: storagePath ?? this.storagePath,
      rootCAName: rootCAName ?? this.rootCAName,
      rootCAPassword: rootCAPassword ?? this.rootCAPassword,
      importRootCA: importRootCA ?? this.importRootCA,
      rootCACertPath: rootCACertPath ?? this.rootCACertPath,
      rootCAKeyPath: rootCAKeyPath ?? this.rootCAKeyPath,
      defaultCnfPath: defaultCnfPath ?? this.defaultCnfPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'initialized': initialized,
    'storagePath': storagePath,
    'rootCAName': rootCAName,
    'rootCAPassword': rootCAPassword,
    'importRootCA': importRootCA,
    'rootCACertPath': rootCACertPath,
    'rootCAKeyPath': rootCAKeyPath,
    'defaultCnfPath': defaultCnfPath,
  };

  factory SslManagerConfig.fromJson(Map<String, dynamic> json) {
    return SslManagerConfig(
      initialized: json['initialized'] == true,
      storagePath: (json['storagePath'] ?? '').toString(),
      rootCAName: (json['rootCAName'] ?? '').toString(),
      rootCAPassword: (json['rootCAPassword'] ?? '').toString(),
      importRootCA: json['importRootCA'] == true,
      rootCACertPath: (json['rootCACertPath'] ?? '').toString(),
      rootCAKeyPath: (json['rootCAKeyPath'] ?? '').toString(),
      defaultCnfPath: (json['defaultCnfPath'] ?? '').toString(),
    );
  }
}

enum CertificateExportFormat { pem, pkcs12 }

class CertificateDetailInfo {
  const CertificateDetailInfo({
    required this.publicKeyAlgorithm,
    required this.signatureAlgorithm,
    required this.keyUsage,
    required this.extendedKeyUsage,
    required this.subjectAltNames,
    required this.sha256Fingerprint,
    this.basicConstraints,
    this.authorityKeyIdentifier,
    this.subjectKeyIdentifier,
    this.rawFields = const {},
  });

  final String publicKeyAlgorithm;
  final String signatureAlgorithm;
  final List<String> keyUsage;
  final List<String> extendedKeyUsage;
  final List<String> subjectAltNames;
  final String sha256Fingerprint;
  final String? basicConstraints;
  final String? authorityKeyIdentifier;
  final String? subjectKeyIdentifier;
  final Map<String, String> rawFields;

  factory CertificateDetailInfo.fromOpenSslText(
    String text, {
    String? fingerprint,
  }) {
    final rawFields = <String, String>{};
    String publicKeyAlgo = '';
    String signatureAlgo = '';
    final keyUsageList = <String>[];
    final extKeyUsageList = <String>[];
    final sanList = <String>[];
    String? basicConstraints;
    String? authKeyId;
    String? subjectKeyId;

    final lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('Signature Algorithm:')) {
        signatureAlgo = line.substring('Signature Algorithm:'.length).trim();
        rawFields['Signature Algorithm'] = signatureAlgo;
      } else if (line.startsWith('Public Key Algorithm:')) {
        publicKeyAlgo = line.substring('Public Key Algorithm:'.length).trim();
        rawFields['Public Key Algorithm'] = publicKeyAlgo;
      } else if (line.contains('Public-Key:')) {
        final keySize = line.trim();
        if (publicKeyAlgo.isNotEmpty) {
          publicKeyAlgo = '$publicKeyAlgo ($keySize)';
        } else {
          publicKeyAlgo = keySize;
        }
        rawFields['Public Key'] = publicKeyAlgo;
      } else if (line.startsWith('Issuer:')) {
        rawFields['Issuer'] = line.substring('Issuer:'.length).trim();
      } else if (line.startsWith('Subject:')) {
        rawFields['Subject'] = line.substring('Subject:'.length).trim();
      } else if (line.startsWith('Not Before:')) {
        rawFields['Not Before'] = line.substring('Not Before:'.length).trim();
      } else if (line.startsWith('Not After :')) {
        rawFields['Not After'] = line.substring('Not After :'.length).trim();
      } else if (line.startsWith('Serial Number:')) {
        rawFields['Serial Number'] =
            line.substring('Serial Number:'.length).trim();
      } else if (line == 'X509v3 Key Usage: critical' ||
          line == 'X509v3 Key Usage:') {
        if (i + 1 < lines.length) {
          final usageLine = lines[i + 1].trim();
          keyUsageList.addAll(
            usageLine.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
          );
          rawFields['Key Usage'] = usageLine;
        }
      } else if (line.startsWith('X509v3 Extended Key Usage:')) {
        if (i + 1 < lines.length) {
          final usageLine = lines[i + 1].trim();
          extKeyUsageList.addAll(
            usageLine.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
          );
          rawFields['Extended Key Usage'] = usageLine;
        }
      } else if (line.startsWith('X509v3 Subject Alternative Name:')) {
        if (i + 1 < lines.length) {
          final sanLine = lines[i + 1].trim();
          sanList.addAll(
            sanLine.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
          );
          rawFields['Subject Alternative Name'] = sanLine;
        }
      } else if (line.startsWith('X509v3 Basic Constraints:')) {
        if (i + 1 < lines.length) {
          basicConstraints = lines[i + 1].trim();
          rawFields['Basic Constraints'] = basicConstraints;
        }
      } else if (line.startsWith('X509v3 Authority Key Identifier:')) {
        if (i + 1 < lines.length) {
          authKeyId = lines[i + 1].trim();
          rawFields['Authority Key Identifier'] = authKeyId;
        }
      } else if (line.startsWith('X509v3 Subject Key Identifier:')) {
        if (i + 1 < lines.length) {
          subjectKeyId = lines[i + 1].trim();
          rawFields['Subject Key Identifier'] = subjectKeyId;
        }
      }
    }

    return CertificateDetailInfo(
      publicKeyAlgorithm: publicKeyAlgo,
      signatureAlgorithm: signatureAlgo,
      keyUsage: keyUsageList,
      extendedKeyUsage: extKeyUsageList,
      subjectAltNames: sanList,
      sha256Fingerprint: fingerprint ?? '',
      basicConstraints: basicConstraints,
      authorityKeyIdentifier: authKeyId,
      subjectKeyIdentifier: subjectKeyId,
      rawFields: rawFields,
    );
  }
}

class CrlState {
  const CrlState({
    this.crlFilePath,
    this.lastGeneratedAt,
    this.crlDays = 30,
  });

  final String? crlFilePath;
  final DateTime? lastGeneratedAt;
  final int crlDays;

  CrlState copyWith({
    String? crlFilePath,
    DateTime? lastGeneratedAt,
    int? crlDays,
  }) {
    return CrlState(
      crlFilePath: crlFilePath ?? this.crlFilePath,
      lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
      crlDays: crlDays ?? this.crlDays,
    );
  }

  Map<String, dynamic> toJson() => {
    'crlFilePath': crlFilePath,
    'lastGeneratedAt': lastGeneratedAt?.toIso8601String(),
    'crlDays': crlDays,
  };

  factory CrlState.fromJson(Map<String, dynamic> json) {
    return CrlState(
      crlFilePath: json['crlFilePath']?.toString(),
      lastGeneratedAt: json['lastGeneratedAt'] != null
          ? DateTime.tryParse(json['lastGeneratedAt'].toString())
          : null,
      crlDays: json['crlDays'] is int ? json['crlDays'] as int : 30,
    );
  }
}

class SslCertificateRecord {
  const SslCertificateRecord({
    required this.id,
    required this.domain,
    required this.commonName,
    required this.issuer,
    required this.serialNumber,
    required this.issuedAt,
    required this.expiresAt,
    required this.status,
    required this.altNames,
    required this.configFilePath,
    required this.certFilePath,
    required this.keyFilePath,
    required this.csrFilePath,
    this.revokeReason,
  });

  final String id;
  final String domain;
  final String commonName;
  final String issuer;
  final String serialNumber;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final SslCertStatus status;
  final List<AltNameEntry> altNames;
  final String configFilePath;
  final String certFilePath;
  final String keyFilePath;
  final String csrFilePath;
  final String? revokeReason;

  bool get isExpired =>
      status == SslCertStatus.issued && expiresAt.isBefore(DateTime.now());

  bool get isExpiringSoon =>
      status == SslCertStatus.issued &&
      !isExpired &&
      expiresAt.difference(DateTime.now()).inDays <= 30;

  int get daysRemaining => expiresAt.difference(DateTime.now()).inDays;

  SslCertificateRecord copyWith({
    String? id,
    String? domain,
    String? commonName,
    String? issuer,
    String? serialNumber,
    DateTime? issuedAt,
    DateTime? expiresAt,
    SslCertStatus? status,
    List<AltNameEntry>? altNames,
    String? configFilePath,
    String? certFilePath,
    String? keyFilePath,
    String? csrFilePath,
    String? revokeReason,
  }) {
    return SslCertificateRecord(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      commonName: commonName ?? this.commonName,
      issuer: issuer ?? this.issuer,
      serialNumber: serialNumber ?? this.serialNumber,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      altNames: altNames ?? this.altNames,
      configFilePath: configFilePath ?? this.configFilePath,
      certFilePath: certFilePath ?? this.certFilePath,
      keyFilePath: keyFilePath ?? this.keyFilePath,
      csrFilePath: csrFilePath ?? this.csrFilePath,
      revokeReason: revokeReason ?? this.revokeReason,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'domain': domain,
    'commonName': commonName,
    'issuer': issuer,
    'serialNumber': serialNumber,
    'issuedAt': issuedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'status': status.name,
    'altNames': altNames.map((e) => e.toJson()).toList(),
    'configFilePath': configFilePath,
    'certFilePath': certFilePath,
    'keyFilePath': keyFilePath,
    'csrFilePath': csrFilePath,
    'revokeReason': revokeReason,
  };

  factory SslCertificateRecord.fromJson(Map<String, dynamic> json) {
    return SslCertificateRecord(
      id: (json['id'] ?? '').toString(),
      domain: (json['domain'] ?? '').toString(),
      commonName: (json['commonName'] ?? '').toString(),
      issuer: (json['issuer'] ?? '').toString(),
      serialNumber: (json['serialNumber'] ?? '').toString(),
      issuedAt:
          DateTime.tryParse((json['issuedAt'] ?? '').toString()) ??
          DateTime.now(),
      expiresAt:
          DateTime.tryParse((json['expiresAt'] ?? '').toString()) ??
          DateTime.now(),
      status: SslCertStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SslCertStatus.issued,
      ),
      altNames: ((json['altNames'] as List?) ?? [])
          .map((e) => AltNameEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      configFilePath: (json['configFilePath'] ?? '').toString(),
      certFilePath: (json['certFilePath'] ?? '').toString(),
      keyFilePath: (json['keyFilePath'] ?? '').toString(),
      csrFilePath: (json['csrFilePath'] ?? '').toString(),
      revokeReason: json['revokeReason']?.toString(),
    );
  }
}

enum AuditAction { issue, revoke, delete, export, crl, importCsr }

class AuditLogEntry {
  const AuditLogEntry({
    required this.timestamp,
    required this.action,
    required this.detail,
  });

  final DateTime timestamp;
  final AuditAction action;
  final String detail;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'action': action.name,
    'detail': detail,
  };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      timestamp:
          DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
          DateTime.now(),
      action: AuditAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => AuditAction.issue,
      ),
      detail: (json['detail'] ?? '').toString(),
    );
  }
}

class SslManagerStateSnapshot {
  const SslManagerStateSnapshot({
    required this.config,
    required this.template,
    required this.certificates,
    this.pinnedIssueFieldKeys = const [],
    this.pinnedIssueFieldValues = const {},
    this.crlState = const CrlState(),
    this.auditLog = const [],
  });

  final SslManagerConfig config;
  final SslIssueTemplate template;
  final List<SslCertificateRecord> certificates;
  final List<String> pinnedIssueFieldKeys;
  final Map<String, String> pinnedIssueFieldValues;
  final CrlState crlState;
  final List<AuditLogEntry> auditLog;

  Map<String, dynamic> toJson() => {
    'config': config.toJson(),
    'template': template.toJson(),
    'certificates': certificates.map((e) => e.toJson()).toList(),
    'pinnedIssueFieldKeys': pinnedIssueFieldKeys,
    'pinnedIssueFieldValues': pinnedIssueFieldValues,
    'crlState': crlState.toJson(),
    'auditLog': auditLog.map((e) => e.toJson()).toList(),
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory SslManagerStateSnapshot.fromJson(Map<String, dynamic> json) {
    return SslManagerStateSnapshot(
      config: SslManagerConfig.fromJson(
        Map<String, dynamic>.from(json['config'] as Map? ?? {}),
      ),
      template: SslIssueTemplate.fromJson(
        Map<String, dynamic>.from(json['template'] as Map? ?? {}),
      ),
      certificates: ((json['certificates'] as List?) ?? [])
          .map(
            (e) => SslCertificateRecord.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      pinnedIssueFieldKeys: ((json['pinnedIssueFieldKeys'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      pinnedIssueFieldValues:
          ((json['pinnedIssueFieldValues'] as Map?) ?? const {}).map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          ),
      crlState: json['crlState'] is Map
          ? CrlState.fromJson(Map<String, dynamic>.from(json['crlState'] as Map))
          : const CrlState(),
      auditLog: ((json['auditLog'] as List?) ?? [])
          .map(
            (e) => AuditLogEntry.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

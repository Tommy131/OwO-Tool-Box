import 'package:path/path.dart' as p;

class SslConfig {
  final String baseDir;
  final int days;
  final String domain;
  final String certName;
  final String rootCaName;
  final String ip;
  final String ocspServerUrl;
  final String crlUrl;
  final String userConfigPath;
  final String opensslConfigPath;
  final String caKeyPassword;
  final String pfxPassword;

  SslConfig({
    required this.baseDir,
    required this.days,
    required this.domain,
    required this.certName,
    required this.rootCaName,
    required this.ip,
    required this.ocspServerUrl,
    required this.crlUrl,
    String? userConfigPath,
    String? opensslConfigPath,
    required this.caKeyPassword,
    required this.pfxPassword,
  }) : userConfigPath = userConfigPath?.trim().isNotEmpty == true
           ? userConfigPath!
           : p.join(baseDir, 'openssl_config', '$domain.cnf'),
       opensslConfigPath = opensslConfigPath?.trim().isNotEmpty == true
           ? opensslConfigPath!
           : p.join(baseDir, 'openssl.cnf');

  factory SslConfig.defaults({required String baseDir}) {
    return SslConfig(
      baseDir: baseDir,
      days: 18250,
      domain: 'local.owoserver.com',
      certName: 'local.owoserver.com',
      rootCaName: 'OwOTeam_Root_CA',
      ip: '127.0.0.1:443',
      ocspServerUrl: 'http://ssl.owoserver.com/ocsp',
      crlUrl: 'http://ssl.owoserver.com/rootca.crl',
      caKeyPassword: '',
      pfxPassword: '',
    );
  }

  String get caCertDir => p.join(baseDir, 'CAcerts');
  String get csrDir => p.join(baseDir, 'csr');
  String get keyDir => p.join(baseDir, 'private');
  String get certDir => p.join(baseDir, 'newcerts');
  String get pfxDir => p.join(baseDir, 'pfx');
  String get opensslConfigDir => p.join(baseDir, 'openssl_config');
  String get filesDir => p.join(baseDir, '_files');

  String get csrFilePath => p.join(csrDir, '$domain.csr');
  String get caKeyPath => p.join(caCertDir, '$rootCaName.key');
  String get caCertPath => p.join(caCertDir, '$rootCaName.crt');
  String get userKeyPath => p.join(keyDir, '$domain.key');
  String get userCertPath => p.join(certDir, '$domain.crt');
  String get pfxFilePath => p.join(pfxDir, '$domain.pfx');
  String get revocationCertPath => p.join(certDir, '$certName.crt');
  String get crlPath => p.join(baseDir, 'rootca.crl');
  String get ocspIndexPath => p.join(filesDir, 'index.txt');
  String get serialFilePath => p.join(filesDir, 'serial');

  Map<String, dynamic> toMap() {
    return {
      'baseDir': baseDir,
      'days': days,
      'domain': domain,
      'certName': certName,
      'rootCaName': rootCaName,
      'ip': ip,
      'ocspServerUrl': ocspServerUrl,
      'crlUrl': crlUrl,
      'userConfigPath': userConfigPath,
      'opensslConfigPath': opensslConfigPath,
      'caKeyPassword': caKeyPassword,
      'pfxPassword': pfxPassword,
    };
  }

  factory SslConfig.fromMap(
    Map<String, dynamic> map, {
    required String baseDir,
  }) {
    final defaults = SslConfig.defaults(baseDir: baseDir);
    return SslConfig(
      baseDir: (map['baseDir'] as String?)?.trim().isNotEmpty == true
          ? (map['baseDir'] as String)
          : defaults.baseDir,
      days: (map['days'] as num?)?.toInt() ?? defaults.days,
      domain: (map['domain'] as String?) ?? defaults.domain,
      certName: (map['certName'] as String?) ?? defaults.certName,
      rootCaName: (map['rootCaName'] as String?) ?? defaults.rootCaName,
      ip: (map['ip'] as String?) ?? defaults.ip,
      ocspServerUrl:
          (map['ocspServerUrl'] as String?) ?? defaults.ocspServerUrl,
      crlUrl: (map['crlUrl'] as String?) ?? defaults.crlUrl,
      userConfigPath:
          (map['userConfigPath'] as String?) ?? defaults.userConfigPath,
      opensslConfigPath:
          (map['opensslConfigPath'] as String?) ?? defaults.opensslConfigPath,
      caKeyPassword:
          (map['caKeyPassword'] as String?) ?? defaults.caKeyPassword,
      pfxPassword: (map['pfxPassword'] as String?) ?? defaults.pfxPassword,
    );
  }

  SslConfig copyWith({
    String? baseDir,
    int? days,
    String? domain,
    String? certName,
    String? rootCaName,
    String? ip,
    String? ocspServerUrl,
    String? crlUrl,
    String? userConfigPath,
    String? opensslConfigPath,
    String? caKeyPassword,
    String? pfxPassword,
  }) {
    return SslConfig(
      baseDir: baseDir ?? this.baseDir,
      days: days ?? this.days,
      domain: domain ?? this.domain,
      certName: certName ?? this.certName,
      rootCaName: rootCaName ?? this.rootCaName,
      ip: ip ?? this.ip,
      ocspServerUrl: ocspServerUrl ?? this.ocspServerUrl,
      crlUrl: crlUrl ?? this.crlUrl,
      userConfigPath: userConfigPath ?? this.userConfigPath,
      opensslConfigPath: opensslConfigPath ?? this.opensslConfigPath,
      caKeyPassword: caKeyPassword ?? this.caKeyPassword,
      pfxPassword: pfxPassword ?? this.pfxPassword,
    );
  }
}

/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-22
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
/// 证书用途配置
class CertificatePurpose {
  final String id;
  final String name;
  final String description;
  final List<String> keyUsage;
  final List<String> extendedKeyUsage;
  final bool forCA;
  final bool forSSL;

  const CertificatePurpose({
    required this.id,
    required this.name,
    required this.description,
    required this.keyUsage,
    required this.extendedKeyUsage,
    this.forCA = false,
    this.forSSL = false,
  });

  /// 转换为 OpenSSL 配置扩展
  String toOpenSSLExtensions() {
    final buffer = StringBuffer();

    if (keyUsage.isNotEmpty) {
      buffer.writeln('keyUsage = ${keyUsage.join(", ")}');
    }

    if (extendedKeyUsage.isNotEmpty) {
      buffer.writeln('extendedKeyUsage = ${extendedKeyUsage.join(", ")}');
    }

    return buffer.toString();
  }
}

/// 预定义的证书用途
class CertificatePurposes {
  // CA 证书用途
  static const rootCA = CertificatePurpose(
    id: 'root_ca',
    name: 'Root CA',
    description: 'Root Certificate Authority',
    keyUsage: ['critical', 'keyCertSign', 'cRLSign', 'digitalSignature'],
    extendedKeyUsage: [],
    forCA: true,
  );

  static const intermediateCA = CertificatePurpose(
    id: 'intermediate_ca',
    name: 'Intermediate CA',
    description: 'Intermediate Certificate Authority',
    keyUsage: ['critical', 'keyCertSign', 'cRLSign', 'digitalSignature'],
    extendedKeyUsage: [],
    forCA: true,
  );

  // SSL/TLS 证书用途
  static const tlsServer = CertificatePurpose(
    id: 'tls_server',
    name: 'TLS/SSL Server',
    description: 'Web server authentication (HTTPS)',
    keyUsage: ['critical', 'digitalSignature', 'keyEncipherment'],
    extendedKeyUsage: ['serverAuth'],
    forSSL: true,
  );

  static const tlsClient = CertificatePurpose(
    id: 'tls_client',
    name: 'TLS/SSL Client',
    description: 'Client authentication',
    keyUsage: ['critical', 'digitalSignature', 'keyEncipherment'],
    extendedKeyUsage: ['clientAuth'],
    forSSL: true,
  );

  static const tlsServerClient = CertificatePurpose(
    id: 'tls_server_client',
    name: 'TLS Server + Client',
    description: 'Both server and client authentication',
    keyUsage: ['critical', 'digitalSignature', 'keyEncipherment'],
    extendedKeyUsage: ['serverAuth', 'clientAuth'],
    forSSL: true,
  );

  static const emailProtection = CertificatePurpose(
    id: 'email_protection',
    name: 'Email Protection',
    description: 'S/MIME email signing and encryption',
    keyUsage: ['critical', 'digitalSignature', 'keyEncipherment'],
    extendedKeyUsage: ['emailProtection'],
    forSSL: true,
  );

  static const codeSigning = CertificatePurpose(
    id: 'code_signing',
    name: 'Code Signing',
    description: 'Sign software and scripts',
    keyUsage: ['critical', 'digitalSignature'],
    extendedKeyUsage: ['codeSigning'],
    forSSL: true,
  );

  static const ocspSigning = CertificatePurpose(
    id: 'ocsp_signing',
    name: 'OCSP Signing',
    description: 'OCSP response signing',
    keyUsage: ['critical', 'digitalSignature'],
    extendedKeyUsage: ['OCSPSigning'],
    forSSL: true,
  );

  static const timestamping = CertificatePurpose(
    id: 'timestamping',
    name: 'Time Stamping',
    description: 'Timestamp Authority',
    keyUsage: ['critical', 'digitalSignature'],
    extendedKeyUsage: ['timeStamping'],
    forSSL: true,
  );

  static const custom = CertificatePurpose(
    id: 'custom',
    name: 'Custom',
    description: 'Custom certificate purpose',
    keyUsage: [],
    extendedKeyUsage: [],
    forCA: true,
    forSSL: true,
  );

  /// 获取所有 CA 证书用途
  static List<CertificatePurpose> get caPurposes => [
        rootCA,
        intermediateCA,
        custom,
      ];

  /// 获取所有 SSL 证书用途
  static List<CertificatePurpose> get sslPurposes => [
        tlsServer,
        tlsClient,
        tlsServerClient,
        emailProtection,
        codeSigning,
        ocspSigning,
        timestamping,
        custom,
      ];

  /// 根据 ID 获取用途
  static CertificatePurpose? getById(String id) {
    final all = [...caPurposes, ...sslPurposes];
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

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
class RevokedCertificate {
  final String serialNumber;
  final DateTime revocationDate;
  final String reason;
  final String issuer;

  RevokedCertificate({
    required this.serialNumber,
    required this.revocationDate,
    required this.reason,
    required this.issuer,
  });

  Map<String, dynamic> toJson() => {
        'serialNumber': serialNumber,
        'revocationDate': revocationDate.toIso8601String(),
        'reason': reason,
        'issuer': issuer,
      };

  factory RevokedCertificate.fromJson(Map<String, dynamic> json) {
    return RevokedCertificate(
      serialNumber: json['serialNumber'],
      revocationDate: DateTime.parse(json['revocationDate']),
      reason: json['reason'],
      issuer: json['issuer'],
    );
  }
}

class CAConfig {
  final String caName;
  final String caKeyPath;
  final String caCertPath;
  final String certPath;
  final String indexPath;
  final String serialPath;
  final String crlNumberPath;
  final String configPath;
  final String? caPassword;

  CAConfig({
    required this.caName,
    required this.caKeyPath,
    required this.caCertPath,
    required this.certPath,
    required this.indexPath,
    required this.serialPath,
    required this.crlNumberPath,
    required this.configPath,
    this.caPassword,
  });
}

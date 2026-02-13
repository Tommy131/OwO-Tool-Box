/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-30
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

class CloudflareConfig {
  final String apiToken;
  final bool isEmailKeyMode;
  final String? email;
  final String? apiKey;

  CloudflareConfig({
    required this.apiToken,
    this.isEmailKeyMode = false,
    this.email,
    this.apiKey,
  });

  Map<String, dynamic> toJson() => {
    'apiToken': apiToken,
    'isEmailKeyMode': isEmailKeyMode,
    'email': email,
    'apiKey': apiKey,
  };

  factory CloudflareConfig.fromJson(Map<String, dynamic> json) {
    return CloudflareConfig(
      apiToken: json['apiToken'] ?? '',
      isEmailKeyMode: json['isEmailKeyMode'] ?? false,
      email: json['email'],
      apiKey: json['apiKey'],
    );
  }

  bool get isValid =>
      isEmailKeyMode ? (email != null && apiKey != null) : apiToken.isNotEmpty;
}

class DdnsConfig {
  final String zoneId;
  final String recordId;
  final String domainName;
  final bool enabled;
  final DateTime? lastSync;
  final String? lastIp;

  DdnsConfig({
    required this.zoneId,
    required this.recordId,
    required this.domainName,
    this.enabled = false,
    this.lastSync,
    this.lastIp,
  });

  Map<String, dynamic> toJson() => {
    'zoneId': zoneId,
    'recordId': recordId,
    'domainName': domainName,
    'enabled': enabled,
    'lastSync': lastSync?.toIso8601String(),
    'lastIp': lastIp,
  };

  factory DdnsConfig.fromJson(Map<String, dynamic> json) {
    return DdnsConfig(
      zoneId: json['zoneId'],
      recordId: json['recordId'],
      domainName: json['domainName'],
      enabled: json['enabled'] ?? false,
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'])
          : null,
      lastIp: json['lastIp'],
    );
  }
}

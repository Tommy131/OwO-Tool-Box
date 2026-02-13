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

class CloudflareDNSRecord {
  final String id;
  final String zoneId;
  final String type;
  final String name;
  final String content;
  final bool proxiable;
  final bool proxied;
  final int ttl;
  final String comment;

  CloudflareDNSRecord({
    required this.id,
    required this.zoneId,
    required this.type,
    required this.name,
    required this.content,
    required this.proxiable,
    required this.proxied,
    required this.ttl,
    this.comment = '',
  });

  factory CloudflareDNSRecord.fromJson(
    Map<String, dynamic> json, [
    String? fallbackZoneId,
  ]) {
    return CloudflareDNSRecord(
      id: json['id'] ?? '',
      zoneId: json['zone_id'] ?? fallbackZoneId ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      content: json['content'] ?? '',
      proxiable: json['proxiable'] ?? false,
      proxied: json['proxied'] ?? false,
      ttl: json['ttl'] ?? 1,
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'content': content,
    'proxied': proxied,
    'ttl': ttl,
    'comment': comment,
  };
}

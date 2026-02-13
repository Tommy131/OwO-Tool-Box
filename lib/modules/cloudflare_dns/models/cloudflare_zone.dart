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

class CloudflareZone {
  final String id;
  final String name;
  final String status;
  final bool paused;
  final String type;

  CloudflareZone({
    required this.id,
    required this.name,
    required this.status,
    required this.paused,
    required this.type,
  });

  factory CloudflareZone.fromJson(Map<String, dynamic> json) {
    return CloudflareZone(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      paused: json['paused'],
      type: json['type'],
    );
  }
}

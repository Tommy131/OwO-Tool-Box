/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-12 19:06:25
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-13 00:35:36
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// 主机状态枚举
enum HostStatus {
  unknown, // 未检测
  online, // 在线且Token正确（绿色）
  offline, // 离线（灰色）
  authFailed, // 在线但Token错误（红色）
}

class HostModel {
  final String id;
  final String name;
  final String address;
  final int port;
  final String token;
  final DateTime createdAt;
  final DateTime? lastConnected;
  final HostStatus status;

  HostModel({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    required this.token,
    required this.createdAt,
    this.lastConnected,
    this.status = HostStatus.unknown, // 默认未检测
  });

  // 主机状态检测
  bool? get isOnline {
    switch (status) {
      case HostStatus.online:
        return true;
      case HostStatus.offline:
        return false;
      case HostStatus.authFailed:
        return true; // Token错误但主机在线
      case HostStatus.unknown:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'port': port,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'lastConnected': lastConnected?.toIso8601String(),
      // status 不保存，每次启动时重新检测
    };
  }

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      port: json['port'] as int,
      token: json['token'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastConnected: json['lastConnected'] != null
          ? DateTime.parse(json['lastConnected'] as String)
          : null,
      status: HostStatus.unknown,
    );
  }

  HostModel copyWith({
    String? id,
    String? name,
    String? address,
    int? port,
    String? token,
    DateTime? createdAt,
    DateTime? lastConnected,
    HostStatus? status,
  }) {
    return HostModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      port: port ?? this.port,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      lastConnected: lastConnected ?? this.lastConnected,
      status: status ?? this.status,
    );
  }
}

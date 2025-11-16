/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-20 00:00:00
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-20 00:00:00
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

/// 告警类型枚举
enum AlertType {
  hostOffline, // 主机离线
  hostOnline, // 主机上线
  authFailed, // 认证失败
  statusChange, // 状态变化
  custom, // 自定义告警
}

/// 告警严重程度枚举
enum AlertSeverity {
  critical, // 严重
  high, // 高
  medium, // 中
  low, // 低
}

/// 告警模型
class AlertModel {
  final String id;
  final String hostId;
  final String hostName;
  final String hostAddress;
  final int hostPort;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final bool acknowledged;
  final DateTime? acknowledgedAt;

  AlertModel({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.hostAddress,
    required this.hostPort,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    this.acknowledged = false,
    this.acknowledgedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostId': hostId,
      'hostName': hostName,
      'hostAddress': hostAddress,
      'hostPort': hostPort,
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'acknowledged': acknowledged,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
    };
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      hostAddress: json['hostAddress'] as String,
      hostPort: json['hostPort'] as int,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.custom,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.low,
      ),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      acknowledged: json['acknowledged'] as bool? ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.parse(json['acknowledgedAt'] as String)
          : null,
    );
  }

  AlertModel copyWith({
    String? id,
    String? hostId,
    String? hostName,
    String? hostAddress,
    int? hostPort,
    AlertType? type,
    AlertSeverity? severity,
    String? message,
    DateTime? timestamp,
    bool? acknowledged,
    DateTime? acknowledgedAt,
  }) {
    return AlertModel(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAddress: hostAddress ?? this.hostAddress,
      hostPort: hostPort ?? this.hostPort,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      acknowledged: acknowledged ?? this.acknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }
}

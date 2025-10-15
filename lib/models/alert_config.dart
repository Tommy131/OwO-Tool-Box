/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-12 23:17:09
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-12 23:17:09
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// lib/models/alert_config.dart
class AlertConfig {
  final bool enabled;
  final double cpuThreshold;
  final double memoryThreshold;
  final double diskThreshold;
  final double networkUploadThreshold; // KB/s
  final double networkDownloadThreshold; // KB/s
  final bool notifyOnDisconnect;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final int checkInterval; // 秒

  const AlertConfig({
    this.enabled = true,
    this.cpuThreshold = 90.0,
    this.memoryThreshold = 90.0,
    this.diskThreshold = 90.0,
    this.networkUploadThreshold = 10240.0, // 10 MB/s
    this.networkDownloadThreshold = 10240.0, // 10 MB/s
    this.notifyOnDisconnect = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.checkInterval = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'cpuThreshold': cpuThreshold,
      'memoryThreshold': memoryThreshold,
      'diskThreshold': diskThreshold,
      'networkUploadThreshold': networkUploadThreshold,
      'networkDownloadThreshold': networkDownloadThreshold,
      'notifyOnDisconnect': notifyOnDisconnect,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'checkInterval': checkInterval,
    };
  }

  factory AlertConfig.fromJson(Map<String, dynamic> json) {
    return AlertConfig(
      enabled: json['enabled'] ?? true,
      cpuThreshold: (json['cpuThreshold'] ?? 90.0).toDouble(),
      memoryThreshold: (json['memoryThreshold'] ?? 90.0).toDouble(),
      diskThreshold: (json['diskThreshold'] ?? 90.0).toDouble(),
      networkUploadThreshold:
          (json['networkUploadThreshold'] ?? 10240.0).toDouble(),
      networkDownloadThreshold:
          (json['networkDownloadThreshold'] ?? 10240.0).toDouble(),
      notifyOnDisconnect: json['notifyOnDisconnect'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      checkInterval: json['checkInterval'] ?? 5,
    );
  }

  AlertConfig copyWith({
    bool? enabled,
    double? cpuThreshold,
    double? memoryThreshold,
    double? diskThreshold,
    double? networkUploadThreshold,
    double? networkDownloadThreshold,
    bool? notifyOnDisconnect,
    bool? soundEnabled,
    bool? vibrationEnabled,
    int? checkInterval,
  }) {
    return AlertConfig(
      enabled: enabled ?? this.enabled,
      cpuThreshold: cpuThreshold ?? this.cpuThreshold,
      memoryThreshold: memoryThreshold ?? this.memoryThreshold,
      diskThreshold: diskThreshold ?? this.diskThreshold,
      networkUploadThreshold:
          networkUploadThreshold ?? this.networkUploadThreshold,
      networkDownloadThreshold:
          networkDownloadThreshold ?? this.networkDownloadThreshold,
      notifyOnDisconnect: notifyOnDisconnect ?? this.notifyOnDisconnect,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      checkInterval: checkInterval ?? this.checkInterval,
    );
  }
}

// 告警类型枚举
enum AlertType {
  cpuHigh,
  memoryHigh,
  diskHigh,
  networkUploadHigh,
  networkDownloadHigh,
  disconnected,
}

// 告警记录
class AlertRecord {
  final String id;
  final AlertType type;
  final String hostName;
  final double value;
  final double threshold;
  final DateTime timestamp;
  final bool acknowledged;

  AlertRecord({
    required this.id,
    required this.type,
    required this.hostName,
    required this.value,
    required this.threshold,
    required this.timestamp,
    this.acknowledged = false,
  });

  String get message {
    switch (type) {
      case AlertType.cpuHigh:
        return 'CPU使用率过高：${value.toStringAsFixed(1)}% (阈值: ${threshold.toStringAsFixed(0)}%)';
      case AlertType.memoryHigh:
        return '内存使用率过高：${value.toStringAsFixed(1)}% (阈值: ${threshold.toStringAsFixed(0)}%)';
      case AlertType.diskHigh:
        return '磁盘使用率过高：${value.toStringAsFixed(1)}% (阈值: ${threshold.toStringAsFixed(0)}%)';
      case AlertType.networkUploadHigh:
        return '上传速率异常：${_formatSpeed(value)} (阈值: ${_formatSpeed(threshold)})';
      case AlertType.networkDownloadHigh:
        return '下载速率异常：${_formatSpeed(value)} (阈值: ${_formatSpeed(threshold)})';
      case AlertType.disconnected:
        return '服务器连接断开';
    }
  }

  String _formatSpeed(double kbps) {
    if (kbps < 1024) {
      return '${kbps.toStringAsFixed(1)} KB/s';
    } else {
      return '${(kbps / 1024).toStringAsFixed(2)} MB/s';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'hostName': hostName,
      'value': value,
      'threshold': threshold,
      'timestamp': timestamp.toIso8601String(),
      'acknowledged': acknowledged,
    };
  }

  factory AlertRecord.fromJson(Map<String, dynamic> json) {
    return AlertRecord(
      id: json['id'],
      type: AlertType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      hostName: json['hostName'],
      value: json['value'],
      threshold: json['threshold'],
      timestamp: DateTime.parse(json['timestamp']),
      acknowledged: json['acknowledged'] ?? false,
    );
  }
}

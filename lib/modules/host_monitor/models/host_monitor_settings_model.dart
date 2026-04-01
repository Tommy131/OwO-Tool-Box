/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-12 19:07:23
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-18 16:30:00
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
class HostMonitorSettingsModel {
  // 主机检测相关
  final int refreshInterval; // 刷新监控间隔
  final int chartDataPoints; // 图表绘制点数
  final int hostCheckTimeout; // 主机检测tick (in seconds)
  final int hostCheckInterval; // 主机超时间隔 (in minutes)

  // 告警配置相关
  final bool enabledAlert; // 告警是否启用
  final double cpuThreshold; // CPU使用率阈值
  final double memoryThreshold; // 内存使用率阈值
  final double diskThreshold; // 磁盘使用率阈值
  final double networkUploadThreshold; // 上传速率阈值 (KB/s)
  final double networkDownloadThreshold; // 下载速率阈值 (KB/s)
  final bool notifyOnDisconnect; // 是否在断开连接时通知
  final bool soundEnabled; // 是否启用声音通知
  final bool vibrationEnabled; // 是否启用震动通知
  final int checkInterval; // 告警检查间隔 (秒)

  const HostMonitorSettingsModel({
    this.refreshInterval = 1,
    this.chartDataPoints = 60,
    this.hostCheckTimeout = 10,
    this.hostCheckInterval = 5,

    // 添加告警设置的默认值
    this.enabledAlert = true,
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
      'refreshIntervalSeconds': refreshInterval,
      'chartDataPoints': chartDataPoints,
      'hostCheckInterval': hostCheckInterval,
      'hostCheckTimeout': hostCheckTimeout,

      // 告警配置相关
      'enabledAlert': enabledAlert,
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

  factory HostMonitorSettingsModel.fromJson(Map<String, dynamic> json) {
    return HostMonitorSettingsModel(
      refreshInterval: json['refreshIntervalSeconds'] as int? ?? 1,
      chartDataPoints: json['chartDataPoints'] as int? ?? 60,
      hostCheckInterval: json['hostCheckInterval'] as int? ?? 5,
      hostCheckTimeout: json['hostCheckTimeout'] as int? ?? 10,
      enabledAlert: json['enabledAlert'] ?? true,
      cpuThreshold: (json['cpuThreshold'] ?? 90.0).toDouble(),
      memoryThreshold: (json['memoryThreshold'] ?? 90.0).toDouble(),
      diskThreshold: (json['diskThreshold'] ?? 90.0).toDouble(),
      networkUploadThreshold: (json['networkUploadThreshold'] ?? 10240.0)
          .toDouble(),
      networkDownloadThreshold: (json['networkDownloadThreshold'] ?? 10240.0)
          .toDouble(),
      notifyOnDisconnect: json['notifyOnDisconnect'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      checkInterval: json['checkInterval'] ?? 5,
    );
  }

  HostMonitorSettingsModel copyWith({
    int? refreshInterval,
    int? chartDataPoints,
    int? hostCheckTimeout,
    int? hostCheckInterval,

    // 告警配置相关
    bool? enabledAlert,
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
    return HostMonitorSettingsModel(
      refreshInterval: refreshInterval ?? this.refreshInterval,
      chartDataPoints: chartDataPoints ?? this.chartDataPoints,
      hostCheckTimeout: hostCheckTimeout ?? this.hostCheckTimeout,
      hostCheckInterval: hostCheckInterval ?? this.hostCheckInterval,

      // 告警配置相关
      enabledAlert: enabledAlert ?? this.enabledAlert,
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

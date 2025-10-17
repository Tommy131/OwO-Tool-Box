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
 * @LastEditTime : 2025-10-13 15:10:18
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// lib/models/app_settings.dart
class AppSettings {
  final int refreshInterval;
  final int chartDataPoints; // 图表数据点数量
  final int hostCheckTimeout;
  final int hostCheckInterval;

  const AppSettings({
    this.refreshInterval = 1,
    this.chartDataPoints = 60, // 默认60个点
    this.hostCheckTimeout = 10,
    this.hostCheckInterval = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshIntervalSeconds': refreshInterval,
      'chartDataPoints': chartDataPoints,
      'hostCheckInterval': hostCheckInterval,
      'hostCheckTimeout': hostCheckTimeout,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      refreshInterval: json['refreshIntervalSeconds'] as int? ?? 1,
      chartDataPoints: json['chartDataPoints'] as int? ?? 60,
      hostCheckInterval: json['hostCheckInterval'] as int? ?? 5,
      hostCheckTimeout: json['hostCheckTimeout'] as int? ?? 10,
    );
  }

  AppSettings copyWith({
    refreshInterval,
    int? chartDataPoints,
  }) {
    return AppSettings(
      refreshInterval: refreshInterval,
      chartDataPoints: chartDataPoints ?? this.chartDataPoints,
      hostCheckInterval: hostCheckInterval,
      hostCheckTimeout: hostCheckTimeout,
    );
  }
}

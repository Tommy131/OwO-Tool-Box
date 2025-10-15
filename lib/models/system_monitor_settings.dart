// ============================================================================
// 系统监控设置数据模型
// ============================================================================

import 'alert_config.dart';

class SystemMonitorSettings {
  final int refreshInterval;
  final int hostCheckTimeout;
  final int hostCheckInterval;
  final AlertConfig alertConfig;

  const SystemMonitorSettings({
    required this.refreshInterval,
    required this.hostCheckTimeout,
    required this.hostCheckInterval,
    required this.alertConfig,
  });

  SystemMonitorSettings copyWith({
    int? refreshInterval,
    int? hostCheckTimeout,
    int? hostCheckInterval,
    AlertConfig? alertConfig,
  }) {
    return SystemMonitorSettings(
      refreshInterval: refreshInterval ?? this.refreshInterval,
      hostCheckTimeout: hostCheckTimeout ?? this.hostCheckTimeout,
      hostCheckInterval: hostCheckInterval ?? this.hostCheckInterval,
      alertConfig: alertConfig ?? this.alertConfig,
    );
  }
}

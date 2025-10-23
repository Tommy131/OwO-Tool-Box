/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-18
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-20
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

// lib/services/alert_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/notification_service.dart';
import '../../core/utils/logger.dart';

import '../models/host_monitor_settings_model.dart';
import '../models/system_info_model.dart';

// ==================== 告警类型枚举 ====================
/// 定义系统监控的各种告警类型
enum AlertType {
  cpuHigh, // CPU使用率过高
  memoryHigh, // 内存使用率过高
  diskHigh, // 磁盘使用率过高
  networkUploadHigh, // 上传速率异常
  networkDownloadHigh, // 下载速率异常
  disconnected, // 服务器连接断开
}

// ==================== 告警记录模型 ====================
/// 告警记录数据模型，记录单次告警的详细信息
class AlertRecord {
  final String id; // 唯一标识符
  final AlertType type; // 告警类型
  final String hostName; // 主机名称
  final double value; // 当前值
  final double threshold; // 阈值
  final DateTime timestamp; // 触发时间
  final bool acknowledged; // 是否已确认

  AlertRecord({
    required this.id,
    required this.type,
    required this.hostName,
    required this.value,
    required this.threshold,
    required this.timestamp,
    this.acknowledged = false,
  });

  /// 生成告警消息文本
  String get message {
    switch (type) {
      case AlertType.cpuHigh:
        return 'CPU使用率过高: ${value.toStringAsFixed(1)}% (阈值: ${threshold.toStringAsFixed(0)}%)';
      case AlertType.memoryHigh:
        return '内存使用率过高: ${value.toStringAsFixed(1)}% (阈值: ${threshold.toStringAsFixed(0)}%)';
      case AlertType.diskHigh:
        return '磁盘使用率过高: ${value.toStringAsFixed(1)}% (阈值: ${threshold.toStringAsFixed(0)}%)';
      case AlertType.networkUploadHigh:
        return '上传速率异常: ${_formatSpeed(value)} (阈值: ${_formatSpeed(threshold)})';
      case AlertType.networkDownloadHigh:
        return '下载速率异常: ${_formatSpeed(value)} (阈值: ${_formatSpeed(threshold)})';
      case AlertType.disconnected:
        return '服务器连接断开';
    }
  }

  /// 格式化网络速度显示
  String _formatSpeed(double kbps) {
    if (kbps < 1024) {
      return '${kbps.toStringAsFixed(1)} KB/s';
    } else {
      return '${(kbps / 1024).toStringAsFixed(2)} MB/s';
    }
  }

  /// 序列化为JSON
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

  /// 从JSON反序列化
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

// ==================== 告警管理服务 ====================
/// 告警管理服务，负责告警检测、记录、通知等功能
/// 继承 ChangeNotifier 以支持状态变化通知
class AlertService extends ChangeNotifier {
  // ========== 私有属性 ==========
  final NotificationService _notificationService = NotificationService();
  HostMonitorSettingsModel _settings = const HostMonitorSettingsModel();
  final List<AlertRecord> _alertHistory = [];
  final Map<AlertType, DateTime> _lastAlertTime = {};

  /// 告警冷却时间，防止频繁触发
  static const Duration _alertCooldown = Duration(minutes: 5);

  /// 最大历史记录数
  static const int _maxHistoryCount = 100;

  // ========== 公共属性 ==========
  /// 获取当前告警配置（从主机监控设置中）
  HostMonitorSettingsModel get settings => _settings;

  /// 获取告警历史记录（不可修改的副本）
  List<AlertRecord> get alertHistory => List.unmodifiable(_alertHistory);

  /// 获取未确认告警数量
  int get unacknowledgedCount {
    return _alertHistory.where((a) => !a.acknowledged).length;
  }

  // ========== 初始化方法 ==========
  /// 初始化告警服务
  /// 加载配置和历史记录
  Future<void> initialize() async {
    await _notificationService.initialize();
    await _loadSettings();
    await _loadHistory();

    AppLogger.debug('[AlertService] 初始化完成，加载了 ${_alertHistory.length} 条历史记录');
  }

  // ========== 配置管理 ==========
  /// 加载告警配置（从 SharedPreferences）
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('host_monitor_settings');

      if (jsonString != null) {
        _settings = HostMonitorSettingsModel.fromJson(json.decode(jsonString));
      }
    } catch (e) {
      AppLogger.error('[AlertService] 配置加载失败', e);
    }
  }

  /// 更新告警配置
  /// 注意: 这里只更新内部引用，实际保存由 HostMonitorSettingsModel 负责
  Future<void> updateSettings(HostMonitorSettingsModel settings) async {
    try {
      _settings = settings;

      // 同步保存到 SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'host_monitor_settings', json.encode(settings.toJson()));

      notifyListeners();
    } catch (e) {
      AppLogger.error('[AlertService] 配置更新失败', e);
    }
  }

  // ========== 历史记录管理 ==========
  /// 加载告警历史记录
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('alert_history');

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _alertHistory.clear();
        _alertHistory.addAll(
          jsonList.map((json) => AlertRecord.fromJson(json)).toList(),
        );
        AppLogger.debug('[AlertService] 历史记录加载成功，共 ${_alertHistory.length} 条');
      }
    } catch (e) {
      AppLogger.error('[AlertService] 历史记录加载失败', e);
    }
  }

  /// 保存告警历史记录
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        _alertHistory.map((a) => a.toJson()).toList(),
      );
      await prefs.setString('alert_history', jsonString);
    } catch (e) {
      AppLogger.error('[AlertService] 历史记录保存失败', e);
    }
  }

  /// 清空历史记录
  Future<void> clearHistory() async {
    _alertHistory.clear();
    await _saveHistory();

    AppLogger.debug('[AlertService] 历史记录已清空');
    notifyListeners();
  }

  /// 获取未确认的告警列表
  List<AlertRecord> getUnacknowledgedAlerts() {
    return _alertHistory.where((a) => !a.acknowledged).toList();
  }

  /// 获取已确认的告警列表
  List<AlertRecord> getAcknowledgedAlerts() {
    return _alertHistory.where((a) => a.acknowledged).toList();
  }

  /// 清除已确认的告警
  Future<void> clearAcknowledgedAlerts() async {
    _alertHistory.removeWhere((a) => a.acknowledged);
    await _saveHistory();

    AppLogger.debug('[AlertService] 已确认的告警已清除');
    notifyListeners();
  }

  // ========== 告警检测 ==========
  /// 检查系统指标并触发相应告警
  /// 使用 SystemInfoModel 的新 getter 方法
  Future<void> checkAlerts({
    required SystemInfoModel systemInfo,
    required String hostName,
  }) async {
    // 如果告警功能未启用，直接返回
    if (!_settings.enabledAlert) {
      return;
    }

    // 检查 CPU 使用率（使用 cpuUsagePercent getter）
    if (systemInfo.cpuUsagePercent > _settings.cpuThreshold) {
      await _triggerAlert(
        type: AlertType.cpuHigh,
        hostName: hostName,
        value: systemInfo.cpuUsagePercent,
        threshold: _settings.cpuThreshold,
      );
    }

    // 检查内存使用率（使用 memoryUsagePercent getter）
    if (systemInfo.memoryUsagePercent > _settings.memoryThreshold) {
      await _triggerAlert(
        type: AlertType.memoryHigh,
        hostName: hostName,
        value: systemInfo.memoryUsagePercent,
        threshold: _settings.memoryThreshold,
      );
    }

    // 检查磁盘使用率（使用 diskAvgUsagePercent getter）
    if (systemInfo.diskAvgUsagePercent > _settings.diskThreshold) {
      await _triggerAlert(
        type: AlertType.diskHigh,
        hostName: hostName,
        value: systemInfo.diskAvgUsagePercent,
        threshold: _settings.diskThreshold,
      );
    }

    // 检查网络上传速率（使用 totalUploadSpeed getter，转换为 KB/s）
    final uploadSpeedKB = systemInfo.totalUploadSpeed / 1024;
    if (uploadSpeedKB > _settings.networkUploadThreshold) {
      await _triggerAlert(
        type: AlertType.networkUploadHigh,
        hostName: hostName,
        value: uploadSpeedKB,
        threshold: _settings.networkUploadThreshold,
      );
    }

    // 检查网络下载速率（使用 totalDownloadSpeed getter，转换为 KB/s）
    final downloadSpeedKB = systemInfo.totalDownloadSpeed / 1024;
    if (downloadSpeedKB > _settings.networkDownloadThreshold) {
      await _triggerAlert(
        type: AlertType.networkDownloadHigh,
        hostName: hostName,
        value: downloadSpeedKB,
        threshold: _settings.networkDownloadThreshold,
      );
    }
  }

  /// 通知服务器断开连接
  Future<void> notifyDisconnect(String hostName) async {
    if (!_settings.enabledAlert || !_settings.notifyOnDisconnect) {
      return;
    }

    await _triggerAlert(
      type: AlertType.disconnected,
      hostName: hostName,
      value: 0,
      threshold: 0,
    );
  }

  // ========== 告警触发 ==========
  /// 触发告警并记录
  /// 包含冷却时间检测，防止频繁告警
  Future<void> _triggerAlert({
    required AlertType type,
    required String hostName,
    required double value,
    required double threshold,
  }) async {
    // 检查冷却时间
    final lastTime = _lastAlertTime[type];
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime);
      if (elapsed < _alertCooldown) {
        AppLogger.debug(
            '[AlertService] 告警 $type 处于冷却期，跳过 (剩余 ${_alertCooldown.inMinutes - elapsed.inMinutes} 分钟)');
        return;
      }
    }

    // 创建告警记录
    final alert = AlertRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      hostName: hostName,
      value: value,
      threshold: threshold,
      timestamp: DateTime.now(),
    );

    // 添加到历史记录（最新的在前）
    _alertHistory.insert(0, alert);

    // 限制历史记录数量
    if (_alertHistory.length > _maxHistoryCount) {
      _alertHistory.removeRange(_maxHistoryCount, _alertHistory.length);
      AppLogger.debug('[AlertService] 历史记录已超出限制 ($_maxHistoryCount)，已清理旧记录');
    }

    // 保存历史记录
    await _saveHistory();

    // 发送通知（使用当前设置）
    try {
      await _showAlert(
        alert: alert,
        soundEnabled: _settings.soundEnabled,
        vibrationEnabled: _settings.vibrationEnabled,
      );
      AppLogger.debug('[AlertService] 告警通知已发送: ${alert.message}');
    } catch (e) {
      AppLogger.error('[AlertService] 发送通知失败', e);
    }

    // 更新最后告警时间
    _lastAlertTime[type] = DateTime.now();

    // 通知监听者更新UI
    notifyListeners();
  }

  // ==================== 告警通知方法 ====================
  /// 显示告警通知
  ///
  /// 根据告警类型和配置发送通知
  /// 支持声音、震动等自定义配置
  ///
  /// 参数:
  /// - [alert] 告警记录对象
  /// - [soundEnabled] 是否启用声音（默认 true）
  /// - [vibrationEnabled] 是否启用震动（默认 true）
  Future<void> _showAlert({
    required AlertRecord alert,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
  }) async {
    try {
      final notificationId = alert.id.hashCode;
      final title = _getAlertTitle(alert.type);
      final body = alert.message;
      final payload = json.encode({
        'type': 'alert',
        'alertId': alert.id,
        'alertType': alert.type.toString(),
        'hostName': alert.hostName,
      });

      if (soundEnabled) {
        try {
          // 尝试使用自定义声音
          await _notificationService.showNotificationWithSound(
            id: notificationId,
            title: title,
            body: body,
            soundFile: _getAlertSound(alert.type),
          );
        } catch (e) {
          // 如果自定义声音失败,降级为普通通知
          AppLogger.warning('[AlertService] 自定义声音失败,使用默认通知');
          await _notificationService.showNotification(
            id: notificationId,
            title: title,
            body: body,
            payload: payload,
          );
        }
      } else {
        await _notificationService.showNotification(
          id: notificationId,
          title: title,
          body: body,
          payload: payload,
        );
      }

      AppLogger.debug(
          '[AlertService] 告警通知已发送: ID=$notificationId, Type=${alert.type}');
    } catch (e) {
      AppLogger.error('[AlertService] 发送告警通知失败', e);
      // 不再 rethrow,避免阻断后续流程
    }
  }

  /// 根据告警类型获取通知标题
  ///
  /// 返回用户友好的告警标题
  String _getAlertTitle(AlertType type) {
    switch (type) {
      case AlertType.cpuHigh:
        return '⚠️ CPU 告警';
      case AlertType.memoryHigh:
        return '⚠️ 内存告警';
      case AlertType.diskHigh:
        return '⚠️ 磁盘告警';
      case AlertType.networkUploadHigh:
        return '⚠️ 上传速率告警';
      case AlertType.networkDownloadHigh:
        return '⚠️ 下载速率告警';
      case AlertType.disconnected:
        return '❌ 连接断开';
    }
  }

  /// 根据告警类型获取通知音效文件名
  ///
  /// 返回音频文件名（不含扩展名）
  ///
  /// 注意:
  /// - 需要在 android/app/src/main/res/raw/ 放置对应音频文件
  /// - iOS 需要在 Runner/Resources/ 放置对应音频文件
  String? _getAlertSound(AlertType type) {
    // 可以为不同告警类型配置不同音效
    // 如果不需要自定义音效，返回 null 使用系统默认
    switch (type) {
      case AlertType.disconnected:
        return 'alert_critical'; // 严重告警使用特殊音效
      default:
        return 'alert_default'; // 普通告警使用默认音效
    }
  }

  // ========== 告警确认 ==========
  /// 确认告警记录
  Future<void> acknowledgeAlert(String id) async {
    final index = _alertHistory.indexWhere((a) => a.id == id);

    if (index != -1) {
      final oldAlert = _alertHistory[index];

      // 创建新的已确认记录
      _alertHistory[index] = AlertRecord(
        id: oldAlert.id,
        type: oldAlert.type,
        hostName: oldAlert.hostName,
        value: oldAlert.value,
        threshold: oldAlert.threshold,
        timestamp: oldAlert.timestamp,
        acknowledged: true,
      );

      await _saveHistory();
      AppLogger.debug('[AlertService] 告警已确认: $id');
      notifyListeners();
    } else {
      AppLogger.warning('[AlertService] 未找到告警记录: $id');
    }
  }

  /// 批量确认所有未确认告警
  Future<void> acknowledgeAllAlerts() async {
    int acknowledgedCount = 0;

    for (int i = 0; i < _alertHistory.length; i++) {
      if (!_alertHistory[i].acknowledged) {
        final oldAlert = _alertHistory[i];
        _alertHistory[i] = AlertRecord(
          id: oldAlert.id,
          type: oldAlert.type,
          hostName: oldAlert.hostName,
          value: oldAlert.value,
          threshold: oldAlert.threshold,
          timestamp: oldAlert.timestamp,
          acknowledged: true,
        );
        acknowledgedCount++;
      }
    }

    if (acknowledgedCount > 0) {
      await _saveHistory();
      AppLogger.debug('[AlertService] 已批量确认 $acknowledgedCount 条告警');
      notifyListeners();
    }
  }

  // ========== 资源清理 ==========
  @override
  void dispose() {
    AppLogger.debug('[AlertService] 服务已销毁');
    super.dispose();
  }
}

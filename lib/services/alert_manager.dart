/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-12 23:17:34
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-13 01:10:33
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// lib/services/alert_manager.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alert_config.dart';
import '../models/system_info.dart';
import 'notification_service.dart';

class AlertManager extends ChangeNotifier {
  // 继承 ChangeNotifier
  final NotificationService _notificationService = NotificationService();
  AlertConfig _config = const AlertConfig();
  final List<AlertRecord> _alertHistory = [];
  final Map<AlertType, DateTime> _lastAlertTime = {};
  final Duration _alertCooldown = const Duration(minutes: 5);

  AlertConfig get config => _config;
  List<AlertRecord> get alertHistory => List.unmodifiable(_alertHistory);

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _loadConfig();
    await _loadHistory();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('alert_config');
    if (jsonString != null) {
      _config = AlertConfig.fromJson(json.decode(jsonString));
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('alert_history');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _alertHistory.clear();
      _alertHistory.addAll(
        jsonList.map((json) => AlertRecord.fromJson(json)).toList(),
      );
    }
  }

  Future<void> updateConfig(AlertConfig config) async {
    _config = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alert_config', json.encode(config.toJson()));
    notifyListeners(); // 添加通知
  }

  Future<void> checkAlerts({
    required SystemInfo systemInfo,
    required String hostName,
  }) async {
    if (!_config.enabled) return;

    // 检查 CPU
    if (systemInfo.cpuPercent > _config.cpuThreshold) {
      await _triggerAlert(
        type: AlertType.cpuHigh,
        hostName: hostName,
        value: systemInfo.cpuPercent,
        threshold: _config.cpuThreshold,
      );
    }

    // 检查内存
    if (systemInfo.memoryUsage > _config.memoryThreshold) {
      await _triggerAlert(
        type: AlertType.memoryHigh,
        hostName: hostName,
        value: systemInfo.memoryUsage,
        threshold: _config.memoryThreshold,
      );
    }

    // 检查磁盘
    if (systemInfo.diskUsage > _config.diskThreshold) {
      await _triggerAlert(
        type: AlertType.diskHigh,
        hostName: hostName,
        value: systemInfo.diskUsage,
        threshold: _config.diskThreshold,
      );
    }

    // 检查网络上传
    final uploadSpeedKB = systemInfo.totalUploadSpeed / 1024;
    if (uploadSpeedKB > _config.networkUploadThreshold) {
      await _triggerAlert(
        type: AlertType.networkUploadHigh,
        hostName: hostName,
        value: uploadSpeedKB,
        threshold: _config.networkUploadThreshold,
      );
    }

    // 检查网络下载
    final downloadSpeedKB = systemInfo.totalDownloadSpeed / 1024;
    if (downloadSpeedKB > _config.networkDownloadThreshold) {
      await _triggerAlert(
        type: AlertType.networkDownloadHigh,
        hostName: hostName,
        value: downloadSpeedKB,
        threshold: _config.networkDownloadThreshold,
      );
    }
  }

  Future<void> notifyDisconnect(String hostName) async {
    if (!_config.enabled || !_config.notifyOnDisconnect) return;

    await _triggerAlert(
      type: AlertType.disconnected,
      hostName: hostName,
      value: 0,
      threshold: 0,
    );
  }

  Future<void> _triggerAlert({
    required AlertType type,
    required String hostName,
    required double value,
    required double threshold,
  }) async {
    final lastTime = _lastAlertTime[type];
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime);
      if (elapsed < _alertCooldown) {
        return;
      }
    }

    final alert = AlertRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      hostName: hostName,
      value: value,
      threshold: threshold,
      timestamp: DateTime.now(),
    );

    _alertHistory.insert(0, alert);

    if (_alertHistory.length > 100) {
      _alertHistory.removeRange(100, _alertHistory.length);
    }

    await _saveHistory();

    try {
      await _notificationService.showAlert(alert: alert, config: _config);
    } catch (e) {
      // print('发送通知失败: $e');
    }

    _lastAlertTime[type] = DateTime.now();

    notifyListeners(); // 添加通知 - 更新未读数量
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      _alertHistory.map((a) => a.toJson()).toList(),
    );
    await prefs.setString('alert_history', jsonString);
  }

  Future<void> acknowledgeAlert(String id) async {
    final index = _alertHistory.indexWhere((a) => a.id == id);
    if (index != -1) {
      final oldAlert = _alertHistory[index];
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
      notifyListeners(); // 添加通知 - 更新UI
    }
  }

  Future<void> clearHistory() async {
    _alertHistory.clear();
    await _saveHistory();
    notifyListeners(); // 添加通知
  }

  int get unacknowledgedCount {
    return _alertHistory.where((a) => !a.acknowledged).length;
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/alert_config.dart';
import '../services/windows_notification_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _initializationFailed = false;

  Future<void> initialize() async {
    if (_initialized || _initializationFailed) return;

    try {
      // 仅在支持的平台上初始化
      if (Platform.isAndroid || Platform.isIOS) {
        const androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosSettings = DarwinInitializationSettings();

        const initSettings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );

        final result = await _notifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: _onNotificationTapped,
        );

        _initialized = result ?? false;
      } else {
        // Windows 不使用 flutter_local_notifications
        _initialized = true;
      }
    } catch (e) {
      // print('通知初始化失败: $e');
      _initializationFailed = true;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // print('通知被点击: ${response.payload}');
  }

  Future<void> showAlert({
    required AlertRecord alert,
    required AlertConfig config,
  }) async {
    if (!config.enabled) return;

    // 如果初始化失败，尝试重新初始化
    if (_initializationFailed) {
      await initialize();
      if (_initializationFailed) {
        // print('通知服务不可用，跳过通知');
        return;
      }
    }

    // 确保初始化完成
    if (!_initialized) {
      await initialize();
    }

    if (!_initialized) {
      // print('通知服务未初始化，跳过通知');
      return;
    }

    // 根据平台选择通知方式
    if (Platform.isAndroid) {
      await _showAndroidNotification(alert, config);
    } else if (Platform.isIOS) {
      await _showIOSNotification(alert, config);
    } else if (Platform.isWindows) {
      _showWindowsNotification(alert);
    }
  }

  Future<void> _showAndroidNotification(
      AlertRecord alert, AlertConfig config) async {
    final notificationId = alert.type.index;

    final androidDetails = AndroidNotificationDetails(
      'system_alerts',
      '系统告警',
      channelDescription: '系统资源使用告警通知',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: config.vibrationEnabled,
      playSound: config.soundEnabled,
      color: _getAlertColor(alert.type) != null
          ? Color(_getAlertColor(alert.type)!)
          : null,
      styleInformation: BigTextStyleInformation(
        alert.message,
        contentTitle: '${alert.hostName} - 系统告警',
      ),
    );

    final details = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.show(
        notificationId,
        '${alert.hostName} - 系统告警',
        alert.message,
        details,
        payload: alert.id,
      );
    } catch (e) {
      // print('显示通知失败: $e');
    }
  }

  Future<void> _showIOSNotification(
      AlertRecord alert, AlertConfig config) async {
    final notificationId = alert.type.index;

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: config.soundEnabled,
    );

    final details = NotificationDetails(
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        notificationId,
        '${alert.hostName} - 系统告警',
        alert.message,
        details,
        payload: alert.id,
      );
    } catch (e) {
      // print('显示通知失败: $e');
    }
  }

  void _showWindowsNotification(AlertRecord alert) {
    // 控制台输出
    // print('═══════════════════════════════════════');
    // print('【Windows 系统通知】');
    // print('主机: ${alert.hostName}');
    // print('告警: ${alert.message}');
    // print('时间: ${alert.timestamp}');
    // print('═══════════════════════════════════════');

    // Windows 原生通知（如果实现了）
    try {
      WindowsNotificationService.showNotification(
        '${alert.hostName} - 系统告警',
        alert.message,
      );
    } catch (e) {
      // print('Windows 通知失败: $e');
    }
  }

  int? _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.cpuHigh:
      case AlertType.memoryHigh:
      case AlertType.diskHigh:
        return 0xFFFF5252; // 红色
      case AlertType.networkUploadHigh:
      case AlertType.networkDownloadHigh:
        return 0xFFFF9800; // 橙色
      case AlertType.disconnected:
        return 0xFF9E9E9E; // 灰色
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;

    try {
      await _notifications.cancelAll();
    } catch (e) {
      // print('取消通知失败: $e');
    }
  }

  Future<void> cancel(int id) async {
    if (!_initialized) return;

    try {
      await _notifications.cancel(id);
    } catch (e) {
      // print('取消通知失败: $e');
    }
  }
}

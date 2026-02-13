/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-25 21:40:00
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2026-01-25 21:40:00
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/shutdown_task.dart';
import '../models/power_plan.dart';
import '../services/shutdown_service.dart';
import '../services/power_management_service.dart';
import '../../../core/utils/logger.dart';

/// 系统工具状态管理
class SystemToolsProvider extends ChangeNotifier {
  final ShutdownService _shutdownService = ShutdownService();
  final PowerManagementService _powerService = PowerManagementService();

  // 关机任务相关
  ShutdownTask? _currentTask;
  bool _isSchedulingShutdown = false;
  String? _shutdownError;
  Timer? _countdownTimer;

  // 电源计划相关
  List<PowerPlanModel> _powerPlans = [];
  PowerPlanModel? _currentPowerPlan;
  bool _isLoadingPowerPlans = false;
  bool _isChangingPowerPlan = false;
  String? _powerError;

  // Getters - 关机任务
  ShutdownTask? get currentTask => _currentTask;
  bool get isSchedulingShutdown => _isSchedulingShutdown;
  String? get shutdownError => _shutdownError;
  bool get hasActiveShutdown =>
      _currentTask != null &&
      _currentTask!.status == ShutdownTaskStatus.scheduled;

  // Getters - 电源计划
  List<PowerPlanModel> get powerPlans => _powerPlans;
  PowerPlanModel? get currentPowerPlan => _currentPowerPlan;
  bool get isLoadingPowerPlans => _isLoadingPowerPlans;
  bool get isChangingPowerPlan => _isChangingPowerPlan;
  String? get powerError => _powerError;

  /// 初始化
  Future<void> initialize() async {
    await loadPowerPlans();
    _checkExistingShutdownTask();
  }

  /// 检查是否有现有的关机任务
  void _checkExistingShutdownTask() {
    final task = _shutdownService.activeTask;
    if (task != null && task.status == ShutdownTaskStatus.scheduled) {
      _currentTask = task;
      _startCountdownTimer();
      notifyListeners();
    }
  }

  /// 启动倒计时定时器
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentTask != null) {
        final remaining = _currentTask!.getRemainingSeconds();
        if (remaining != null && remaining <= 0) {
          _countdownTimer?.cancel();
          _currentTask = _currentTask!.copyWith(
            status: ShutdownTaskStatus.completed,
          );
        }
        notifyListeners();
      }
    });
  }

  /// 设置定时关机（使用秒数）
  Future<bool> scheduleShutdownBySeconds(int seconds) async {
    _isSchedulingShutdown = true;
    _shutdownError = null;
    notifyListeners();

    try {
      final task = await _shutdownService.scheduleShutdownBySeconds(seconds);
      _currentTask = task;
      _startCountdownTimer();

      _isSchedulingShutdown = false;
      notifyListeners();

      AppLogger.info('[SystemToolsProvider] Shutdown scheduled successfully');
      return true;
    } catch (e) {
      _shutdownError = e.toString();
      _isSchedulingShutdown = false;
      notifyListeners();

      AppLogger.error('[SystemToolsProvider] Failed to schedule shutdown', e);
      return false;
    }
  }

  /// 设置定时关机（使用具体时间）
  Future<bool> scheduleShutdownByTime(DateTime scheduledTime) async {
    _isSchedulingShutdown = true;
    _shutdownError = null;
    notifyListeners();

    try {
      final task = await _shutdownService.scheduleShutdownByTime(scheduledTime);
      _currentTask = task;
      _startCountdownTimer();

      _isSchedulingShutdown = false;
      notifyListeners();

      AppLogger.info(
        '[SystemToolsProvider] Shutdown scheduled for $scheduledTime',
      );
      return true;
    } catch (e) {
      _shutdownError = e.toString();
      _isSchedulingShutdown = false;
      notifyListeners();

      AppLogger.error('[SystemToolsProvider] Failed to schedule shutdown', e);
      return false;
    }
  }

  /// 取消定时关机
  Future<bool> cancelShutdown() async {
    try {
      final success = await _shutdownService.cancelShutdown();
      if (success) {
        _countdownTimer?.cancel();
        _currentTask = _currentTask?.copyWith(
          status: ShutdownTaskStatus.cancelled,
        );
        _shutdownError = null;
        notifyListeners();

        AppLogger.info('[SystemToolsProvider] Shutdown cancelled successfully');
      }
      return success;
    } catch (e) {
      _shutdownError = e.toString();
      notifyListeners();

      AppLogger.error('[SystemToolsProvider] Failed to cancel shutdown', e);
      return false;
    }
  }

  /// 立即关机
  Future<void> shutdownNow({bool force = false}) async {
    try {
      await _shutdownService.shutdownNow(force: force);
    } catch (e) {
      _shutdownError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 重启系统
  Future<void> restart({int delaySeconds = 0, bool force = false}) async {
    try {
      await _shutdownService.restart(delaySeconds: delaySeconds, force: force);
    } catch (e) {
      _shutdownError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 清除关机任务
  void clearShutdownTask() {
    _currentTask = null;
    _shutdownError = null;
    _countdownTimer?.cancel();
    _shutdownService.clearTask();
    notifyListeners();
  }

  /// 加载所有电源计划
  Future<void> loadPowerPlans() async {
    _isLoadingPowerPlans = true;
    _powerError = null;
    notifyListeners();

    try {
      _powerPlans = await _powerService.getAllPowerPlans();
      _currentPowerPlan = await _powerService.getCurrentPowerPlan();

      _isLoadingPowerPlans = false;
      notifyListeners();

      AppLogger.info(
        '[SystemToolsProvider] Loaded ${_powerPlans.length} power plans',
      );
    } catch (e) {
      _powerError = e.toString();
      _isLoadingPowerPlans = false;
      notifyListeners();

      AppLogger.error('[SystemToolsProvider] Failed to load power plans', e);
    }
  }

  /// 设置电源模式
  Future<bool> setPowerMode(PowerMode mode) async {
    _isChangingPowerPlan = true;
    _powerError = null;
    notifyListeners();

    try {
      final success = await _powerService.setPowerMode(mode);
      if (success) {
        await loadPowerPlans(); // 重新加载以更新当前状态
        AppLogger.info(
          '[SystemToolsProvider] Power mode changed to ${mode.displayName}',
        );
      }

      _isChangingPowerPlan = false;
      notifyListeners();

      return success;
    } catch (e) {
      _powerError = e.toString();
      _isChangingPowerPlan = false;
      notifyListeners();

      AppLogger.error('[SystemToolsProvider] Failed to change power mode', e);
      return false;
    }
  }

  /// 设置电源计划（通过 GUID）
  Future<bool> setPowerPlanByGuid(String guid) async {
    _isChangingPowerPlan = true;
    _powerError = null;
    notifyListeners();

    try {
      final success = await _powerService.setPowerPlanByGuid(guid);
      if (success) {
        await loadPowerPlans();
        AppLogger.info(
          '[SystemToolsProvider] Power plan changed to GUID: $guid',
        );
      }

      _isChangingPowerPlan = false;
      notifyListeners();

      return success;
    } catch (e) {
      _powerError = e.toString();
      _isChangingPowerPlan = false;
      notifyListeners();

      AppLogger.error('[SystemToolsProvider] Failed to change power plan', e);
      return false;
    }
  }

  /// 休眠
  Future<bool> hibernate() async {
    try {
      return await _powerService.hibernate();
    } catch (e) {
      _powerError = e.toString();
      notifyListeners();
      AppLogger.error('[SystemToolsProvider] Failed to hibernate', e);
      return false;
    }
  }

  /// 睡眠
  Future<bool> sleep() async {
    try {
      return await _powerService.sleep();
    } catch (e) {
      _powerError = e.toString();
      notifyListeners();
      AppLogger.error('[SystemToolsProvider] Failed to sleep', e);
      return false;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

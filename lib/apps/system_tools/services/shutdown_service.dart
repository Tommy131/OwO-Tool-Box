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

import 'dart:io';
import '../../../core/utils/logger.dart';
import '../models/shutdown_task.dart';

/// Windows 定时关机服务
class ShutdownService {
  /// 单例模式
  static final ShutdownService _instance = ShutdownService._internal();
  factory ShutdownService() => _instance;
  ShutdownService._internal();

  /// 当前活动的关机任务
  ShutdownTask? _activeTask;

  /// 获取当前活动任务
  ShutdownTask? get activeTask => _activeTask;

  /// 设置定时关机（使用秒数）
  ///
  /// [seconds] 延迟秒数
  /// 返回创建的任务
  Future<ShutdownTask> scheduleShutdownBySeconds(int seconds) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    if (seconds <= 0) {
      throw ArgumentError('Seconds must be greater than 0');
    }

    // 取消现有任务
    if (_activeTask != null &&
        _activeTask!.status == ShutdownTaskStatus.scheduled) {
      await cancelShutdown();
    }

    // 创建新任务
    _activeTask = ShutdownTask.create(delaySeconds: seconds);
    _activeTask = _activeTask!.copyWith(status: ShutdownTaskStatus.scheduled);

    try {
      // 执行 shutdown 命令
      // shutdown -s: 关机
      // -t: 设置延迟时间（秒）
      final result = await Process.run('shutdown', [
        '-s',
        '-t',
        seconds.toString(),
      ], runInShell: true);

      if (result.exitCode == 0) {
        AppLogger.info(
          '[ShutdownService] Shutdown scheduled for $seconds seconds',
        );
        return _activeTask!;
      } else {
        final error = result.stderr.toString();
        AppLogger.error('[ShutdownService] Failed to schedule shutdown', error);
        _activeTask = _activeTask!.copyWith(
          status: ShutdownTaskStatus.failed,
          errorMessage: error,
        );
        throw Exception('Failed to schedule shutdown: $error');
      }
    } catch (e) {
      AppLogger.error('[ShutdownService] Error scheduling shutdown', e);
      _activeTask = _activeTask!.copyWith(
        status: ShutdownTaskStatus.failed,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// 设置定时关机（使用具体时间）
  ///
  /// [scheduledTime] 计划关机时间
  /// 返回创建的任务
  Future<ShutdownTask> scheduleShutdownByTime(DateTime scheduledTime) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) {
      throw ArgumentError('Scheduled time must be in the future');
    }

    // 计算延迟秒数
    final delaySeconds = scheduledTime.difference(now).inSeconds;

    // 创建任务
    final task = await scheduleShutdownBySeconds(delaySeconds);
    _activeTask = task.copyWith(scheduledTime: scheduledTime);

    return _activeTask!;
  }

  /// 取消定时关机
  ///
  /// 返回是否成功取消
  Future<bool> cancelShutdown() async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    if (_activeTask == null ||
        _activeTask!.status != ShutdownTaskStatus.scheduled) {
      AppLogger.warning('[ShutdownService] No active shutdown task to cancel');
      return false;
    }

    try {
      // 执行 shutdown -a 命令取消关机
      final result = await Process.run('shutdown', ['-a'], runInShell: true);

      if (result.exitCode == 0) {
        AppLogger.info('[ShutdownService] Shutdown cancelled successfully');
        _activeTask = _activeTask!.copyWith(
          status: ShutdownTaskStatus.cancelled,
        );
        return true;
      } else {
        final error = result.stderr.toString();
        AppLogger.error('[ShutdownService] Failed to cancel shutdown', error);
        return false;
      }
    } catch (e) {
      AppLogger.error('[ShutdownService] Error cancelling shutdown', e);
      return false;
    }
  }

  /// 立即关机
  ///
  /// [force] 是否强制关机
  Future<void> shutdownNow({bool force = false}) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    try {
      final args = ['-s', '-t', '0'];
      if (force) {
        args.add('-f'); // 强制关闭应用程序
      }

      final result = await Process.run('shutdown', args, runInShell: true);

      if (result.exitCode == 0) {
        AppLogger.info('[ShutdownService] Immediate shutdown initiated');
      } else {
        final error = result.stderr.toString();
        AppLogger.error('[ShutdownService] Failed to shutdown', error);
        throw Exception('Failed to shutdown: $error');
      }
    } catch (e) {
      AppLogger.error('[ShutdownService] Error during shutdown', e);
      rethrow;
    }
  }

  /// 重启系统
  ///
  /// [delaySeconds] 延迟秒数（0表示立即重启）
  /// [force] 是否强制重启
  Future<void> restart({int delaySeconds = 0, bool force = false}) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    try {
      final args = ['-r', '-t', delaySeconds.toString()];
      if (force) {
        args.add('-f');
      }

      final result = await Process.run('shutdown', args, runInShell: true);

      if (result.exitCode == 0) {
        AppLogger.info(
          '[ShutdownService] Restart scheduled for $delaySeconds seconds',
        );
      } else {
        final error = result.stderr.toString();
        AppLogger.error('[ShutdownService] Failed to restart', error);
        throw Exception('Failed to restart: $error');
      }
    } catch (e) {
      AppLogger.error('[ShutdownService] Error during restart', e);
      rethrow;
    }
  }

  /// 检查是否有活动的关机任务
  bool hasActiveTask() {
    return _activeTask != null &&
        _activeTask!.status == ShutdownTaskStatus.scheduled;
  }

  /// 清除任务记录
  void clearTask() {
    _activeTask = null;
  }
}

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
import '../models/power_plan.dart';

/// Windows 电源管理服务
class PowerManagementService {
  /// 单例模式
  static final PowerManagementService _instance =
      PowerManagementService._internal();
  factory PowerManagementService() => _instance;
  PowerManagementService._internal();

  /// 获取当前电源计划
  Future<PowerPlanModel?> getCurrentPowerPlan() async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    try {
      // 使用 powercfg 命令获取当前活动的电源计划
      final result = await Process.run('powercfg', [
        '/getactivescheme',
      ], runInShell: true);

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        AppLogger.debug('[PowerManagementService] Current power plan: $output');

        // 解析输出，格式类似：
        // Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
        final guidMatch = RegExp(
          r'([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})',
        ).firstMatch(output);
        final nameMatch = RegExp(r'\((.*?)\)').firstMatch(output);

        if (guidMatch != null) {
          final guid = guidMatch.group(1)!;
          final name = nameMatch?.group(1) ?? 'Unknown';

          // 识别电源模式
          PowerMode? mode;
          for (final powerMode in PowerMode.values) {
            if (powerMode.guid.toLowerCase() == guid.toLowerCase()) {
              mode = powerMode;
              break;
            }
          }

          return PowerPlanModel(
            guid: guid,
            name: name,
            description: mode?.description ?? '',
            isActive: true,
            mode: mode,
          );
        }
      } else {
        AppLogger.error(
          '[PowerManagementService] Failed to get power plan',
          result.stderr,
        );
      }
    } catch (e) {
      AppLogger.error('[PowerManagementService] Error getting power plan', e);
    }

    return null;
  }

  /// 获取所有可用的电源计划
  Future<List<PowerPlanModel>> getAllPowerPlans() async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    final plans = <PowerPlanModel>[];

    try {
      // 使用 powercfg 命令列出所有电源计划
      final result = await Process.run('powercfg', ['/list'], runInShell: true);

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');

        // 获取当前活动的电源计划
        final currentPlan = await getCurrentPowerPlan();
        final currentGuid = currentPlan?.guid.toLowerCase();

        for (final line in lines) {
          // 解析格式：Power Scheme GUID: {guid} (Name) *
          final match = RegExp(
            r'([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})\s+\((.*?)\)(.*)',
          ).firstMatch(line);

          if (match != null) {
            final guid = match.group(1)!;
            final name = match.group(2)!;
            final isActive =
                match.group(3)?.contains('*') ??
                false || guid.toLowerCase() == currentGuid;

            // 识别电源模式
            PowerMode? mode;
            for (final powerMode in PowerMode.values) {
              if (powerMode.guid.toLowerCase() == guid.toLowerCase()) {
                mode = powerMode;
                break;
              }
            }

            plans.add(
              PowerPlanModel(
                guid: guid,
                name: name,
                description: mode?.description ?? '',
                isActive: isActive,
                mode: mode,
              ),
            );
          }
        }

        AppLogger.debug(
          '[PowerManagementService] Found ${plans.length} power plans',
        );
      } else {
        AppLogger.error(
          '[PowerManagementService] Failed to list power plans',
          result.stderr,
        );
      }
    } catch (e) {
      AppLogger.error('[PowerManagementService] Error listing power plans', e);
    }

    return plans;
  }

  /// 设置电源计划（使用 PowerMode）
  ///
  /// [mode] 要设置的电源模式
  /// 返回是否成功
  Future<bool> setPowerMode(PowerMode mode) async {
    return await setPowerPlanByGuid(mode.guid);
  }

  /// 设置电源计划（使用 GUID）
  ///
  /// [guid] 电源计划的 GUID
  /// 返回是否成功
  Future<bool> setPowerPlanByGuid(String guid) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    try {
      // 使用 powercfg 命令设置活动电源计划
      final result = await Process.run('powercfg', [
        '/setactive',
        guid,
      ], runInShell: true);

      if (result.exitCode == 0) {
        AppLogger.info(
          '[PowerManagementService] Power plan set to GUID: $guid',
        );
        return true;
      } else {
        final error = result.stderr.toString();
        AppLogger.error(
          '[PowerManagementService] Failed to set power plan',
          error,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('[PowerManagementService] Error setting power plan', e);
      return false;
    }
  }

  /// 获取电源计划的详细信息
  ///
  /// [guid] 电源计划的 GUID
  Future<Map<String, dynamic>?> getPowerPlanDetails(String guid) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    try {
      final result = await Process.run('powercfg', [
        '/query',
        guid,
      ], runInShell: true);

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        AppLogger.debug('[PowerManagementService] Power plan details: $output');

        // 这里可以根据需要解析更详细的信息
        return {'guid': guid, 'details': output};
      } else {
        AppLogger.error(
          '[PowerManagementService] Failed to query power plan',
          result.stderr,
        );
      }
    } catch (e) {
      AppLogger.error('[PowerManagementService] Error querying power plan', e);
    }

    return null;
  }

  /// 休眠
  Future<bool> hibernate() async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    try {
      final result = await Process.run('shutdown', ['/h'], runInShell: true);

      if (result.exitCode == 0) {
        AppLogger.info('[PowerManagementService] Hibernate initiated');
        return true;
      } else {
        AppLogger.error(
          '[PowerManagementService] Failed to hibernate',
          result.stderr,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('[PowerManagementService] Error during hibernate', e);
      return false;
    }
  }

  /// 睡眠
  Future<bool> sleep() async {
    if (!Platform.isWindows) {
      throw UnsupportedError('This feature is only available on Windows');
    }

    try {
      // Windows 没有直接的睡眠命令，使用 rundll32 调用
      final result = await Process.run('rundll32.exe', [
        'powrprof.dll,SetSuspendState',
        '0,1,0',
      ], runInShell: true);

      if (result.exitCode == 0) {
        AppLogger.info('[PowerManagementService] Sleep initiated');
        return true;
      } else {
        AppLogger.error(
          '[PowerManagementService] Failed to sleep',
          result.stderr,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('[PowerManagementService] Error during sleep', e);
      return false;
    }
  }
}

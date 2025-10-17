/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-12 19:07:55
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-18 15:30:00
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'dart:convert';
import 'package:owo_system_tools/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../my_models/host_model.dart';
import '../my_models/host_monitor_settings_model.dart';

/// 存储服务类 - 统一管理主机配置和应用设置的持久化存储
///
/// 功能特性:
/// - 主机列表的 CRUD 操作
/// - 应用设置的读写管理
/// - 配置项的单独操作方法
/// - 完整的错误处理和日志记录
class StorageService {
  // ==================== 常量定义 ====================

  /// 主机列表存储键
  static const String _hostsKey = 'saved_hosts';

  /// 应用设置存储键
  static const String _settingsKey = 'host_monitor_settings';

  // ==================== 私有属性 ====================

  /// SharedPreferences 实例
  final SharedPreferences _prefs;

  /// 设置缓存，避免频繁读取存储
  HostMonitorSettingsModel? _settingsCache;

  // ==================== 构造函数 ====================

  /// 私有构造函数
  StorageService(this._prefs);

  /// 工厂方法 - 创建 StorageService 实例
  ///
  /// 返回值: Future<StorageService> - 初始化完成的服务实例
  static Future<StorageService> create() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return StorageService(prefs);
    } catch (e) {
      AppLogger.debug('StorageService: 初始化失败 - $e');
      rethrow;
    }
  }

  // ==================== 主机配置管理 ====================

  /// 获取所有主机配置列表
  ///
  /// 返回值: Future<List<HostModel>> - 主机配置列表，失败返回空列表
  Future<List<HostModel>> getHosts() async {
    try {
      final jsonString = _prefs.getString(_hostsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final dynamic jsonData = json.decode(jsonString);

      if (jsonData is! List) {
        AppLogger.debug('主机数据格式错误，已清空');
        await _prefs.remove(_hostsKey);
        return [];
      }

      final hosts = jsonData
          .map((item) {
            try {
              return HostModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              AppLogger.debug('解析主机配置失败: $e');
              return null;
            }
          })
          .where((host) => host != null)
          .cast<HostModel>()
          .toList();

      return hosts;
    } catch (e) {
      AppLogger.debug('读取主机列表失败: $e');
      await _prefs.remove(_hostsKey);
      return [];
    }
  }

  /// 保存主机配置列表
  ///
  /// 参数:
  /// - hosts: 要保存的主机列表
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> saveHosts(List<HostModel> hosts) async {
    try {
      final jsonString = json.encode(hosts.map((h) => h.toJson()).toList());
      return await _prefs.setString(_hostsKey, jsonString);
    } catch (e) {
      AppLogger.debug('保存主机列表失败: $e');
      return false;
    }
  }

  /// 添加或更新主机配置
  ///
  /// 如果主机 ID 已存在则更新，否则添加新主机
  ///
  /// 参数:
  /// - host: 要添加或更新的主机配置
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> addHost(HostModel host) async {
    try {
      final hosts = await getHosts();
      final existingIndex = hosts.indexWhere((h) => h.id == host.id);

      if (existingIndex != -1) {
        hosts[existingIndex] = host;
      } else {
        hosts.add(host);
      }

      return await saveHosts(hosts);
    } catch (e) {
      AppLogger.debug('添加主机失败: $e');
      return false;
    }
  }

  /// 更新指定主机配置
  ///
  /// 参数:
  /// - host: 要更新的主机配置
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> updateHost(HostModel host) async {
    try {
      final hosts = await getHosts();
      final index = hosts.indexWhere((h) => h.id == host.id);

      if (index != -1) {
        hosts[index] = host;
        return await saveHosts(hosts);
      }

      return false;
    } catch (e) {
      AppLogger.debug('更新主机失败: $e');
      return false;
    }
  }

  /// 删除指定主机配置
  ///
  /// 参数:
  /// - id: 要删除的主机 ID
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> deleteHost(String id) async {
    try {
      final hosts = await getHosts();
      final initialLength = hosts.length;
      hosts.removeWhere((h) => h.id == id);

      if (hosts.length < initialLength) {
        return await saveHosts(hosts);
      }

      return false;
    } catch (e) {
      AppLogger.debug('删除主机失败: $e');
      return false;
    }
  }

  /// 根据 ID 获取单个主机配置
  ///
  /// 参数:
  /// - id: 主机 ID
  ///
  /// 返回值: Future<HostModel?> - 主机配置，未找到返回 null
  Future<HostModel?> getHostById(String id) async {
    try {
      final hosts = await getHosts();
      return hosts.where((h) => h.id == id).firstOrNull;
    } catch (e) {
      AppLogger.debug('查询主机失败: $e');
      return null;
    }
  }

  /// 清空所有主机配置
  ///
  /// 注意: 此操作不可恢复，建议仅用于调试或重置场景
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> clearAllHosts() async {
    try {
      return await _prefs.remove(_hostsKey);
    } catch (e) {
      AppLogger.debug('清空主机列表失败: $e');
      return false;
    }
  }

  // ==================== 应用设置管理 ====================

  /// 获取应用设置
  ///
  /// 优先返回缓存，缓存不存在时从存储读取
  ///
  /// 返回值: Future<HostMonitorSettingsModel> - 设置对象，失败返回默认设置
  Future<HostMonitorSettingsModel> getSettings() async {
    if (_settingsCache != null) {
      return _settingsCache!;
    }

    try {
      final jsonString = _prefs.getString(_settingsKey);

      if (jsonString == null || jsonString.isEmpty) {
        _settingsCache = const HostMonitorSettingsModel();
        return _settingsCache!;
      }

      final jsonData = json.decode(jsonString);
      _settingsCache =
          HostMonitorSettingsModel.fromJson(jsonData as Map<String, dynamic>);

      return _settingsCache!;
    } catch (e) {
      AppLogger.debug('读取设置失败: $e');
      await _prefs.remove(_settingsKey);
      _settingsCache = const HostMonitorSettingsModel();
      return _settingsCache!;
    }
  }

  /// 保存应用设置
  ///
  /// 参数:
  /// - settings: 要保存的设置对象
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> saveSettings(HostMonitorSettingsModel settings) async {
    try {
      final jsonString = json.encode(settings.toJson());
      final result = await _prefs.setString(_settingsKey, jsonString);

      if (result) {
        _settingsCache = settings;
      }

      return result;
    } catch (e) {
      AppLogger.debug('保存设置失败: $e');
      return false;
    }
  }

  /// 创建新的默认设置
  ///
  /// 可选参数允许自定义默认值
  ///
  /// 参数:
  /// - refreshInterval: 刷新间隔(秒)，默认 1
  /// - chartDataPoints: 图表数据点数量，默认 60
  /// - hostCheckTimeout: 主机检测超时时间(秒)，默认 10
  /// - hostCheckInterval: 主机检测间隔(分钟)，默认 5
  ///
  /// 返回值: Future<HostMonitorSettingsModel> - 新创建的设置对象
  Future<HostMonitorSettingsModel> newSettings({
    int refreshInterval = 1,
    int chartDataPoints = 60,
    int hostCheckTimeout = 10,
    int hostCheckInterval = 5,
  }) async {
    try {
      final newSettings = HostMonitorSettingsModel(
        refreshInterval: refreshInterval,
        chartDataPoints: chartDataPoints,
        hostCheckTimeout: hostCheckTimeout,
        hostCheckInterval: hostCheckInterval,
      );

      await saveSettings(newSettings);
      return newSettings;
    } catch (e) {
      AppLogger.debug('创建设置失败: $e');
      return const HostMonitorSettingsModel();
    }
  }

  /// 重置设置为默认值
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> resetSettings() async {
    try {
      const defaultSettings = HostMonitorSettingsModel();
      return await saveSettings(defaultSettings);
    } catch (e) {
      AppLogger.debug('重置设置失败: $e');
      return false;
    }
  }

  /// 更新刷新间隔
  ///
  /// 参数:
  /// - interval: 新的刷新间隔(秒)
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> updateRefreshInterval(int interval) async {
    try {
      final settings = await getSettings();
      final updatedSettings = HostMonitorSettingsModel(
        refreshInterval: interval,
        chartDataPoints: settings.chartDataPoints,
        hostCheckTimeout: settings.hostCheckTimeout,
        hostCheckInterval: settings.hostCheckInterval,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      AppLogger.debug('更新刷新间隔失败: $e');
      return false;
    }
  }

  /// 更新图表数据点数量
  ///
  /// 参数:
  /// - dataPoints: 新的数据点数量
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> updateChartDataPoints(int dataPoints) async {
    try {
      final settings = await getSettings();
      final updatedSettings = HostMonitorSettingsModel(
        refreshInterval: settings.refreshInterval,
        chartDataPoints: dataPoints,
        hostCheckTimeout: settings.hostCheckTimeout,
        hostCheckInterval: settings.hostCheckInterval,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      AppLogger.debug('更新图表数据点失败: $e');
      return false;
    }
  }

  /// 更新主机检测超时时间
  ///
  /// 参数:
  /// - timeout: 新的超时时间(秒)
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> updateHostCheckTimeout(int timeout) async {
    try {
      final settings = await getSettings();
      final updatedSettings = HostMonitorSettingsModel(
        refreshInterval: settings.refreshInterval,
        chartDataPoints: settings.chartDataPoints,
        hostCheckTimeout: timeout,
        hostCheckInterval: settings.hostCheckInterval,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      AppLogger.debug('更新检测超时失败: $e');
      return false;
    }
  }

  /// 更新主机检测间隔
  ///
  /// 参数:
  /// - interval: 新的检测间隔(分钟)
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> updateHostCheckInterval(int interval) async {
    try {
      final settings = await getSettings();
      final updatedSettings = HostMonitorSettingsModel(
        refreshInterval: settings.refreshInterval,
        chartDataPoints: settings.chartDataPoints,
        hostCheckTimeout: settings.hostCheckTimeout,
        hostCheckInterval: interval,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      AppLogger.debug('更新检测间隔失败: $e');
      return false;
    }
  }

  /// 批量更新设置
  ///
  /// 参数:
  /// - refreshInterval: 刷新间隔(秒)，null 表示不更新
  /// - chartDataPoints: 图表数据点数量，null 表示不更新
  /// - hostCheckTimeout: 检测超时时间(秒)，null 表示不更新
  /// - hostCheckInterval: 检测间隔(分钟)，null 表示不更新
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> updateSettingsBatch({
    int? refreshInterval,
    int? chartDataPoints,
    int? hostCheckTimeout,
    int? hostCheckInterval,
  }) async {
    try {
      final settings = await getSettings();
      final updatedSettings = HostMonitorSettingsModel(
        refreshInterval: refreshInterval ?? settings.refreshInterval,
        chartDataPoints: chartDataPoints ?? settings.chartDataPoints,
        hostCheckTimeout: hostCheckTimeout ?? settings.hostCheckTimeout,
        hostCheckInterval: hostCheckInterval ?? settings.hostCheckInterval,
      );

      return await saveSettings(updatedSettings);
    } catch (e) {
      AppLogger.debug('批量更新设置失败: $e');
      return false;
    }
  }

  /// 清空所有设置
  ///
  /// 注意: 此操作不可恢复，建议仅用于调试或重置场景
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> clearAllSettings() async {
    try {
      _settingsCache = null;
      return await _prefs.remove(_settingsKey);
    } catch (e) {
      AppLogger.debug('清空设置失败: $e');
      return false;
    }
  }

  /// 清除设置缓存
  ///
  /// 用于强制下次 getSettings 时重新从存储读取
  void clearSettingsCache() {
    _settingsCache = null;
  }

  // ==================== 通用管理 ====================

  /// 完全重置所有数据
  ///
  /// 清空主机列表和应用设置
  ///
  /// 注意: 此操作不可恢复，建议仅用于调试或重置场景
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> clearAll() async {
    try {
      final hostsResult = await clearAllHosts();
      final settingsResult = await clearAllSettings();
      return hostsResult && settingsResult;
    } catch (e) {
      AppLogger.debug('清空所有数据失败: $e');
      return false;
    }
  }

  /// 导出所有数据为 JSON 字符串
  ///
  /// 用于数据备份或迁移
  ///
  /// 返回值: Future<String?> - JSON 字符串，失败返回 null
  Future<String?> exportAllData() async {
    try {
      final hosts = await getHosts();
      final settings = await getSettings();

      final exportData = {
        'hosts': hosts.map((h) => h.toJson()).toList(),
        'settings': settings.toJson(),
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      return json.encode(exportData);
    } catch (e) {
      AppLogger.debug('导出数据失败: $e');
      return null;
    }
  }

  /// 从 JSON 字符串导入数据
  ///
  /// 用于数据恢复或迁移
  ///
  /// 参数:
  /// - jsonString: 导出的 JSON 字符串
  /// - overwrite: 是否覆盖现有数据，默认 false (合并模式)
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> importAllData(String jsonString,
      {bool overwrite = false}) async {
    try {
      final importData = json.decode(jsonString) as Map<String, dynamic>;

      // 导入设置
      if (importData.containsKey('settings')) {
        final settings = HostMonitorSettingsModel.fromJson(
            importData['settings'] as Map<String, dynamic>);
        await saveSettings(settings);
      }

      // 导入主机列表
      if (importData.containsKey('hosts')) {
        final importHosts = (importData['hosts'] as List)
            .map((item) => HostModel.fromJson(item as Map<String, dynamic>))
            .toList();

        if (overwrite) {
          await saveHosts(importHosts);
        } else {
          final existingHosts = await getHosts();
          final existingIds = existingHosts.map((h) => h.id).toSet();
          final newHosts =
              importHosts.where((h) => !existingIds.contains(h.id)).toList();
          final mergedHosts = [...existingHosts, ...newHosts];
          await saveHosts(mergedHosts);
        }
      }

      return true;
    } catch (e) {
      AppLogger.debug('导入数据失败: $e');
      return false;
    }
  }

  /// 获取存储统计信息
  ///
  /// 返回值: Future<Map<String, dynamic>> - 统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final hosts = await getHosts();
      final settings = await getSettings();
      final hostsJson = json.encode(hosts.map((h) => h.toJson()).toList());
      final settingsJson = json.encode(settings.toJson());

      return {
        'hostsCount': hosts.length,
        'hostsDataSize': hostsJson.length,
        'settingsDataSize': settingsJson.length,
        'totalDataSize': hostsJson.length + settingsJson.length,
        'settingsInfo': {
          'refreshInterval': settings.refreshInterval,
          'chartDataPoints': settings.chartDataPoints,
          'hostCheckTimeout': settings.hostCheckTimeout,
          'hostCheckInterval': settings.hostCheckInterval,
        },
        'lastUpdate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppLogger.debug('获取存储统计失败: $e');
      return {};
    }
  }

  /// 验证存储数据完整性
  ///
  /// 检查存储的数据是否可以正确解析
  ///
  /// 返回值: Future<Map<String, bool>> - 验证结果
  Future<Map<String, bool>> validateStorageIntegrity() async {
    final result = {
      'hostsValid': false,
      'settingsValid': false,
    };

    try {
      await getHosts();
      result['hostsValid'] = true;
    } catch (e) {
      AppLogger.debug('主机数据验证失败: $e');
    }

    try {
      await getSettings();
      result['settingsValid'] = true;
    } catch (e) {
      AppLogger.debug('设置数据验证失败: $e');
    }

    return result;
  }

  /// 修复损坏的存储数据
  ///
  /// 尝试清除损坏的数据并恢复默认值
  ///
  /// 返回值: Future<bool> - 操作是否成功
  Future<bool> repairStorageData() async {
    try {
      final validation = await validateStorageIntegrity();

      if (!validation['hostsValid']!) {
        await _prefs.remove(_hostsKey);
      }

      if (!validation['settingsValid']!) {
        await resetSettings();
      }

      return true;
    } catch (e) {
      AppLogger.debug('修复存储数据失败: $e');
      return false;
    }
  }
}

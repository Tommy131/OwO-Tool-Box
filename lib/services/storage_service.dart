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
 * @LastEditTime : 2025-10-13 01:11:18
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/host_config.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _hostsKey = 'saved_hosts';
  static const String _settingsKey = 'app_settings';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // 主机配置管理
  Future<List<HostConfig>> getHosts() async {
    try {
      final jsonString = _prefs.getString(_hostsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final dynamic jsonData = json.decode(jsonString);

      // 确保是列表类型
      if (jsonData is! List) {
        // print('警告: 存储的主机数据格式不正确，已清空');
        await _prefs.remove(_hostsKey);
        return [];
      }

      return jsonData
          .map((item) {
            try {
              return HostConfig.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              // print('解析主机配置失败: $e');
              return null;
            }
          })
          .where((host) => host != null)
          .cast<HostConfig>()
          .toList();
    } catch (e) {
      // print('读取主机列表失败: $e');
      // 清除损坏的数据
      await _prefs.remove(_hostsKey);
      return [];
    }
  }

  Future<bool> saveHosts(List<HostConfig> hosts) async {
    try {
      final jsonString = json.encode(hosts.map((h) => h.toJson()).toList());
      return await _prefs.setString(_hostsKey, jsonString);
    } catch (e) {
      // print('保存主机列表失败: $e');
      return false;
    }
  }

  Future<bool> addHost(HostConfig host) async {
    try {
      final hosts = await getHosts();

      // 检查是否已存在相同ID的主机
      final existingIndex = hosts.indexWhere((h) => h.id == host.id);
      if (existingIndex != -1) {
        hosts[existingIndex] = host;
      } else {
        hosts.add(host);
      }

      return await saveHosts(hosts);
    } catch (e) {
      // print('添加主机失败: $e');
      return false;
    }
  }

  Future<bool> updateHost(HostConfig host) async {
    try {
      final hosts = await getHosts();
      final index = hosts.indexWhere((h) => h.id == host.id);

      if (index != -1) {
        hosts[index] = host;
        return await saveHosts(hosts);
      }

      // print('未找到要更新的主机: ${host.id}');
      return false;
    } catch (e) {
      // print('更新主机失败: $e');
      return false;
    }
  }

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
      // print('删除主机失败: $e');
      return false;
    }
  }

  // 清空所有主机（调试用）
  Future<bool> clearAllHosts() async {
    try {
      return await _prefs.remove(_hostsKey);
    } catch (e) {
      // print('清空主机列表失败: $e');
      return false;
    }
  }

  // 应用设置管理
  Future<AppSettings> getSettings() async {
    try {
      final jsonString = _prefs.getString(_settingsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return const AppSettings();
      }

      final jsonData = json.decode(jsonString);
      return AppSettings.fromJson(jsonData as Map<String, dynamic>);
    } catch (e) {
      // print('读取设置失败: $e');
      // 清除损坏的数据
      await _prefs.remove(_settingsKey);
      return const AppSettings();
    }
  }

  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final jsonString = json.encode(settings.toJson());
      return await _prefs.setString(_settingsKey, jsonString);
    } catch (e) {
      // print('保存设置失败: $e');
      return false;
    }
  }

  // 清空所有设置（调试用）
  Future<bool> clearAllSettings() async {
    try {
      return await _prefs.remove(_settingsKey);
    } catch (e) {
      // print('清空设置失败: $e');
      return false;
    }
  }

  // 完全重置（调试用）
  Future<bool> clearAll() async {
    try {
      await clearAllHosts();
      await clearAllSettings();
      return true;
    } catch (e) {
      // print('清空所有数据失败: $e');
      return false;
    }
  }
}

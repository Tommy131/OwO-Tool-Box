/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-30
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cloudflare_config.dart';

class CloudflareStorageService {
  static const String _configKey = 'cf_api_config';
  static const String _ddnsKeyPrefix = 'cf_ddns_configs';

  static Future<CloudflareConfig?> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_configKey);
    if (jsonString == null) return null;
    return CloudflareConfig.fromJson(json.decode(jsonString));
  }

  static Future<void> saveConfig(CloudflareConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, json.encode(config.toJson()));
  }

  static Future<List<DdnsConfig>> getDdnsConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ddnsKeyPrefix);
    if (jsonString == null) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => DdnsConfig.fromJson(e)).toList();
  }

  static Future<void> saveDdnsConfigs(List<DdnsConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ddnsKeyPrefix,
      json.encode(configs.map((e) => e.toJson()).toList()),
    );
  }
}

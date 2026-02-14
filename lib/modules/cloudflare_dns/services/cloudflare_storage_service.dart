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
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/cloudflare_config.dart';
import '../../../core/services/bootstrap_service.dart';
import '../../../core/services/persistence_service.dart';

class CloudflareStorageService {
  static const String _configFileName = 'config.json';
  static const String _ddnsFileName = 'ddns_configs.json';

  static Future<CloudflareConfig?> getConfig() async {
    final file = await _getConfigFile();
    if (!await file.exists()) return null;
    final jsonString = await file.readAsString();
    if (jsonString.isEmpty) return null;
    return CloudflareConfig.fromJson(json.decode(jsonString));
  }

  static Future<void> saveConfig(CloudflareConfig config) async {
    final file = await _getConfigFile();
    await file.writeAsString(json.encode(config.toJson()));
  }

  static Future<List<DdnsConfig>> getDdnsConfigs() async {
    final file = await _getDdnsFile();
    if (!await file.exists()) return [];
    final jsonString = await file.readAsString();
    if (jsonString.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => DdnsConfig.fromJson(e)).toList();
  }

  static Future<void> saveDdnsConfigs(List<DdnsConfig> configs) async {
    final file = await _getDdnsFile();
    await file.writeAsString(
      json.encode(configs.map((e) => e.toJson()).toList()),
    );
  }

  static Future<File> _getConfigFile() async {
    final dir = await _ensureStorageDir();
    return File(p.join(dir.path, _configFileName));
  }

  static Future<File> _getDdnsFile() async {
    final dir = await _ensureStorageDir();
    return File(p.join(dir.path, _ddnsFileName));
  }

  static Future<Directory> _ensureStorageDir() async {
    final root = await _resolveRootPath();
    final dir = Directory(p.join(root, 'cloudflare_dns'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<String> _resolveRootPath() async {
    final persistence = PersistenceService();
    if (!persistence.isInitialized || persistence.rootPath == null) {
      final bootstrap = BootstrapService();
      if (!bootstrap.isInitialized) {
        await bootstrap.init();
      }
      final customPath = bootstrap.getDataPath();
      await persistence.init(customPath: customPath);
    }
    return persistence.rootPath ?? PersistenceService.getAppCacheRootPath();
  }
}

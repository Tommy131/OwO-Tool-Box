/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-22
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/certificate.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

class SSLSettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  AppSettings? _settings;
  bool _isLoading = false;
  String? _error;

  AppSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _settingsService.loadSettings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      await _settingsService.saveSettings(settings);
      _settings = settings;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String> getConfigContent() async {
    return await _settingsService.getConfigContent();
  }

  Future<void> saveConfigContent(String content) async {
    await _settingsService.saveConfigContent(content);
  }

  /// 迁移证书到分类结构（直接基于存储列表）
  Future<Map<String, dynamic>> migrateCertificates() async {
    if (_settings == null) {
      return {'error': 'Settings not loaded'};
    }

    try {
      // 获取当前证书列表
      final storageService = StorageService();
      final certificates = await storageService.loadCertificates();

      if (certificates.isEmpty) {
        return {
          'success': 0,
          'failed': 0,
          'skipped': 0,
          'errors': <String>[],
          'message': 'No certificates to migrate',
        };
      }

      // 转换为 JSON 格式
      final certificatesJson =
          certificates.map((cert) => cert.toJson()).toList();

      // 执行迁移
      final results =
          await _settingsService.migrateCertificatesToOrganizedStructure(
        _settings!.certificatePath,
        certificatesJson,
      );

      // 更新证书存储
      if (results['success'] as int > 0) {
        final updatedCertificates =
            certificatesJson.map((json) => Certificate.fromJson(json)).toList();
        await storageService.saveCertificates(updatedCertificates);
      }

      return results;
    } catch (e) {
      return {
        'error': e.toString(),
        'success': 0,
        'failed': 0,
        'skipped': 0,
      };
    }
  }
}

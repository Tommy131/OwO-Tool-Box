// ============================================================================
// 语言管理Provider
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/language_config.dart';
import '../utils/logger.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  SharedPreferences? _prefs;

  /// 获取当前语言
  /// 如果为null，则使用系统语言
  Locale? get locale => _locale;

  /// 获取支持的语言列表（从LanguageConfig动态获取）
  List<Locale> get supportedLocales => LanguageConfig.supportedLocales;

  LocaleProvider() {
    _loadLocale();
  }

  /// 从本地存储加载语言设置
  Future<void> _loadLocale() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final languageCode = _prefs?.getString('languageCode');

      if (languageCode != null) {
        // 使用保存的语言
        _locale = LanguageConfig.getLocaleFromLanguageCode(languageCode);
        AppLogger.info('语言加载成功: $_locale');
      } else {
        // 首次启动，使用系统语言或默认语言
        _locale = null;
        AppLogger.info('使用系统语言');
      }

      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('加载语言失败', e, stackTrace);
      _locale = const Locale('zh', 'CN'); // 失败时使用默认语言
      notifyListeners();
    }
  }

  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    if (_locale?.languageCode == locale.languageCode) {
      AppLogger.info('语言未改变，跳过设置');
      return;
    }

    try {
      _locale = locale;

      // 保存到本地存储
      await _prefs?.setString('languageCode', locale.languageCode);
      await _prefs?.setString('countryCode', locale.countryCode ?? '');

      // 立即通知监听器
      notifyListeners();

      AppLogger.info('语言切换成功: $locale');
    } catch (e, stackTrace) {
      AppLogger.error('设置语言失败', e, stackTrace);
    }
  }

  /// 重置为系统语言
  Future<void> resetToSystemLocale() async {
    try {
      _locale = null;
      await _prefs?.remove('languageCode');
      await _prefs?.remove('countryCode');
      notifyListeners();
      AppLogger.info('已重置为系统语言');
    } catch (e, stackTrace) {
      AppLogger.error('重置语言失败', e, stackTrace);
    }
  }

  /// 检查是否支持指定语言
  bool isLocaleSupported(Locale locale) {
    return LanguageConfig.supportedLanguages.contains(locale.languageCode);
  }
}

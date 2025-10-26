// ============================================================================
// 语言配置管理
// ============================================================================

import 'package:flutter/material.dart';
import 'languages/es_ES.dart';
import 'languages/fr_FR.dart';
import 'languages/zh_CN.dart';
import 'languages/en_US.dart';
import 'languages/de_DE.dart';
import 'languages/ja_JP.dart';
import 'languages/zh_HK.dart';

class LanguageConfig {
  // 支持的语言列表
  static const List<String> supportedLanguages = [
    'zh',
    'hk',
    'en',
    'de',
    'ja',
    'fr',
    'es',
  ];

  // 支持的Locale列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('zh', 'HK'),
    Locale('en', 'US'),
    Locale('de', 'DE'),
    Locale('ja', 'JP'),
    Locale('fr', 'FR'),
    Locale('es', 'ES'),
  ];

  // 语言显示名称映射
  static const Map<String, String> languageNames = {
    'zh': '简体中文',
    'hk': '繁體中文（香港）',
    'en': 'English',
    'de': 'Deutsch',
    'ja': '日本語',
    'fr': 'Français',
    'es': 'Español',
  };

  // 接收 Locale 對象的翻譯方法
  static Map<String, String> getTranslations(Locale locale) {
    // 處理中文的特殊情況
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'HK') {
        return ZhHK.translations; // 香港繁體
      }
      return ZhCN.translations; // 簡體中文
    }

    // 其他語言
    switch (locale.languageCode) {
      case 'en':
        return EnUS.translations;
      case 'de':
        return DeDE.translations;
      case 'ja':
        return JaJP.translations;
      case 'fr':
        return FrFR.translations;
      case 'es':
        return EsES.translations;
      default:
        return ZhCN.translations;
    }
  }

  // 保留舊方法以兼容其他可能的調用
  static Map<String, String> getTranslationsByCode(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return ZhCN.translations;
      case 'hk':
        return ZhHK.translations;
      case 'en':
        return EnUS.translations;
      case 'de':
        return DeDE.translations;
      case 'ja':
        return JaJP.translations;
      case 'fr':
        return FrFR.translations;
      case 'es':
        return EsES.translations;
      default:
        return ZhCN.translations;
    }
  }

  // 從語言代碼獲取Locale（保留舊方法）
  static Locale getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return const Locale('zh', 'CN');
      case 'hk':
        return const Locale('zh', 'HK');
      case 'en':
        return const Locale('en', 'US');
      case 'de':
        return const Locale('de', 'DE');
      case 'ja':
        return const Locale('ja', 'JP');
      case 'fr':
        return const Locale('fr', 'FR');
      case 'es':
        return const Locale('es', 'ES');
      default:
        return const Locale('zh', 'CN');
    }
  }

  // 從 Locale 獲取語言代碼
  static String getLanguageCodeFromLocale(Locale locale) {
    // 處理中文的特殊情況
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'HK') {
        return 'hk'; // 香港繁體
      }
      return 'zh'; // 簡體中文
    }

    // 其他語言直接返回 languageCode
    return locale.languageCode;
  }

  // 接收 Locale 對象獲取語言顯示名稱
  static String getLanguageName(Locale locale) {
    final languageCode = getLanguageCodeFromLocale(locale);
    return languageNames[languageCode] ?? languageCode;
  }

  // 获取语言的本地化显示名称（用于语言选择器）
  static String getLocalizedLanguageName(String languageCode) {
    final translations = getTranslationsByCode(languageCode);
    switch (languageCode) {
      case 'zh':
        return translations['chinese'] ?? '简体中文';
      case 'hk':
        return translations['chinese'] ?? '繁體中文（香港）';
      case 'en':
        return translations['english'] ?? 'English';
      case 'de':
        return 'Deutsch';
      case 'ja':
        return '日本語';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      default:
        return languageCode;
    }
  }

  // 语言旗帜映射
  static const Map<String, String> languageFlags = {
    'zh': '🇨🇳',
    'hk': '🇭🇰',
    'en': '🇺🇸',
    'de': '🇩🇪',
    'ja': '🇯🇵',
    'fr': '🇫🇷',
    'es': '🇪🇸',
    'ru': '🇷🇺',
    'ko': '🇰🇷',
    'it': '🇮🇹',
    'pt': '🇵🇹',
    'ar': '🇸🇦',
    'hi': '🇮🇳',
  };

  // 修改：接收 Locale 對象獲取語言旗幟
  static String getLanguageFlag(Locale locale) {
    final languageCode = getLanguageCodeFromLocale(locale);
    return languageFlags[languageCode] ?? '🌐';
  }
}

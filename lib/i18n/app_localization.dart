// ============================================================================
// 国际化核心类
// ============================================================================

import 'package:flutter/material.dart';
import 'language_config.dart';

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  /// 翻译指定的键
  String translate(String key) {
    final languageCode = locale.languageCode;
    final translations = LanguageConfig.getTranslations(languageCode);
    return translations[key] ?? key;
  }

  /// 获取当前语言的所有翻译
  Map<String, String> get currentTranslations {
    return LanguageConfig.getTranslations(locale.languageCode);
  }
}

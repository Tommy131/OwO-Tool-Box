// ============================================================================
// 国际化委托
// ============================================================================

import 'package:flutter/material.dart';
import 'app_localization.dart';
import 'language_config.dart';

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return LanguageConfig.supportedLanguages.contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    return AppLocalization(locale);
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

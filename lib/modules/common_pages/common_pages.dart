import 'package:flutter/material.dart';

import '../../core/module_registry/module_registrar.dart';
import '../../core/module_registry/module_registry.dart';
import '../../core/module_registry/navigation/navigation_item.dart';
import '../../core/services/localization_service.dart';

// localization
import 'localization/translations.dart';
import 'localization/localization_keys.dart';

// pages
import 'pages/about/about_page.dart';
import 'pages/dashboard/dashboard_page.dart';

class CommonPages implements ModuleRegistrar {
  @override
  String get moduleName => 'common_pages';

  @override
  void register() {
    final registry = ModuleRegistry();

    // 1. 注册国际化翻译
    LocalizationService().registerModuleTranslations(translations);

    // 2. 注册页面
    registry.navigation.register(
      (context) => NavigationItem(
        id: 'dashboard_page',
        title: LocalizationKeys.deviceInfo.tr(context),
        icon: Icons.speed_outlined,
        activeIcon: Icons.speed,
        page: const DashboardPage(),
        priority: 1,
      ),
    );

    registry.navigation.register(
      (context) => NavigationItem(
        id: 'about_page',
        title: LocalizationKeys.navAbout.tr(context),
        icon: Icons.speed_outlined,
        activeIcon: Icons.speed,
        page: const AboutPage(),
        priority: 999,
      ),
    );
  }
}

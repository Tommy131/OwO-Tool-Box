import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/module_registry/module_registrar.dart';
import '../../core/module_registry/module_registry.dart';
import '../../core/module_registry/navigation/navigation_item.dart';
import '../../core/services/localization_service.dart';

// localization
import 'localization/translations.dart';
import 'localization/localization_keys.dart';

// providers
import 'providers/dev_tools_provider.dart';

// pages
import 'pages/dev_tools_page.dart';

class DevTools implements ModuleRegistrar {
  @override
  String get moduleName => 'dev_tools';

  @override
  void register() {
    final registry = ModuleRegistry();

    // 1. 注册国际化翻译
    LocalizationService().registerModuleTranslations(translations);

    // 2. 注册 Cloudflare DNS 提供器
    registry.providers.register(
      ChangeNotifierProvider(create: (_) => DevToolsProvider()),
    );

    // 3. 注册导航页面
    registry.navigation.register(
      (context) => NavigationItem(
        id: 'dev_tools',
        title: LocalizationKeys.navDevTools.tr(context),
        icon: Icons.build_circle_outlined,
        activeIcon: Icons.build_circle,
        page: const DevToolsPage(),
      ),
    );
  }
}

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
import 'providers/system_tools_provider.dart';

// pages
import 'pages/system_tools_page.dart';

class SystemTools implements ModuleRegistrar {
  @override
  String get moduleName => 'system_tools';

  @override
  void register() {
    final registry = ModuleRegistry();

    // 1. 注册国际化翻译
    LocalizationService().registerModuleTranslations(translations);

    // 2. 注册 SystemTools 提供器
    registry.providers.register(
      ChangeNotifierProvider(create: (_) => SystemToolsProvider()),
    );

    // 3. 注册导航页面
    registry.navigation.register(
      (context) => NavigationItem(
        id: 'system_tools',
        title: LocalizationKeys.navSystemTools.tr(context),
        icon: Icons.build_circle_outlined,
        activeIcon: Icons.build_circle,
        page: const SystemToolsPage(),
        priority: 3,
      ),
    );
  }
}

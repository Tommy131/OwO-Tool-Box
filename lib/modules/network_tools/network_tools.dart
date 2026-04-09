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
import 'providers/ping_provider.dart';
import 'providers/perf_test_provider.dart';
import 'providers/site_test_provider.dart';
import 'providers/port_scan_provider.dart';

// pages
import 'pages/network_tools_page.dart';

class NetworkTools implements ModuleRegistrar {
  @override
  String get moduleName => 'network_tools';

  @override
  void register() {
    final registry = ModuleRegistry();

    // 1. 注册国际化翻译
    LocalizationService().registerModuleTranslations(translations);

    // 2. 注册工具提供器
    registry.providers.register(
      ChangeNotifierProvider(create: (_) => PingProvider()),
    );
    registry.providers.register(
      ChangeNotifierProvider(create: (_) => PerfTestProvider()),
    );
    registry.providers.register(
      ChangeNotifierProvider(create: (_) => SiteTestProvider()),
    );
    registry.providers.register(
      ChangeNotifierProvider(create: (_) => PortScanProvider()),
    );

    // 3. 注册导航页面
    registry.navigation.register(
      (context) => NavigationItem(
        id: 'network_tools',
        title: LocalizationKeys.navNetworkTools.tr(context),
        icon: Icons.speed_outlined,
        activeIcon: Icons.speed,
        page: const NetworkToolsPage(),
        priority: 5,
      ),
    );
  }
}

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
import 'providers/cloudflare_provider.dart';

// pages
import 'pages/cloudflare_dns_page.dart';

class CloudflareDns implements ModuleRegistrar {
  @override
  String get moduleName => 'cloudflare_dns';

  @override
  void register() {
    final registry = ModuleRegistry();

    // 1. 注册国际化翻译
    LocalizationService().registerModuleTranslations(translations);

    // 2. 注册 Cloudflare DNS 提供器
    registry.providers.register(
      ChangeNotifierProvider(create: (_) => CloudflareProvider()),
    );

    // 3. 注册导航页面
    registry.navigation.register(
      (context) => NavigationItem(
        id: 'cloudflare_dns',
        title: LocalizationKeys.navCloudflareDNS.tr(context),
        icon: Icons.dns_outlined,
        activeIcon: Icons.dns,
        page: const CloudflareDnsPage(),
        priority: 4,
      ),
    );

    // 4. 注册向导步骤
    // registry.wizardSteps.register('example_step', () => ExampleWizardStep());
  }
}

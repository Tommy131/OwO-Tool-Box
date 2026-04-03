import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/module_registry/module_registrar.dart';
import '../../core/module_registry/module_registry.dart';
import '../../core/module_registry/navigation/navigation_item.dart';
import '../../core/services/localization_service.dart';
import 'localization/localization_keys.dart';
import 'localization/translations.dart';
import 'pages/ssl_certificate_manager_page.dart';
import 'providers/ssl_certificate_manager_provider.dart';

class SslCertificateManager implements ModuleRegistrar {
  @override
  String get moduleName => 'ssl_certificate_manager';

  @override
  void register() {
    final registry = ModuleRegistry();

    LocalizationService().registerModuleTranslations(translations);

    registry.providers.register(
      ChangeNotifierProvider(create: (_) => SslCertificateManagerProvider()),
    );

    registry.navigation.register(
      (context) => NavigationItem(
        id: 'ssl_certificate_manager',
        title: LocalizationKeys.navSslManager.tr(context),
        icon: Icons.shield_outlined,
        activeIcon: Icons.shield,
        page: const SslCertificateManagerPage(),
        priority: 6,
      ),
    );
  }
}

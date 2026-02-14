import 'package:flutter/material.dart';

import '../../core/module_registry/module_registrar.dart';
import '../../core/module_registry/module_registry.dart';
import '../../core/module_registry/about_page/about_page_item.dart';
import '../../core/module_registry/navigation/navigation_item.dart';
import '../../core/services/localization_service.dart';

// localization
import 'localization/translations.dart';
import 'localization/localization_keys.dart';

// pages
import 'pages/about/agreement_card.dart';
import 'pages/about/app_icon_card.dart';
import 'pages/about/app_info_card.dart';
import 'pages/about/copyright_card.dart';
import 'pages/about/developer_card.dart';
import 'pages/about/donation_card.dart';
import 'pages/about/open_source_card.dart';
import 'pages/about/tech_stack_card.dart';
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

    registry.aboutPages.register(
      AboutPageItem(
        id: 'app_icon',
        priority: 10,
        builder: (_) => const AppIconCard(),
      ),
    );

    registry.aboutPages.register(
      AboutPageItem(
        id: 'app_info',
        priority: 20,
        builder: (_) => const AppInfoCard(),
      ),
    );

    registry.aboutPages.register(
      AboutPageItem(
        id: 'developer',
        priority: 30,
        builder: (_) => const DeveloperCard(),
      ),
    );

    registry.aboutPages.register(
      AboutPageItem(
        id: 'tech_stack',
        priority: 40,
        builder: (_) => const TechStackCard(),
      ),
    );

    registry.aboutPages.register(
      AboutPageItem(
        id: 'donation',
        priority: 50,
        builder: (_) => const DonationCard(),
      ),
    );

    registry.aboutPages.register(
      AboutPageItem(
        id: 'open_source',
        priority: 60,
        builder: (_) => const OpenSourceCard(),
      ),
    );

    registry.aboutPages.register(
      AboutPageItem(
        id: 'agreement',
        priority: 70,
        builder: (_) => const AgreementCard(),
      ),
    );

    registry.aboutPages.register(
      AboutPageItem(
        id: 'copyright',
        priority: 80,
        builder: (_) => const CopyrightCard(),
      ),
    );
  }
}

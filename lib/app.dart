/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-22
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/layouts/desktop_layout.dart';
import 'core/layouts/responsive_builder.dart';
import 'core/layouts/mobile_layout.dart';
import 'core/layouts/tablet_layout.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/matrix_rain_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/i18n/app_localization.dart' hide AppLocalizationDelegate;
import 'core/i18n/language_config.dart';
import 'core/i18n/localization_delegate.dart';
import 'screens/screen_navigation_helper.dart';
// Host Monitor
import 'host_monitor/providers/host_monitor_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // core
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => MatrixRainProvider()),
        // Host Monitor
        ChangeNotifierProvider(create: (_) => HostMonitorProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'OwO! Tool Box',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: LanguageConfig.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // 语言解析回调
            localeResolutionCallback: (locale, supportedLocales) {
              // 如果用户没有设置语言，使用系统语言
              if (localeProvider.locale == null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first; // 默认返回第一个支持的语言
              }
              return localeProvider.locale;
            },

            home: const AdaptiveScaffold(),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 自适应脚手架 - 根据屏幕尺寸自动切换布局
// ============================================================================

class AdaptiveScaffold extends StatelessWidget with WidgetsBindingObserver {
  const AdaptiveScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化主机监测管理器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HostMonitorProvider>().initialize();
    });

    final localizations = AppLocalization.of(context);
    final navigationHelper =
        ScreenNavigationHelper(localizations: localizations);

    List<NavigationRailDestination> destinationsRail =
        navigationHelper.getRailDestinations();
    List<NavigationDestination> destinations =
        navigationHelper.getDestinations();

    return ResponsiveBuilder(
      mobile: MobileLayout(
        pages: navigationHelper.getPages(),
        destinations: destinations,
      ),
      tablet: TabletLayout(
        pages: navigationHelper.getPages(),
        destinations: destinationsRail,
      ),
      desktop: DesktopLayout(
        pages: navigationHelper.getPages(),
        destinations: destinationsRail,
      ),
    );
  }
}

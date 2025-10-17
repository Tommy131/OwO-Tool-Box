// ============================================================================
// Flutter 应用框架 - 主入口文件(增强版 - 多平台布局支持 + 窗口控制)
// 版本: 2.2.0
// 说明: 支持多平台自适应布局,针对手机、平板、PC进行优化,添加窗口控制功能
//      支持动态主题配色切换
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'layouts/desktop_layout.dart';
import 'layouts/responsive_builder.dart';
import 'layouts/mobile_layout.dart';
import 'layouts/tablet_layout.dart';
import 'providers/locale_provider.dart';
import 'providers/matrix_rain_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/screen_navigation_helper.dart';
import 'providers/theme_provider.dart';
import 'i18n/app_localization.dart';
import 'i18n/language_config.dart';
import 'i18n/localization_delegate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => MatrixRainProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Flutter App Framework',
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

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({super.key});

  @override
  Widget build(BuildContext context) {
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

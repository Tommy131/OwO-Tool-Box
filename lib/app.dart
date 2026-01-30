import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'apps/host_monitor/pages/host_monitor_page.dart';
import 'apps/host_monitor/providers/host_monitor_provider.dart';

import 'apps/system_tools/pages/system_tools_page.dart';
import 'apps/system_tools/providers/system_tools_provider.dart';

import 'apps/cloudflare_dns/pages/cloudflare_dns_page.dart';
import 'apps/cloudflare_dns/providers/cloudflare_provider.dart';

import 'core/i18n/app_localization.dart';
import 'core/i18n/language_config.dart';
import 'core/providers/locale_provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/i18n/localization_keys.dart';
import 'core/layouts/desktop_layout.dart';
import 'core/layouts/mobile_layout.dart';
import 'core/layouts/responsive.dart';
import 'core/models/navigation_item.dart';
import 'core/widgets/common/dialog.dart';
import 'core/widgets/desktop/custom_title_bar.dart';
import 'pages/about/about_page.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/settings/settings_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        // Host Monitor
        ChangeNotifierProvider(create: (_) => HostMonitorProvider()),
        // System Tools
        ChangeNotifierProvider(create: (_) => SystemToolsProvider()),
        // Cloudflare DNS
        ChangeNotifierProvider(create: (_) => CloudflareProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme.generateLightTheme(),
            darkTheme: themeProvider.currentTheme.generateDarkTheme(),
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
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WindowListener {
  int _selectedIndex = 0;

  // 定义导航项
  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      id: 'dashboard',
      title: L18nKeys.deviceInfo,
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      page: DashboardPage(),
    ),
    NavigationItem(
      id: 'host_monitor',
      title: L18nKeys.navMonitor,
      icon: Icons.monitor_outlined,
      activeIcon: Icons.monitor,
      page: HostMonitorPage(),
    ),
    NavigationItem(
      id: 'system_tools',
      title: L18nKeys.navSystemTools,
      icon: Icons.build_circle_outlined,
      activeIcon: Icons.build_circle,
      page: SystemToolsPage(),
    ),
    NavigationItem(
      id: 'cloudflare_dns',
      title: L18nKeys.navCloudflareDNS,
      icon: Icons.dns_outlined,
      activeIcon: Icons.dns,
      page: CloudflareDnsPage(),
    ),
    NavigationItem(
      id: 'about',
      title: L18nKeys.navAbout,
      icon: Icons.info_outlined,
      activeIcon: Icons.info,
      page: AboutPage(),
    ),
    NavigationItem(
      id: 'settings',
      title: L18nKeys.navSettings,
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      page: SettingsPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _init();

    // 初始化主机监测管理器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HostMonitorProvider>().initialize();
    });
  }

  void _init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (!Platform.isAndroid && !Platform.isIOS) ...[
          const CustomTitleBar(title: Text(AppConstants.appName)),
          Divider(height: 1, color: Color(isDark ? 0xFF313131 : 0xFFD6D6D6)),
        ],
        Expanded(
          child: Responsive(
            // 移动端布局
            mobile: MobileLayout(
              navigationItems: _navigationItems,
              selectedIndex: _selectedIndex,
              onNavigationChanged: _onNavigationChanged,
            ),
            // 桌面端布局
            desktop: DesktopLayout(
              navigationItems: _navigationItems,
              selectedIndex: _selectedIndex,
              onNavigationChanged: _onNavigationChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      final l10n = AppLocalization.of(context);
      final result = await showAdvancedConfirmDialog(
        context: context,
        // style: ConfirmDialogStyle.glass,
        title: l10n.translate(L18nKeys.exitConfirmTitle),
        content: l10n.translate(L18nKeys.exitConfirmMessage),
        icon: Icons.warning_amber_rounded,
        confirmColor: Colors.redAccent,
        confirmText: l10n.translate(L18nKeys.confirm),
        cancelText: l10n.translate(L18nKeys.cancel),
      );

      if (result == true && mounted) {
        await windowManager.destroy();
      }
    }
  }
}

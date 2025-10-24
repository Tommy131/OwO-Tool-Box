import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/app_localization.dart';
import '../../core/i18n/localization_keys.dart';
import '../../core/providers/theme_provider.dart';
import '../providers/certificate_provider.dart';
import 'certificate_management_screen.dart';
import 'settings_screen.dart';
import 'openssl_config_screen.dart';

class SSLHomeScreen extends StatefulWidget {
  const SSLHomeScreen({super.key});

  @override
  State<SSLHomeScreen> createState() => _SSLHomeScreenState();
}

enum Screens {
  certificateManagementScreen,
  openSSLConfigScreen,
  settingsScreen,
}

class _SSLHomeScreenState extends State<SSLHomeScreen> {
  Screens? _currentScreen;

  // 国际化翻译辅助方法
  String _tr(String key) {
    return AppLocalization.of(context).translate(key);
  }

  /// 导航数据
  List<
      ({
        String Function() title,
        String Function() subtitle,
        IconData icon,
        Color color,
        Widget screen,
        Screens screenType,
      })> get navigationItems => [
        (
          title: () => _tr(L18nKeys.sslCertificates),
          subtitle: () => _tr(L18nKeys.sslManageCertificates),
          icon: Icons.folder,
          color: Colors.lightGreen,
          screen: const CertificateManagementScreen(),
          screenType: Screens.certificateManagementScreen,
        ),
        (
          title: () => _tr(L18nKeys.sslConfig),
          subtitle: () => _tr(L18nKeys.sslOpenSSLConfiguration),
          icon: Icons.settings_applications,
          color: Colors.orange,
          screen: const OpenSSLConfigScreen(),
          screenType: Screens.openSSLConfigScreen,
        ),
        (
          title: () => _tr(L18nKeys.settings),
          subtitle: () => _tr(L18nKeys.sslAppSettings),
          icon: Icons.settings,
          color: Colors.blueGrey,
          screen: const SettingsScreen(),
          screenType: Screens.settingsScreen,
        ),
      ];

  get _getNavigationItems =>
      navigationItems.firstWhere((item) => _currentScreen == item.screenType);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text((_currentScreen == null)
            ? _tr(L18nKeys.sslCertificateManager)
            : _getNavigationItems.title()),
        leading: (_currentScreen != null)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentScreen = null;
                  });
                },
                tooltip: _tr(L18nKeys.sslBack),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: _tr(L18nKeys.sslToggleTheme),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: (_currentScreen == null) ? _buildWelcomeArea() : _buildScreen(),
    );
  }

  Widget _buildScreen() {
    return _getNavigationItems.screen;
  }

  Widget _buildWelcomeArea() {
    final theme = Theme.of(context);
    final certificateProvider = context.watch<CertificateProvider>();

    double screenWidth = MediaQuery.of(context).size.width;

    final totalCerts = certificateProvider.certificates.length;
    final caCerts = certificateProvider.caCertificates.length;
    final sslCerts = certificateProvider.sslCertificates.length;
    final expiredCerts =
        certificateProvider.certificates.where((cert) => cert.isExpired).length;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 欢迎信息
          Text(
            _tr(L18nKeys.sslWelcomeTitle),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tr(L18nKeys.sslWelcomeSubtitle),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // 统计卡片
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: (screenWidth > 1120) ? 1.2 : 1,
            children: [
              _StatCard(
                title: _tr(L18nKeys.sslTotalCertificates),
                value: totalCerts.toString(),
                icon: Icons.inventory_2,
                color: theme.colorScheme.primary,
              ),
              _StatCard(
                title: _tr(L18nKeys.sslCACertificates),
                value: caCerts.toString(),
                icon: Icons.security,
                color: Colors.blue,
              ),
              _StatCard(
                title: _tr(L18nKeys.sslSSLCertificates),
                value: sslCerts.toString(),
                icon: Icons.verified_user,
                color: Colors.green,
              ),
              _StatCard(
                title: _tr(L18nKeys.sslExpired),
                value: expiredCerts.toString(),
                icon: Icons.error,
                color: theme.colorScheme.error,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 导航区域
          Text(
            _tr(L18nKeys.sslNavigation),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2,
            children: navigationItems
                .map(
                  (item) => _NavigationCard(
                    title: item.title(),
                    subtitle: item.subtitle(),
                    icon: item.icon,
                    color: item.color,
                    onTap: () {
                      setState(() {
                        _currentScreen = item.screenType;
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// 导航卡片
class _NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 统计卡片
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

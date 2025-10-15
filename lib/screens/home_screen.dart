// ============================================================================
// 首页内容
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/responsive_break_points.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/theme_config.dart';
import '../utils/i18n/app_localization.dart';
import '../utils/i18n/localization_keys.dart';
import '../widgets/cards/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isCyberpunk = themeProvider.themeType == ThemeType.cyberpunk;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String deviceType;
    if (isMobile) {
      deviceType = localizations.translate(L18nKeys.mobileDevice);
    } else if (isTablet) {
      deviceType = localizations.translate(L18nKeys.tabletDevice);
    } else {
      deviceType = localizations.translate(L18nKeys.desktopDevice);
    }

    // ✅ 移除 MatrixRain 包裹，直接返回内容
    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(localizations.translate(L18nKeys.appTitle)),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop
              ? 48
              : isTablet
                  ? 32
                  : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop
                    ? 1200
                    : isTablet
                        ? 800
                        : 600,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      isCyberpunk
                          ? Icons.electric_bolt_rounded
                          : Icons.rocket_launch_rounded,
                      size: isDesktop
                          ? 140
                          : isTablet
                              ? 100
                              : 80,
                      color: Theme.of(context).colorScheme.primary,
                      shadows: isCyberpunk && isDark
                          ? [
                              Shadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8),
                                blurRadius: 20,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32 : 24),
                  Text(
                    localizations.translate(L18nKeys.welcome),
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.translate(L18nKeys.welcomeMessage),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.translate(L18nKeys.welcomeDescription),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isDesktop ? 48 : 32),
                  _buildDeviceInfoCard(context, deviceType),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildFeatureGrid(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(BuildContext context, String deviceType) {
    final localizations = AppLocalization.of(context);
    final size = MediaQuery.of(context).size;
    final isWideScreen = ResponsiveBreakpoints.isWideScreen(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.devices_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.translate(L18nKeys.deviceInfo),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              localizations.translate(L18nKeys.deviceType),
              deviceType,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              context,
              localizations.translate(L18nKeys.screenSize),
              '${size.width.toInt()} × ${size.height.toInt()}',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              context,
              localizations.translate(L18nKeys.layoutMode),
              isWideScreen
                  ? localizations.translate(L18nKeys.adaptiveLayout)
                  : localizations.translate(L18nKeys.mobileDevice),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    final features = [
      {
        'icon': Icons.palette_rounded,
        'title': AppLocalization.of(context).translate(L18nKeys.themeSettings),
        'description':
            AppLocalization.of(context).translate(L18nKeys.themeSettings),
        'onTap': () => navigationProvider.setIndex(1),
      },
      {
        'icon': Icons.language_rounded,
        'title':
            AppLocalization.of(context).translate(L18nKeys.languageSettings),
        'description':
            AppLocalization.of(context).translate(L18nKeys.languageSettings),
        'onTap': () => navigationProvider.setIndex(1),
      },
      {
        'icon': Icons.info_rounded,
        'title': AppLocalization.of(context).translate(L18nKeys.about),
        'description': AppLocalization.of(context).translate(L18nKeys.appInfo),
        'onTap': () => navigationProvider.setIndex(2),
      },
      {
        'icon': Icons.devices_rounded,
        'title': AppLocalization.of(context).translate(L18nKeys.adaptiveLayout),
        'description':
            AppLocalization.of(context).translate(L18nKeys.deviceInfo),
        'onTap': () {},
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop
            ? 2
            : isTablet
                ? 2
                : 1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isDesktop
            ? 3.5
            : isTablet
                ? 3.0
                : 3.5,
        mainAxisExtent: isDesktop
            ? null
            : isTablet
                ? null
                : 80,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return FeatureCard(
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
          onTap: feature['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    // ✅ 修复：使用更清晰的颜色方案
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  // ✅ 修复：深色模式下更亮的颜色
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  // ✅ 修复：使用主题的 onSurface 颜色
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

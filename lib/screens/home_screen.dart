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
// ============================================================================
// 首页内容 - 优化版
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/layouts/responsive_break_points.dart';
import '../core/providers/navigation_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/theme/theme_config.dart';
import '../core/i18n/app_localization.dart';
import '../core/i18n/localization_keys.dart';

/// 主页屏幕
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints(context).isMobile();
    final localizations = AppLocalization.of(context);

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(localizations.translate(L18nKeys.appTitle)),
            )
          : null,
      body: const SafeArea(
        child: _HomeContent(),
      ),
    );
  }
}

/// 主页内容组件
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final responsiveBreakpoints = ResponsiveBreakpoints(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(responsiveBreakpoints.padding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: responsiveBreakpoints.maxWidth,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AnimatedWelcomeIcon(
                size: responsiveBreakpoints.iconSize,
              ),
              SizedBox(height: responsiveBreakpoints.sectionSpacing),
              _WelcomeText(),
              SizedBox(height: responsiveBreakpoints.sectionSpacing),
              const _DeviceInfoCard(),
              SizedBox(height: responsiveBreakpoints.cardSpacing),
              const _FeatureGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 动画欢迎图标
class _AnimatedWelcomeIcon extends StatefulWidget {
  final double size;

  const _AnimatedWelcomeIcon({required this.size});

  @override
  State<_AnimatedWelcomeIcon> createState() => _AnimatedWelcomeIconState();
}

class _AnimatedWelcomeIconState extends State<_AnimatedWelcomeIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // 启动动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isCyberpunk = themeProvider.themeType == ThemeType.cyberpunk;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value.clamp(0.0, 1.0), // 确保值在有效范围内
            child: child,
          ),
        );
      },
      child: Icon(
        isCyberpunk ? Icons.electric_bolt_rounded : Icons.rocket_launch_rounded,
        size: widget.size,
        color: Theme.of(context).colorScheme.primary,
        shadows: isCyberpunk && isDark
            ? [
                Shadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.8),
                  blurRadius: 20,
                ),
              ]
            : null,
      ),
    );
  }
}

/// 欢迎文本组件
class _WelcomeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          localizations.translate(L18nKeys.welcome),
          style: theme.textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          localizations.translate(L18nKeys.welcomeMessage),
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          localizations.translate(L18nKeys.welcomeDescription),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// 设备信息卡片
class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final deviceInfo = _DeviceInfo(context);

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
            _InfoRow(
              label: localizations.translate(L18nKeys.deviceType),
              value: deviceInfo.deviceType,
            ),
            const SizedBox(height: 10),
            _InfoRow(
              label: localizations.translate(L18nKeys.screenSize),
              value: deviceInfo.screenSize,
            ),
            const SizedBox(height: 10),
            _InfoRow(
              label: localizations.translate(L18nKeys.layoutMode),
              value: deviceInfo.layoutMode,
            ),
          ],
        ),
      ),
    );
  }
}

/// 设备信息辅助类
class _DeviceInfo {
  final BuildContext context;

  _DeviceInfo(this.context);

  String get deviceType {
    final localizations = AppLocalization.of(context);
    final responsiveBreakpoints = ResponsiveBreakpoints(context);
    if (responsiveBreakpoints.isMobile()) {
      return localizations.translate(L18nKeys.mobileDevice);
    } else if (responsiveBreakpoints.isTablet()) {
      return localizations.translate(L18nKeys.tabletDevice);
    } else {
      return localizations.translate(L18nKeys.desktopDevice);
    }
  }

  String get screenSize {
    final size = MediaQuery.of(context).size;
    return '${size.width.toInt()} × ${size.height.toInt()}';
  }

  String get layoutMode {
    final localizations = AppLocalization.of(context);
    return ResponsiveBreakpoints(context).isWideScreen()
        ? localizations.translate(L18nKeys.adaptiveLayout)
        : localizations.translate(L18nKeys.mobileDevice);
  }
}

/// 信息行组件 - 可复用的标签-值显示
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
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

/// 功能网格
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final responsiveBreakpoints = ResponsiveBreakpoints(context);
    final features = _FeatureData.getFeatures(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsiveBreakpoints.gridColumns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: responsiveBreakpoints.gridAspectRatio,
        mainAxisExtent: responsiveBreakpoints.gridItemHeight,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) => features[index],
    );
  }
}

/// 功能数据类 - 集中管理功能卡片配置
class _FeatureData {
  static List<Widget> getFeatures(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final navigationProvider = context.read<NavigationProvider>();

    final featureConfigs = [
      _FeatureConfig(
        icon: Icons.palette_rounded,
        titleKey: L18nKeys.themeSettings,
        descriptionKey: L18nKeys.themeSettings,
        onTap: () => navigationProvider.setIndex(3),
      ),
      _FeatureConfig(
        icon: Icons.language_rounded,
        titleKey: L18nKeys.languageSettings,
        descriptionKey: L18nKeys.languageSettings,
        onTap: () => navigationProvider.setIndex(3),
      ),
      _FeatureConfig(
        icon: Icons.monitor_outlined,
        titleKey: L18nKeys.monitor,
        descriptionKey: L18nKeys.hostMonitor,
        onTap: () => navigationProvider.setIndex(1),
      ),
      _FeatureConfig(
        icon: Icons.info_rounded,
        titleKey: L18nKeys.about,
        descriptionKey: L18nKeys.appInfo,
        onTap: () => navigationProvider.setIndex(2),
      ),
    ];

    return featureConfigs
        .map((config) => FeatureCard(
              icon: config.icon,
              title: localizations.translate(config.titleKey),
              description: localizations.translate(config.descriptionKey),
              onTap: config.onTap,
            ))
        .toList();
  }
}

/// 功能配置类
class _FeatureConfig {
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final VoidCallback onTap;

  const _FeatureConfig({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.onTap,
  });
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // ✅ 修复：图标容器使用主色调的半透明背景
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ 修复：标题使用 onSurface 颜色确保可见
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // ✅ 修复：描述使用更亮的灰色
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // ✅ 修复：箭头图标颜色
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

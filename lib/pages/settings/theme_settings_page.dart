import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../../core/theme/app_theme_data.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/i18n/app_localization.dart';
import '../../core/i18n/localization_keys.dart';

/// 统一的主题设置页面
class ThemeSettingsPage extends StatelessWidget {
  final VoidCallback? onBack;

  const ThemeSettingsPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalization.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        children: [
          _buildHeader(context, theme, l10n),
          const SizedBox(height: AppThemeData.spacingSmall),
          const _CurrentThemeCard(),
          const SizedBox(height: AppThemeData.spacingLarge),
          const _PresetThemesSection(),
          const SizedBox(height: AppThemeData.spacingLarge),
          const _CustomThemeSection(),
          const SizedBox(height: AppThemeData.spacingLarge),
          const _DesignConstantsSection(),
          const SizedBox(height: AppThemeData.spacingLarge),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalization l10n,
  ) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
            Text(
              l10n.translate(L18nKeys.themeSettings),
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),
        Row(
          children: [
            _QuickThemeMenu(),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.translate(L18nKeys.resetToDefault),
              onPressed: () {
                context.read<ThemeProvider>().resetToDefault();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.translate(L18nKeys.resetToDefaultMessage),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== 公共组件 ====================

/// 通用设置区块卡片
class _SettingsSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SettingsSectionCard({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            if (subtitle != null) ...[
              const SizedBox(height: AppThemeData.spacingSmall),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: AppThemeData.spacingMedium),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// 主题颜色圆圈组件
class _ThemeColorCircle extends StatelessWidget {
  final Color color;
  final double size;
  final bool showCheck;
  final bool showShadow;

  const _ThemeColorCircle({
    required this.color,
    this.size = 48,
    this.showCheck = false,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: showCheck
          ? Icon(
              Icons.check,
              color: AppThemeData.getContrastColor(color),
              size: size * 0.5,
            )
          : null,
    );
  }
}

/// 快速主题切换菜单
class _QuickThemeMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeProvider>().currentTheme;
    final l10n = AppLocalization.of(context);

    return PopupMenuButton<AppThemeData>(
      icon: const Icon(Icons.palette_outlined),
      tooltip: l10n.translate(L18nKeys.quickSwitchTheme),
      onSelected: (theme) {
        context.read<ThemeProvider>().setTheme(theme);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n
                  .translate(L18nKeys.switchedToTheme)
                  .replaceAll(
                    '{theme}',
                    theme.isCustom ? theme.name : l10n.translate(theme.name),
                  ),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      itemBuilder: (context) {
        return AppThemeData.presetThemes.map((theme) {
          final isSelected = currentTheme == theme;
          return PopupMenuItem(
            value: theme,
            child: Row(
              children: [
                _ThemeColorCircle(
                  color: theme.primaryColor,
                  size: 24,
                  showCheck: isSelected,
                ),
                const SizedBox(width: 12),
                Text(
                  theme.isCustom ? theme.name : l10n.translate(theme.name),
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

// ==================== 页面区块 ====================

/// 当前主题信息卡片
class _CurrentThemeCard extends StatelessWidget {
  const _CurrentThemeCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalization.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate(L18nKeys.currentTheme),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppThemeData.spacingMedium),
            Row(
              children: [
                _ThemeColorCircle(
                  color: provider.currentTheme.primaryColor,
                  size: 56,
                  showShadow: true,
                ),
                const SizedBox(width: AppThemeData.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.currentTheme.isCustom
                            ? provider.currentTheme.name
                            : l10n.translate(provider.currentTheme.name),
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.translate(
                          provider.getThemeModeName(provider.themeMode),
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  provider.getThemeModeIcon(provider.themeMode),
                  size: 32,
                  color: theme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: AppThemeData.spacingMedium),
            _QuickActionButtons(),
          ],
        ),
      ),
    );
  }
}

/// 快速操作按钮
class _QuickActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final l10n = AppLocalization.of(context);

    return Wrap(
      spacing: AppThemeData.spacingSmall,
      runSpacing: AppThemeData.spacingSmall,
      children: [
        ElevatedButton.icon(
          onPressed: () => provider.toggleThemeMode(),
          icon: Icon(provider.getThemeModeIcon(provider.themeMode)),
          label: Text(l10n.translate(L18nKeys.switchMode)),
        ),
        OutlinedButton.icon(
          onPressed: () => provider.toggleDarkMode(),
          icon: const Icon(Icons.brightness_6),
          label: Text(
            provider.isDarkMode
                ? l10n.translate(L18nKeys.switchToLight)
                : l10n.translate(L18nKeys.switchToDark),
          ),
        ),
      ],
    );
  }
}

/// 预设主题区域
class _PresetThemesSection extends StatelessWidget {
  const _PresetThemesSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return _SettingsSectionCard(
      title: l10n.translate(L18nKeys.themeColorSchemes),
      subtitle: l10n.translate(L18nKeys.selectFavoriteTheme),
      children: [_PresetThemeGrid()],
    );
  }
}

/// 预设主题网格
class _PresetThemeGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeProvider>().currentTheme;
    final l10n = AppLocalization.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: AppThemeData.spacingSmall,
        mainAxisSpacing: AppThemeData.spacingSmall,
        childAspectRatio: 1.1,
      ),
      itemCount: AppThemeData.presetThemes.length,
      itemBuilder: (context, index) {
        final theme = AppThemeData.presetThemes[index];
        final isSelected = currentTheme == theme;

        return _ThemeCard(
          theme: theme,
          isSelected: isSelected,
          onTap: () {
            context.read<ThemeProvider>().setTheme(theme);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n
                      .translate(L18nKeys.switchedToTheme)
                      .replaceAll(
                        '{theme}',
                        theme.isCustom
                            ? theme.name
                            : l10n.translate(theme.name),
                      ),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }
}

/// 主题卡片
class _ThemeCard extends StatelessWidget {
  final AppThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppThemeData.borderRadiusMedium),
        side: BorderSide(
          color: isSelected
              ? theme.primaryColor
              : AppThemeData.getBorderColor(Theme.of(context)),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeData.borderRadiusMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ThemeColorCircle(
              color: theme.primaryColor,
              size: 48,
              showCheck: isSelected,
              showShadow: isSelected,
            ),
            const SizedBox(height: AppThemeData.spacingSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                theme.isCustom
                    ? theme.name
                    : AppLocalization.of(context).translate(theme.name),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 自定义主题区域
class _CustomThemeSection extends StatelessWidget {
  const _CustomThemeSection();

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeProvider>().currentTheme;
    final l10n = AppLocalization.of(context);

    return _SettingsSectionCard(
      title: l10n.translate(L18nKeys.customTheme),
      subtitle: l10n.translate(L18nKeys.createYourOwnTheme),
      children: [
        if (currentTheme.isCustom) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppThemeData.spacingMedium),
              child: Row(
                children: [
                  _ThemeColorCircle(
                    color: currentTheme.primaryColor,
                    size: 48,
                    showCheck: true,
                  ),
                  const SizedBox(width: AppThemeData.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTheme.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.translate(L18nKeys.currentCustomTheme),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppThemeData.spacingSmall),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showColorPicker(context),
            icon: const Icon(Icons.palette),
            label: Text(l10n.translate(L18nKeys.createCustomTheme)),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    final l10n = AppLocalization.of(context);
    Color selectedColor = context
        .read<ThemeProvider>()
        .currentTheme
        .primaryColor;
    final nameController = TextEditingController(
      text: l10n.translate(L18nKeys.customTheme),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.translate(L18nKeys.customThemeColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.translate(L18nKeys.themeName),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeData.borderRadiusSmall,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppThemeData.spacingMedium),
              ColorPicker(
                color: selectedColor,
                onColorChanged: (color) => selectedColor = color,
                width: 40,
                height: 40,
                borderRadius: 20,
                spacing: 8,
                runSpacing: 8,
                wheelDiameter: 200,
                heading: Text(l10n.translate(L18nKeys.selectThemeColor)),
                subheading: Text(l10n.translate(L18nKeys.selectColorShade)),
                pickersEnabled: const {
                  ColorPickerType.both: false,
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: false,
                  ColorPickerType.wheel: true,
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.translate(L18nKeys.cancel)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ThemeProvider>().createCustomTheme(
                selectedColor,
                nameController.text.isEmpty
                    ? l10n.translate(L18nKeys.customTheme)
                    : nameController.text,
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.translate(L18nKeys.customThemeApplied)),
                ),
              );
            },
            child: Text(l10n.translate(L18nKeys.apply)),
          ),
        ],
      ),
    );
  }
}

/// 设计常量示例区域（可选功能）
class _DesignConstantsSection extends StatelessWidget {
  const _DesignConstantsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return _SettingsSectionCard(
      title: l10n.translate(L18nKeys.designConstants),
      children: [
        _ConstantItem(
          l10n.translate(L18nKeys.spacingSmall),
          '${AppThemeData.spacingSmall}px',
        ),
        _ConstantItem(
          l10n.translate(L18nKeys.spacingMedium),
          '${AppThemeData.spacingMedium}px',
        ),
        _ConstantItem(
          l10n.translate(L18nKeys.spacingLarge),
          '${AppThemeData.spacingLarge}px',
        ),
        const Divider(height: AppThemeData.spacingLarge),
        _ConstantItem(
          l10n.translate(L18nKeys.borderRadiusSmall),
          '${AppThemeData.borderRadiusSmall}px',
        ),
        _ConstantItem(
          l10n.translate(L18nKeys.borderRadiusMedium),
          '${AppThemeData.borderRadiusMedium}px',
        ),
        _ConstantItem(
          l10n.translate(L18nKeys.borderRadiusLarge),
          '${AppThemeData.borderRadiusLarge}px',
        ),
      ],
    );
  }
}

class _ConstantItem extends StatelessWidget {
  final String label;
  final String value;

  const _ConstantItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

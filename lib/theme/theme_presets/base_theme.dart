// ============================================================================
// 基础主题配置 - 提供通用主题构建方法
// ============================================================================

import 'package:flutter/material.dart';

/// 主题颜色配置
class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color? background;
  final Color? surface;
  final Color? cardBackground;
  final Color? onPrimary;
  final Color? onSecondary;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    this.background,
    this.surface,
    this.cardBackground,
    this.onPrimary,
    this.onSecondary,
  });
}

/// 主题样式配置
class ThemeStyles {
  final double cardElevation;
  final double cardBorderRadius;
  final double buttonBorderRadius;
  final bool showCardBorder;
  final bool showGlowEffect;
  final EdgeInsets buttonPadding;

  const ThemeStyles({
    this.cardElevation = 2,
    this.cardBorderRadius = 12,
    this.buttonBorderRadius = 12,
    this.showCardBorder = false,
    this.showGlowEffect = false,
    this.buttonPadding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  const ThemeStyles.tech()
      : cardElevation = 4,
        cardBorderRadius = 16,
        buttonBorderRadius = 12,
        showCardBorder = true,
        showGlowEffect = true,
        buttonPadding =
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12);

  const ThemeStyles.modern()
      : cardElevation = 3,
        cardBorderRadius = 16,
        buttonBorderRadius = 12,
        showCardBorder = false,
        showGlowEffect = false,
        buttonPadding =
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
}

/// 基础主题构建器
abstract class BaseTheme {
  /// 获取浅色主题颜色配置
  ThemeColors get lightColors;

  /// 获取深色主题颜色配置
  ThemeColors get darkColors;

  /// 获取主题样式配置
  ThemeStyles get themeStyles => const ThemeStyles();

  /// 构建浅色主题（实例方法，不与静态成员冲突）
  ThemeData buildLightTheme() => _buildTheme(
        brightness: Brightness.light,
        colors: lightColors,
        styles: themeStyles,
      );

  /// 构建深色主题（实例方法，不与静态成员冲突）
  ThemeData buildDarkTheme() => _buildTheme(
        brightness: Brightness.dark,
        colors: darkColors,
        styles: themeStyles,
      );

  ThemeData _buildTheme({
    required Brightness brightness,
    required ThemeColors colors,
    required ThemeStyles styles,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final Color defaultBackground =
        isDark ? const Color(0xFF121212) : Colors.grey.shade50;
    final Color defaultSurface =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color defaultCardBg = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // 颜色方案
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        secondary: colors.secondary,
        tertiary: colors.tertiary,
        surface: colors.surface ?? defaultSurface,
        error: isDark ? Colors.redAccent : Colors.red,
        onPrimary:
            colors.onPrimary ?? _getContrastingColor(colors.primary), // ✅ 智能对比色
        onSecondary:
            colors.onSecondary ?? _getContrastingColor(colors.secondary),
        onSurface: isDark ? Colors.white : Colors.black87,
        onError: Colors.white,
        surfaceContainerHighest: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
        outline: colors.primary.withOpacity(isDark ? 0.4 : 0.3),
      ),

      scaffoldBackgroundColor: colors.background ?? defaultBackground,

      // 所有主题配置...
      cardTheme: _buildCardTheme(colors, styles, isDark, defaultCardBg),
      appBarTheme: _buildAppBarTheme(colors, styles, isDark),
      navigationRailTheme: _buildNavigationRailTheme(colors, styles, isDark),
      bottomNavigationBarTheme:
          _buildBottomNavTheme(colors, isDark, defaultCardBg),
      floatingActionButtonTheme: _buildFABTheme(colors, styles),
      elevatedButtonTheme: _buildElevatedButtonTheme(colors, styles),

      // ✅ 新增按钮主题
      outlinedButtonTheme: _buildOutlinedButtonTheme(colors, styles, isDark),
      textButtonTheme: _buildTextButtonTheme(colors, isDark),

      listTileTheme: _buildListTileTheme(colors, isDark),
      iconTheme: IconThemeData(color: colors.primary),
      dividerTheme: DividerThemeData(
        color: colors.primary.withOpacity(isDark ? 0.3 : 0.2),
        thickness: 1,
      ),
      textTheme: _buildTextTheme(colors, isDark),
    );
  }

  /// ✅ 新增：智能计算对比色的辅助方法
  Color _getContrastingColor(Color color) {
    // 计算亮度，根据 WCAG 标准
    final luminance = color.computeLuminance();
    // 如果颜色较亮，返回黑色；否则返回白色
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 构建 Card 主题
  CardThemeData _buildCardTheme(
    ThemeColors colors,
    ThemeStyles styles,
    bool isDark,
    Color defaultCardBg,
  ) {
    return CardThemeData(
      elevation: styles.cardElevation,
      color: colors.cardBackground ?? defaultCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(styles.cardBorderRadius),
        side: styles.showCardBorder
            ? BorderSide(
                color: colors.primary.withOpacity(isDark ? 0.4 : 0.3),
                width: 1.5,
              )
            : BorderSide.none,
      ),
      shadowColor:
          styles.showGlowEffect ? colors.primary.withOpacity(0.5) : null,
    );
  }

  /// 构建 AppBar 主题
  AppBarTheme _buildAppBarTheme(
    ThemeColors colors,
    ThemeStyles styles,
    bool isDark,
  ) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: isDark
          ? (colors.cardBackground ?? const Color(0xFF1E1E1E))
          : (colors.surface ?? Colors.white),
      foregroundColor: isDark ? colors.primary : Colors.black87,
      iconTheme: IconThemeData(color: colors.primary),
      titleTextStyle: TextStyle(
        color: isDark ? colors.primary : Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        shadows: styles.showGlowEffect && isDark
            ? [Shadow(color: colors.primary.withOpacity(0.5), blurRadius: 8)]
            : null,
      ),
    );
  }

  /// 构建 NavigationRail 主题
  NavigationRailThemeData _buildNavigationRailTheme(
    ThemeColors colors,
    ThemeStyles styles,
    bool isDark,
  ) {
    return NavigationRailThemeData(
      backgroundColor: isDark
          ? (colors.cardBackground ?? const Color(0xFF2C2C2C))
          : (colors.background ?? Colors.grey.shade50),
      indicatorColor: colors.primary.withOpacity(isDark ? 0.2 : 0.15),
      selectedIconTheme: IconThemeData(
        color: colors.primary,
        size: 28,
        shadows: styles.showGlowEffect && isDark
            ? [Shadow(color: colors.primary.withOpacity(0.8), blurRadius: 12)]
            : null,
      ),
      // ✅ 修复：提高未选中图标的可见度
      unselectedIconTheme: IconThemeData(
        color: isDark
            ? Colors.grey.shade400
            : Colors.grey.shade600, // 从 700 改为 400
        size: 24,
      ),
      selectedLabelTextStyle: TextStyle(
        color: colors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        shadows: styles.showGlowEffect && isDark
            ? [Shadow(color: colors.primary.withOpacity(0.5), blurRadius: 8)]
            : null,
      ),
      // ✅ 修复：提高未选中文字的可见度
      unselectedLabelTextStyle: TextStyle(
        color: isDark
            ? Colors.grey.shade400
            : Colors.grey.shade600, // 从 700 改为 400
        fontSize: 12,
      ),
    );
  }

  /// 构建 BottomNavigationBar 主题
  BottomNavigationBarThemeData _buildBottomNavTheme(
    ThemeColors colors,
    bool isDark,
    Color defaultCardBg,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark
          ? (colors.cardBackground ?? defaultCardBg)
          : (colors.surface ?? Colors.white),
      selectedItemColor: colors.primary,
      unselectedItemColor: isDark ? Colors.grey.shade700 : Colors.grey.shade600,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      elevation: 8,
    );
  }

  /// 构建 FloatingActionButton 主题
  FloatingActionButtonThemeData _buildFABTheme(
    ThemeColors colors,
    ThemeStyles styles,
  ) {
    return FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary ?? Colors.black,
      elevation: styles.cardElevation + 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(styles.buttonBorderRadius),
      ),
    );
  }

  /// 构建 ElevatedButton 主题
  ElevatedButtonThemeData _buildElevatedButtonTheme(
    ThemeColors colors,
    ThemeStyles styles,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary ??
            (colors.primary.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white), // ✅ 自动计算前景色
        elevation: styles.cardElevation,
        padding: styles.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(styles.buttonBorderRadius),
        ),
        shadowColor:
            styles.showGlowEffect ? colors.primary.withOpacity(0.5) : null,
      ),
    );
  }

  /// ✅ 新增：OutlinedButton 主题（用于次要按钮）
  OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ThemeColors colors,
    ThemeStyles styles,
    bool isDark,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.primary, width: 2),
        padding: styles.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(styles.buttonBorderRadius),
        ),
      ),
    );
  }

  /// ✅ 新增：TextButton 主题
  TextButtonThemeData _buildTextButtonTheme(
    ThemeColors colors,
    bool isDark,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// 构建 ListTile 主题
  ListTileThemeData _buildListTileTheme(
    ThemeColors colors,
    bool isDark,
  ) {
    return ListTileThemeData(
      iconColor: colors.primary,
      textColor: isDark ? Colors.white : Colors.black87,
      selectedTileColor: colors.primary.withOpacity(isDark ? 0.15 : 0.1),
      selectedColor: colors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// 构建 Text 主题
  TextTheme _buildTextTheme(ThemeColors colors, bool isDark) {
    return TextTheme(
      headlineLarge: TextStyle(
        color: isDark ? colors.primary : Colors.black87,
        fontWeight: FontWeight.bold,
        shadows: themeStyles.showGlowEffect && isDark
            ? [Shadow(color: colors.primary.withOpacity(0.5), blurRadius: 8)]
            : null,
      ),
      headlineMedium: TextStyle(
        color: isDark ? colors.primary : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: isDark ? colors.primary : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: isDark ? Colors.white70 : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: isDark ? Colors.white : Colors.black87),
      bodyMedium: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
      bodySmall: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
    );
  }
}

// ============================================================================
// 响应式布局配置
// ============================================================================

import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  final BuildContext context;

  ResponsiveBreakpoints(this.context);

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1025;

  bool isMobile() {
    return MediaQuery.of(context).size.width < mobile;
  }

  bool isTablet() {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  bool isDesktop() {
    return MediaQuery.of(context).size.width >= desktop;
  }

  bool isWideScreen() {
    return MediaQuery.of(context).size.width >= mobile;
  }

  double get padding => isDesktop()
      ? 48
      : isTablet()
          ? 32
          : 16;
  double get maxWidth => isDesktop()
      ? 1200
      : isTablet()
          ? 800
          : 600;
  double get iconSize => isDesktop()
      ? 140
      : isTablet()
          ? 100
          : 80;
  double get sectionSpacing => isDesktop() ? 48 : 32;
  double get cardSpacing => isDesktop() ? 32 : 24;

  int get gridColumns => isDesktop()
      ? 2
      : isTablet()
          ? 2
          : 1;
  double get gridAspectRatio => isDesktop()
      ? 3.5
      : isTablet()
          ? 3.0
          : 3.5;
  double? get gridItemHeight => isMobile() ? 80 : null;
}

// ============================================================================
// 窗口控制按钮组件（带国际化和动态提示）
// ============================================================================

import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import '../../utils/i18n/app_localization.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  bool isMaximized = false;

  @override
  void initState() {
    super.initState();
    // 定期检查窗口状态
    _startWindowStateCheck();
  }

  void _startWindowStateCheck() {
    // 立即检查一次
    _checkWindowState();

    // 每秒检查一次窗口状态
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _checkWindowState();
        _startWindowStateCheck();
      }
    });
  }

  void _checkWindowState() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final newMaximized = appWindow.isMaximized;
      if (newMaximized != isMaximized && mounted) {
        setState(() {
          isMaximized = newMaximized;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);

    final buttonColors = WindowButtonColors(
      iconNormal: Theme.of(context).colorScheme.onSurface,
      iconMouseOver: Theme.of(context).colorScheme.onPrimary,
      iconMouseDown: Theme.of(context).colorScheme.onPrimary,
      mouseOver: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      mouseDown: Theme.of(context).colorScheme.primary,
    );

    final closeButtonColors = WindowButtonColors(
      iconNormal: Theme.of(context).colorScheme.onSurface,
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white,
      mouseOver: Colors.red.shade400,
      mouseDown: Colors.red.shade700,
    );

    return Row(
      children: [
        Tooltip(
          message: localizations.translate('minimize'),
          waitDuration: const Duration(milliseconds: 500),
          preferBelow: false,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: MinimizeWindowButton(colors: buttonColors),
        ),
        Tooltip(
          message: isMaximized
              ? localizations.translate('restore')
              : localizations.translate('maximize'),
          waitDuration: const Duration(milliseconds: 500),
          preferBelow: false,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: MaximizeWindowButton(colors: buttonColors),
        ),
        Tooltip(
          message: localizations.translate('close'),
          waitDuration: const Duration(milliseconds: 500),
          preferBelow: false,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: CloseWindowButton(colors: closeButtonColors),
        ),
      ],
    );
  }
}

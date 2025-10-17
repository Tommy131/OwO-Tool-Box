// ============================================================================
// 应用入口
// ============================================================================
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error('Flutter错误', details.exception, details.stack);
  };

  try {
    AppLogger.info('应用启动 - 版本 2.1.0 (多平台布局 + 窗口控制)');
    runApp(const MyApp());

    // 初始化桌面窗口 (仅在桌面平台)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      doWhenWindowReady(() {
        const initialSize = Size(1200, 800);
        const minSize = Size(800, 600);

        appWindow.minSize = minSize;
        appWindow.size = initialSize;
        appWindow.alignment = Alignment.center;
        appWindow.title = 'OwO! System Tools';
        appWindow.show();

        AppLogger.info('桌面窗口初始化完成 - 自定义窗口控制');
      });
    }
  } catch (e, stackTrace) {
    AppLogger.error('应用启动失败', e, stackTrace);
  }
}

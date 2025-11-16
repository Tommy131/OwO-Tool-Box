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
// 应用入口
// ============================================================================
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error('Flutter错误', details.exception, details.stack);
  };

  try {
    AppLogger.info('应用启动 - 版本 2.1.0 (多平台布局 + 窗口控制)');

    // 初始化桌面窗口 (仅在桌面平台)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      doWhenWindowReady(() {
        const initialSize = Size(1200, 800);
        const minSize = Size(800, 600);

        appWindow.minSize = minSize;
        appWindow.size = initialSize;
        appWindow.alignment = Alignment.center;
        appWindow.title = 'OwO! Tool Box';
        appWindow.show();

        AppLogger.info('桌面窗口初始化完成 - 自定义窗口控制');
      });
    }

    // 启动应用程序实例
    runApp(const MyApp());
  } catch (e, stackTrace) {
    AppLogger.error('应用启动失败', e, stackTrace);
  }
}

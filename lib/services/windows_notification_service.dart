/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-12 23:56:52
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-12 23:56:52
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// lib/services/windows_notification_service.dart
import 'dart:io';

class WindowsNotificationService {
  static void showNotification(String title, String message) {
    if (!Platform.isWindows) return;

    // 使用 PowerShell 显示 Windows 10/11 原生通知
    final script = '''
    Add-Type -AssemblyName System.Windows.Forms
    \$notification = New-Object System.Windows.Forms.NotifyIcon
    \$notification.Icon = [System.Drawing.SystemIcons]::Information
    \$notification.BalloonTipTitle = "$title"
    \$notification.BalloonTipText = "$message"
    \$notification.Visible = \$true
    \$notification.ShowBalloonTip(5000)
    Start-Sleep -Seconds 6
    \$notification.Dispose()
    ''';

    try {
      Process.run(
        'powershell.exe',
        ['-NoProfile', '-Command', script],
        runInShell: true,
      );
    } catch (e) {
      // print('Windows 通知失败: $e');
    }
  }
}

// ============================================================================
// 状态栏组件 - StatusBar
// ============================================================================

import 'package:flutter/material.dart';

/// 状态栏组件
///
/// 使用示例:
/// ```dart
/// StatusBar(
///   message: '正在同步数据...',
///   type: StatusBarType.loading,
/// )
/// ```
enum StatusBarType {
  info,
  success,
  warning,
  error,
  loading,
}

class StatusBar extends StatelessWidget {
  final String message;
  final StatusBarType type;
  final VoidCallback? onDismiss;

  const StatusBar({
    super.key,
    required this.message,
    this.type = StatusBarType.info,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData? icon;

    switch (type) {
      case StatusBarType.info:
        backgroundColor = Colors.blue;
        icon = Icons.info_outline;
        break;
      case StatusBarType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case StatusBarType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning_amber;
        break;
      case StatusBarType.error:
        backgroundColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case StatusBarType.loading:
        backgroundColor = Colors.blue.shade700;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (type == StatusBarType.loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (icon != null)
            Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, color: textColor, size: 20),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

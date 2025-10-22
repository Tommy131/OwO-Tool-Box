import 'package:flutter/material.dart';

class CustomSnackBar {
  final BuildContext context;
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;
  final Duration duration;

  /// 显示通知栏
  const CustomSnackBar(
    this.context, {
    required this.message,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.icon = Icons.info_outline,
    this.duration = const Duration(seconds: 2),
  });

  void showModern() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
              message,
              style: TextStyle(color: textColor),
            )),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void showNormal() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }
}

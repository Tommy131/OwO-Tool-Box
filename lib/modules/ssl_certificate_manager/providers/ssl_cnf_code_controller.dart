import 'package:flutter/material.dart';

class OpenSslCnfCodeController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = (style ?? const TextStyle()).copyWith(
      fontFamily: 'monospace',
      fontSize: 12,
      height: 1.4,
    );
    if (withComposing &&
        value.composing.isValid &&
        !value.composing.isCollapsed) {
      // 输入法合成阶段退回系统渲染，避免中间插入/删除时文本错位。
      return super.buildTextSpan(
        context: context,
        style: baseStyle,
        withComposing: withComposing,
      );
    }
    final lines = text.split('\n');
    final children = <InlineSpan>[];
    for (int i = 0; i < lines.length; i++) {
      children.add(_highlightLine(lines[i], baseStyle));
      if (i != lines.length - 1) {
        children.add(TextSpan(text: '\n', style: baseStyle));
      }
    }
    return TextSpan(style: baseStyle, children: children);
  }

  TextSpan _highlightLine(String line, TextStyle baseStyle) {
    final trimmed = line.trimLeft();
    final commentColor = Colors.green.shade700;
    final sectionColor = Colors.purple.shade700;
    final keyColor = Colors.blue.shade700;
    final valueColor = Colors.orange.shade800;

    if (trimmed.startsWith('#')) {
      return TextSpan(
        text: line,
        style: baseStyle.copyWith(color: commentColor),
      );
    }
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      return TextSpan(
        text: line,
        style: baseStyle.copyWith(
          color: sectionColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    final eqIndex = line.indexOf('=');
    if (eqIndex > 0) {
      final keyArea = line.substring(0, eqIndex);
      final keyTextEnd = keyArea.replaceFirst(RegExp(r'[\t ]+$'), '').length;
      final key = keyArea.substring(0, keyTextEnd);
      final gap = keyArea.substring(keyTextEnd);
      final sep = line.substring(eqIndex, eqIndex + 1);
      final value = line.substring(eqIndex + 1);
      return TextSpan(
        children: [
          TextSpan(
            text: key,
            style: baseStyle.copyWith(color: keyColor),
          ),
          TextSpan(text: gap, style: baseStyle),
          TextSpan(text: sep, style: baseStyle),
          TextSpan(
            text: value,
            style: baseStyle.copyWith(color: valueColor),
          ),
        ],
      );
    }
    return TextSpan(text: line, style: baseStyle);
  }
}

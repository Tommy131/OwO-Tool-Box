import 'package:flutter/material.dart';

import '../../../core/services/localization_service.dart';
import '../localization/localization_keys.dart';
import '../providers/ssl_certificate_manager_provider.dart';

/// 差异比较对话框中的行类型
enum _DiffLineType { same, added, removed }

/// 差异比较对话框中的行模型
class _DiffLine {
  final int? oldLine;
  final int? newLine;
  final String text;
  final _DiffLineType type;

  _DiffLine({
    this.oldLine,
    this.newLine,
    required this.text,
    required this.type,
  });

  String get marker {
    switch (type) {
      case _DiffLineType.added:
        return '+';
      case _DiffLineType.removed:
        return '-';
      case _DiffLineType.same:
        return ' ';
    }
  }
}

/// 证书配置文件差异比较对话框
class CnfDiffDialog extends StatelessWidget {
  final SslCertificateManagerProvider provider;

  const CnfDiffDialog({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final before = provider.savedCnfContent;
    final after = provider.cnfEditorController.text;
    final lines = _buildDiffLines(before, after);
    final hasChanges = lines.any((e) => e.type != _DiffLineType.same);

    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(LocalizationKeys.compareChanges.tr(context)),
      content: SizedBox(
        width: 980,
        height: 560,
        child: !hasChanges
            ? Center(
                child: Text(LocalizationKeys.noChangesDetected.tr(context)),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 920,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final line in lines)
                          Container(
                            color: _diffBgColor(theme, line.type),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 1,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 行号
                                SizedBox(
                                  width: 54,
                                  child: Text(
                                    _diffDisplayLineNumber(line),
                                    textAlign: TextAlign.right,
                                    style: _diffNoStyle(theme),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 标记符 (+/-)
                                SizedBox(
                                  width: 14,
                                  child: Text(
                                    line.marker,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      color: _diffMarkerColor(line.type),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 文本内容
                                Expanded(
                                  child: SelectableText.rich(
                                    _highlightCnfLine(
                                      line.text,
                                      theme,
                                      baseColor: _diffTextColor(
                                        theme,
                                        line.type,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocalizationKeys.close.tr(context)),
        ),
      ],
    );
  }

  /// 构建差异比较行
  List<_DiffLine> _buildDiffLines(String before, String after) {
    final bLines = before.split('\n');
    final aLines = after.split('\n');
    final result = <_DiffLine>[];

    int i = 0, j = 0;
    while (i < bLines.length || j < aLines.length) {
      if (i < bLines.length && j < aLines.length && bLines[i] == aLines[j]) {
        result.add(
          _DiffLine(
            oldLine: i + 1,
            newLine: j + 1,
            text: bLines[i],
            type: _DiffLineType.same,
          ),
        );
        i++;
        j++;
      } else if (i < bLines.length &&
          (j >= aLines.length || !aLines.sublist(j).contains(bLines[i]))) {
        result.add(
          _DiffLine(
            oldLine: i + 1,
            text: bLines[i],
            type: _DiffLineType.removed,
          ),
        );
        i++;
      } else {
        result.add(
          _DiffLine(newLine: j + 1, text: aLines[j], type: _DiffLineType.added),
        );
        j++;
      }
    }
    return result;
  }

  /// 差异比较行的高亮逻辑 (复用 cnf 编辑器的规则)
  TextSpan _highlightCnfLine(
    String line,
    ThemeData theme, {
    required Color baseColor,
  }) {
    final mono = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      fontSize: 12,
      color: baseColor,
      height: 1.4,
    );
    final trimmed = line.trimLeft();
    final commentColor = Colors.green.shade700;
    final sectionColor = Colors.purple.shade700;
    final keyColor = Colors.blue.shade700;
    final valueColor = Colors.orange.shade800;

    if (trimmed.startsWith('#')) {
      return TextSpan(
        text: line,
        style: mono?.copyWith(color: commentColor),
      );
    }
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      return TextSpan(
        text: line,
        style: mono?.copyWith(color: sectionColor, fontWeight: FontWeight.w600),
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
            style: mono?.copyWith(color: keyColor),
          ),
          TextSpan(
            text: gap,
            style: mono?.copyWith(color: baseColor),
          ),
          TextSpan(
            text: sep,
            style: mono?.copyWith(color: baseColor),
          ),
          TextSpan(
            text: value,
            style: mono?.copyWith(color: valueColor),
          ),
        ],
      );
    }
    return TextSpan(text: line, style: mono);
  }

  TextStyle? _diffNoStyle(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
    );
  }

  String _diffDisplayLineNumber(_DiffLine line) {
    return (line.newLine ?? line.oldLine)?.toString() ?? '';
  }

  Color _diffBgColor(ThemeData theme, _DiffLineType type) {
    if (type == _DiffLineType.added) {
      return Colors.green.withValues(alpha: 0.10);
    }
    if (type == _DiffLineType.removed) {
      return Colors.red.withValues(alpha: 0.10);
    }
    return Colors.transparent;
  }

  Color _diffMarkerColor(_DiffLineType type) {
    if (type == _DiffLineType.added) return Colors.green;
    if (type == _DiffLineType.removed) return Colors.red;
    return Colors.grey;
  }

  Color _diffTextColor(ThemeData theme, _DiffLineType type) {
    if (type == _DiffLineType.added) return Colors.green.shade900;
    if (type == _DiffLineType.removed) return Colors.red.shade900;
    return theme.colorScheme.onSurface;
  }
}

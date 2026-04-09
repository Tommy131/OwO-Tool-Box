import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';

/// Line type in the diff view.
enum DiffLineType { same, added, removed }

/// A single line in the diff view.
class DiffLine {
  DiffLine({
    required this.type,
    required this.text,
    required this.oldLine,
    required this.newLine,
  });

  final DiffLineType type;
  final String text;
  final int? oldLine;
  final int? newLine;

  String get marker {
    if (type == DiffLineType.added) return '+';
    if (type == DiffLineType.removed) return '-';
    return ' ';
  }
}

/// Dialog that shows a side-by-side diff of CNF template changes.
class CnfDiffDialog extends StatelessWidget {
  const CnfDiffDialog._({required this.before, required this.after});

  final String before;
  final String after;

  /// Show the diff dialog for the given provider's saved vs. current content.
  static Future<void> show(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => CnfDiffDialog._(
        before: provider.savedCnfContent,
        after: provider.cnfEditorController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = _buildDiffLines(before, after);
    final hasChanges = lines.any((e) => e.type != DiffLineType.same);
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
                                SizedBox(
                                  width: 54,
                                  child: Text(
                                    _diffDisplayLineNumber(line),
                                    textAlign: TextAlign.right,
                                    style: _diffNoStyle(theme),
                                  ),
                                ),
                                const SizedBox(width: 8),
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

  // -- Diff computation (LCS-based) --

  static List<DiffLine> _buildDiffLines(String before, String after) {
    final beforeLines = before.split('\n');
    final afterLines = after.split('\n');
    final m = beforeLines.length;
    final n = afterLines.length;

    final dp = List.generate(
      m + 1,
      (_) => List<int>.filled(n + 1, 0, growable: false),
      growable: false,
    );

    for (int i = m - 1; i >= 0; i--) {
      for (int j = n - 1; j >= 0; j--) {
        if (beforeLines[i] == afterLines[j]) {
          dp[i][j] = dp[i + 1][j + 1] + 1;
        } else {
          final down = dp[i + 1][j];
          final right = dp[i][j + 1];
          dp[i][j] = down > right ? down : right;
        }
      }
    }

    int i = 0;
    int j = 0;
    int oldLine = 1;
    int newLine = 1;
    final result = <DiffLine>[];

    while (i < m && j < n) {
      if (beforeLines[i] == afterLines[j]) {
        result.add(
          DiffLine(
            type: DiffLineType.same,
            text: beforeLines[i],
            oldLine: oldLine,
            newLine: newLine,
          ),
        );
        i++;
        j++;
        oldLine++;
        newLine++;
      } else if (dp[i + 1][j] >= dp[i][j + 1]) {
        result.add(
          DiffLine(
            type: DiffLineType.removed,
            text: beforeLines[i],
            oldLine: oldLine,
            newLine: null,
          ),
        );
        i++;
        oldLine++;
      } else {
        result.add(
          DiffLine(
            type: DiffLineType.added,
            text: afterLines[j],
            oldLine: null,
            newLine: newLine,
          ),
        );
        j++;
        newLine++;
      }
    }

    while (i < m) {
      result.add(
        DiffLine(
          type: DiffLineType.removed,
          text: beforeLines[i],
          oldLine: oldLine,
          newLine: null,
        ),
      );
      i++;
      oldLine++;
    }

    while (j < n) {
      result.add(
        DiffLine(
          type: DiffLineType.added,
          text: afterLines[j],
          oldLine: null,
          newLine: newLine,
        ),
      );
      j++;
      newLine++;
    }

    return result;
  }

  // -- Syntax highlighting for CNF lines --

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

  // -- Diff styling helpers --

  TextStyle? _diffNoStyle(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
    );
  }

  String _diffDisplayLineNumber(DiffLine line) {
    return (line.newLine ?? line.oldLine)?.toString() ?? '';
  }

  Color _diffBgColor(ThemeData theme, DiffLineType type) {
    if (type == DiffLineType.added) {
      return Colors.green.withValues(alpha: 0.10);
    }
    if (type == DiffLineType.removed) {
      return Colors.red.withValues(alpha: 0.10);
    }
    return Colors.transparent;
  }

  Color _diffMarkerColor(DiffLineType type) {
    if (type == DiffLineType.added) return Colors.green.shade700;
    if (type == DiffLineType.removed) return Colors.red.shade700;
    return Colors.grey.shade600;
  }

  Color _diffTextColor(ThemeData theme, DiffLineType type) {
    if (type == DiffLineType.added) return Colors.green.shade900;
    if (type == DiffLineType.removed) return Colors.red.shade900;
    return theme.colorScheme.onSurface;
  }
}

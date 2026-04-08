part of '../ssl_certificate_manager_page.dart';

/// Diff 结构与算法：提供行级对比结果给模板弹窗复用。
enum _DiffLineType { same, added, removed }

class _DiffLine {
  _DiffLine({
    required this.type,
    required this.text,
    required this.oldLine,
    required this.newLine,
  });

  final _DiffLineType type;
  final String text;
  final int? oldLine;
  final int? newLine;

  String get marker {
    if (type == _DiffLineType.added) return '+';
    if (type == _DiffLineType.removed) return '-';
    return ' ';
  }
}

List<_DiffLine> _buildDiffLines(String before, String after) {
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
  final result = <_DiffLine>[];

  while (i < m && j < n) {
    if (beforeLines[i] == afterLines[j]) {
      result.add(
        _DiffLine(
          type: _DiffLineType.same,
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
        _DiffLine(
          type: _DiffLineType.removed,
          text: beforeLines[i],
          oldLine: oldLine,
          newLine: null,
        ),
      );
      i++;
      oldLine++;
    } else {
      result.add(
        _DiffLine(
          type: _DiffLineType.added,
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
      _DiffLine(
        type: _DiffLineType.removed,
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
      _DiffLine(
        type: _DiffLineType.added,
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

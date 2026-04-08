part of '../ssl_certificate_manager_page.dart';

/// OpenSSL 模板编辑区：包含行号、高亮编辑与对比弹窗。
extension _SslPageOpenSslTemplateSection on _SslCertificateManagerPageState {
  Widget _buildOpenSslTemplateTab(SslCertificateManagerProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationKeys.defaultOpenSslCnf.tr(context),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: PrimaryScrollController.none(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                padding: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.15),
                                  border: Border(
                                    right: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ),
                                child: ClipRect(
                                  child: AnimatedBuilder(
                                    animation: _cnfEditorScrollController,
                                    builder: (context, child) {
                                      final offset =
                                          _cnfEditorScrollController.hasClients
                                          ? _cnfEditorScrollController.offset
                                          : 0.0;
                                      return Transform.translate(
                                        offset: Offset(0, -offset),
                                        child: child,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.5,
                                      ),
                                      child:
                                          ValueListenableBuilder<
                                            TextEditingValue
                                          >(
                                            valueListenable:
                                                provider.cnfEditorController,
                                            builder: (context, _, __) {
                                              final lines = provider
                                                  .cnfEditorController
                                                  .text
                                                  .split('\n')
                                                  .length;
                                              return OverflowBox(
                                                alignment: Alignment.topRight,
                                                minHeight: 0,
                                                maxHeight: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    for (
                                                      int i = 1;
                                                      i <= lines;
                                                      i++
                                                    )
                                                      Text(
                                                        '$i',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              fontFamily:
                                                                  'monospace',
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onSurface
                                                                      .withValues(
                                                                        alpha:
                                                                            0.45,
                                                                      ),
                                                              height: 1.4,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Scrollbar(
                                  controller: _cnfEditorScrollController,
                                  thumbVisibility: true,
                                  child: TextField(
                                    controller: provider.cnfEditorController,
                                    scrollController:
                                        _cnfEditorScrollController,
                                    scrollPhysics:
                                        const ClampingScrollPhysics(),
                                    maxLines: null,
                                    expands: true,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: provider.saveDefaultCnf,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(LocalizationKeys.saveCnf.tr(context)),
                        ),
                        OutlinedButton.icon(
                          onPressed: provider.regenerateDefaultCnf,
                          icon: const Icon(Icons.auto_fix_high_outlined),
                          label: Text(
                            LocalizationKeys.regenerateCnf.tr(context),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _showCnfDiffDialog(provider),
                          icon: const Icon(Icons.compare_arrows_outlined),
                          label: Text(
                            LocalizationKeys.compareChanges.tr(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Future<void> _showCnfDiffDialog(
    SslCertificateManagerProvider provider,
  ) async {
    final before = provider.savedCnfContent;
    final after = provider.cnfEditorController.text;
    final lines = _buildDiffLines(before, after);
    final hasChanges = lines.any((e) => e.type != _DiffLineType.same);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(LocalizationKeys.compareChanges.tr(ctx)),
          content: SizedBox(
            width: 980,
            height: 560,
            child: !hasChanges
                ? Center(
                    child: Text(LocalizationKeys.noChangesDetected.tr(ctx)),
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
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontFamily: 'monospace',
                                              color: _diffMarkerColor(
                                                line.type,
                                              ),
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
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(LocalizationKeys.close.tr(context)),
            ),
          ],
        );
      },
    );
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
    if (type == _DiffLineType.added) return Colors.green.shade700;
    if (type == _DiffLineType.removed) return Colors.red.shade700;
    return Colors.grey.shade600;
  }

  Color _diffTextColor(ThemeData theme, _DiffLineType type) {
    if (type == _DiffLineType.added) return Colors.green.shade900;
    if (type == _DiffLineType.removed) return Colors.red.shade900;
    return theme.colorScheme.onSurface;
  }
}

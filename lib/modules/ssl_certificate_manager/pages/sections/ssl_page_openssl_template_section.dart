part of '../ssl_certificate_manager_page.dart';

/// OpenSSL 模板编辑区：包含行号、高亮编辑与对比弹窗。
extension _SslPageOpenSslTemplateSection on _SslCertificateManagerPageState {
  Widget _buildOpenSslTemplateTab(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.08),
                    primaryColor.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.code_outlined, size: 18,
                        color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      LocalizationKeys.defaultOpenSslCnf.tr(context),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: provider.cnfEditorController,
                    builder: (context, value, _) {
                      final isModified = value.text != provider.savedCnfContent;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isModified
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isModified
                                ? Colors.orange.withValues(alpha: 0.3)
                                : Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isModified
                                  ? Icons.edit_outlined
                                  : Icons.check_circle_outline,
                              size: 14,
                              color: isModified ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isModified
                                  ? LocalizationKeys.editorUnsaved.tr(context)
                                  : LocalizationKeys.editorSaved.tr(context),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isModified ? Colors.orange : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Toolbar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: provider.cnfEditorController,
                    builder: (context, value, _) {
                      final lineCount = value.text.split('\n').length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          LocalizationKeys.editorLineCount
                              .tr(context)
                              .replaceAll('@count', '$lineCount'),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  _buildToolbarButton(
                    icon: Icons.save_outlined,
                    label: LocalizationKeys.saveCnf.tr(context),
                    onPressed: provider.saveDefaultCnf,
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildToolbarButton(
                    icon: Icons.auto_fix_high_outlined,
                    label: LocalizationKeys.regenerateCnf.tr(context),
                    onPressed: provider.regenerateDefaultCnf,
                    theme: theme,
                    outlined: true,
                  ),
                  const SizedBox(width: 6),
                  _buildToolbarButton(
                    icon: Icons.compare_arrows_outlined,
                    label: LocalizationKeys.compareChanges.tr(context),
                    onPressed: () => _showCnfDiffDialog(provider),
                    theme: theme,
                    tonal: true,
                  ),
                ],
              ),
            ),
            // Editor (takes remaining space)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: PrimaryScrollController.none(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          padding: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.15),
                            border: Border(
                              right: BorderSide(
                                color: theme.dividerColor
                                    .withValues(alpha: 0.2),
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
                                child: ValueListenableBuilder<
                                  TextEditingValue
                                >(
                                  valueListenable:
                                      provider.cnfEditorController,
                                  builder: (context, _, __) {
                                    final lines = provider
                                        .cnfEditorController.text
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
                                          for (int i = 1; i <= lines; i++)
                                            Text(
                                              '$i',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontFamily: 'monospace',
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withValues(
                                                          alpha: 0.45,
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
                              scrollController: _cnfEditorScrollController,
                              scrollPhysics: const ClampingScrollPhysics(),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
    bool outlined = false,
    bool tonal = false,
  }) {
    if (tonal) {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );
    }
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

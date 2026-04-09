import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../../widgets/editor/cnf_diff_dialog.dart';
import '../../widgets/editor/cnf_editor.dart';

/// Tab page for editing the OpenSSL CNF template.
class OpenSslTemplateTab extends StatefulWidget {
  const OpenSslTemplateTab({super.key});

  @override
  State<OpenSslTemplateTab> createState() => _OpenSslTemplateTabState();
}

class _OpenSslTemplateTabState extends State<OpenSslTemplateTab> {
  final ScrollController _cnfEditorScrollController = ScrollController();

  @override
  void dispose() {
    _cnfEditorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final provider = context.watch<SslCertificateManagerProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: primaryColor.withValues(alpha: 0.15)),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.08),
                    primaryColor.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.code_outlined,
                        size: 18, color: primaryColor),
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
                      final isModified =
                          value.text != provider.savedCnfContent;
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
                                ? Colors.orange
                                    .withValues(alpha: 0.3)
                                : Colors.green
                                    .withValues(alpha: 0.3),
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
                              color: isModified
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isModified
                                  ? LocalizationKeys.editorUnsaved
                                      .tr(context)
                                  : LocalizationKeys.editorSaved
                                      .tr(context),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isModified
                                    ? Colors.orange
                                    : Colors.green,
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
                      final lineCount =
                          value.text.split('\n').length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme
                              .colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          LocalizationKeys.editorLineCount
                              .tr(context)
                              .replaceAll(
                                  '@count', '$lineCount'),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  buildToolbarButton(
                    icon: Icons.save_outlined,
                    label: LocalizationKeys.saveCnf.tr(context),
                    onPressed: provider.saveDefaultCnf,
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  buildToolbarButton(
                    icon: Icons.auto_fix_high_outlined,
                    label:
                        LocalizationKeys.regenerateCnf.tr(context),
                    onPressed: provider.regenerateDefaultCnf,
                    theme: theme,
                    outlined: true,
                  ),
                  const SizedBox(width: 6),
                  buildToolbarButton(
                    icon: Icons.compare_arrows_outlined,
                    label: LocalizationKeys.compareChanges
                        .tr(context),
                    onPressed: () =>
                        CnfDiffDialog.show(context, provider),
                    theme: theme,
                    tonal: true,
                  ),
                ],
              ),
            ),
            // Editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: CnfEditor(
                  controller: provider.cnfEditorController,
                  scrollController: _cnfEditorScrollController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

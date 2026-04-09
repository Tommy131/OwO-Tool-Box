import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../../../core/widgets/common/dialog.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../../widgets/shared/premium_card.dart';
import '../../widgets/form/ssl_text_field.dart';

/// Tab page for importing and signing CSR files.
class CsrImportTab extends StatelessWidget {
  const CsrImportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SslCertificateManagerProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          SslGradientHeader(
            title: LocalizationKeys.importCsrTitle.tr(context),
            subtitle: LocalizationKeys.importCsrSubtitle.tr(context),
            icon: Icons.upload_file_outlined,
          ),
          const SizedBox(height: 16),
          SslPremiumCard(
            title: LocalizationKeys.importCsr.tr(context),
            icon: Icons.description_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SslTextField(
                  controller: provider.csrFilePathController,
                  label: LocalizationKeys.csrFilePath.tr(context),
                  suffix: IconButton(
                    icon: const Icon(Icons.upload_file),
                    onPressed: () async {
                      final path = await _pickCsrFile(context);
                      if (path != null) {
                        provider.csrFilePathController.text = path;
                      }
                    },
                  ),
                  requiredField: true,
                ),
                SslTextField(
                  controller: provider.csrValidDaysController,
                  label: LocalizationKeys.validDays.tr(context),
                  requiredField: true,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => _handleSignCsr(context, provider),
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(LocalizationKeys.signCsr.tr(context)),
                ),
                if (provider.infoMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    provider.infoMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _pickCsrFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csr', 'pem'],
      allowMultiple: false,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    final lower = p.basename(path).toLowerCase();
    if (lower.endsWith('.csr') || lower.endsWith('.pem')) {
      return path;
    }
    if (!context.mounted) return null;
    await _showSimpleDialog(
      context,
      LocalizationKeys.fileTypeNotAllowed.tr(context),
      LocalizationKeys.csrFileAllowedOnly.tr(context),
    );
    return null;
  }

  Future<void> _handleSignCsr(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) async {
    final csrPath = provider.csrFilePathController.text.trim();
    if (csrPath.isEmpty) {
      _showInlineMessage(context, LocalizationKeys.csrFilePath.tr(context));
      return;
    }
    final days = int.tryParse(provider.csrValidDaysController.text.trim());
    if (days == null || days <= 0) {
      _showInlineMessage(
        context,
        LocalizationKeys.validationValidDays.tr(context),
      );
      return;
    }

    final confirmed = await showAdvancedConfirmDialog(
      context: context,
      style: ConfirmDialogStyle.darkNeon,
      title: LocalizationKeys.importCsrTitle.tr(context),
      content:
          '${LocalizationKeys.csrFilePath.tr(context)}: $csrPath\n${LocalizationKeys.validDays.tr(context)}: $days',
      icon: Icons.verified_outlined,
      confirmText: LocalizationKeys.signCsr.tr(context),
      cancelText: LocalizationKeys.cancel.tr(context),
    );
    if (!context.mounted || confirmed != true) return;

    showLoadingDialog(
      context: context,
      style: ConfirmDialogStyle.darkNeon,
      title: LocalizationKeys.signCsr.tr(context),
      content: LocalizationKeys.issuingWait.tr(context),
    );

    final result = await provider.signExternalCsr(
      csrFilePath: csrPath,
      validDays: days,
    );
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (result.success) {
      provider.csrFilePathController.clear();
      provider.csrValidDaysController.clear();
      await showAdvancedConfirmDialog(
        context: context,
        style: ConfirmDialogStyle.darkNeon,
        title: LocalizationKeys.signCsrSuccess.tr(context),
        content: result.message,
        icon: Icons.check_circle_outline,
        confirmText: LocalizationKeys.confirm.tr(context),
        cancelText: '',
      );
    } else {
      await showAdvancedConfirmDialog(
        context: context,
        style: ConfirmDialogStyle.darkNeon,
        title: LocalizationKeys.signCsrFailed.tr(context),
        content: result.message,
        icon: Icons.error_outline,
        confirmColor: Colors.redAccent,
        confirmText: LocalizationKeys.dialogAcknowledge.tr(context),
        cancelText: '',
      );
    }
  }

  Future<void> _showSimpleDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(LocalizationKeys.confirm.tr(context)),
            ),
          ],
        );
      },
    );
  }

  void _showInlineMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

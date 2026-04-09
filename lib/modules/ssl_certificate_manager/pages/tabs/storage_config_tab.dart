import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../../widgets/shared/premium_card.dart';
import '../../widgets/shared/section_container.dart';
import '../../widgets/form/ssl_text_field.dart';

/// Tab page for storage configuration and CRL management.
class StorageConfigTab extends StatelessWidget {
  const StorageConfigTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SslCertificateManagerProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          SslPremiumCard(
            title: LocalizationKeys.storageConfig.tr(context),
            icon: Icons.folder_outlined,
            child: Column(
              children: [
                SslTextField(
                  controller: provider.storagePathController,
                  label: LocalizationKeys.setupStoragePath.tr(context),
                  suffix: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      final path = await _pickDirectory(context);
                      if (path != null) {
                        await provider.changeStoragePath(path);
                      }
                    },
                  ),
                ),
                SslTextField(
                  controller: provider.rootCANameController,
                  label: LocalizationKeys.rootCaName.tr(context),
                ),
                SslTextField(
                  controller: provider.rootCACertPathController,
                  label: LocalizationKeys.rootCaCertPath.tr(context),
                ),
                SslTextField(
                  controller: provider.rootCAKeyPathController,
                  label: LocalizationKeys.rootCaKeyPath.tr(context),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => _handleCompleteInitialization(context, provider),
                  icon: const Icon(Icons.settings_backup_restore),
                  label: Text(LocalizationKeys.setupComplete.tr(context)),
                ),
              ],
            ),
          ),
          _buildCrlManagementCard(context, provider),
        ],
      ),
    );
  }

  Widget _buildCrlManagementCard(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) {
    final theme = Theme.of(context);
    final crl = provider.crlState;
    final crlDaysController = TextEditingController(
      text: crl.crlDays.toString(),
    );

    final lastGenerated = crl.lastGeneratedAt;
    final lastGeneratedText = lastGenerated != null
        ? lastGenerated.toLocal().toString().split('.').first
        : LocalizationKeys.crlNotGenerated.tr(context);

    return SslPremiumCard(
      title: LocalizationKeys.crlManagement.tr(context),
      icon: Icons.playlist_remove_outlined,
      accentColor: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SslInfoRow(
            label: LocalizationKeys.crlFilePath.tr(context),
            value:
                crl.crlFilePath ?? LocalizationKeys.crlNotGenerated.tr(context),
            copyable: crl.crlFilePath != null,
          ),
          SslInfoRow(
            label: LocalizationKeys.crlLastGenerated.tr(context),
            value: lastGeneratedText,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 160,
                child: TextField(
                  controller: crlDaysController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: LocalizationKeys.crlDays.tr(context),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final days = int.tryParse(
                          crlDaysController.text.trim(),
                        );
                        final success = await provider
                            .requestGenerateCrlWithPrompt(
                              context,
                              crlDays: days,
                            );
                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                LocalizationKeys.crlGenerateSuccess.tr(context),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else if (provider.infoMessage.startsWith('CRL 生成失败')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                LocalizationKeys.crlGenerateFailed.tr(context),
                              ),
                              backgroundColor: theme.colorScheme.error,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.refresh_outlined),
                label: Text(LocalizationKeys.generateCrl.tr(context)),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _pickDirectory(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) return null;
    return FilePicker.platform.getDirectoryPath(
      dialogTitle: LocalizationKeys.setupStoragePath.tr(context),
    );
  }

  Future<void> _handleCompleteInitialization(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) async {
    if (provider.importRootCA) {
      final validation = await provider.inspectImportedRootCA();
      if (!context.mounted) return;
      if (!validation.isValid) {
        await _showSimpleDialog(
          context,
          LocalizationKeys.importRootCaFailed.tr(context),
          validation.message,
        );
        return;
      }
      final confirmed = await _showRootCaConfirmDialog(context, validation);
      if (!context.mounted || !confirmed) return;
      await provider.completeInitialization();
      if (!context.mounted) return;
      if (!provider.isInitialized && provider.infoMessage.trim().isNotEmpty) {
        await _showSimpleDialog(
          context,
          LocalizationKeys.initFailed.tr(context),
          provider.infoMessage,
        );
      }
      return;
    }

    if (provider.isRootPasswordEmpty) {
      final acceptedRisk = await _showEmptyPasswordRiskDialog(context);
      if (!context.mounted || !acceptedRisk) return;
    }
    await provider.completeInitialization();
    if (!context.mounted) return;
    if (!provider.isInitialized && provider.infoMessage.trim().isNotEmpty) {
      await _showSimpleDialog(
        context,
        LocalizationKeys.initFailed.tr(context),
        provider.infoMessage,
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

  Future<bool> _showRootCaConfirmDialog(
    BuildContext context,
    RootCaValidationResult validation,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(LocalizationKeys.importRootCaConfirmTitle.tr(context)),
          content: SizedBox(
            width: 640,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: validation.details.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SelectableText('${entry.key}: ${entry.value}'),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(LocalizationKeys.cancel.tr(context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(LocalizationKeys.confirmAndContinue.tr(context)),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<bool> _showEmptyPasswordRiskDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(LocalizationKeys.emptyPasswordRiskTitle.tr(context)),
          content: Text(LocalizationKeys.emptyPasswordRiskContent.tr(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(LocalizationKeys.backToFillPassword.tr(context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(LocalizationKeys.continueWithRisk.tr(context)),
            ),
          ],
        );
      },
    );
    return result == true;
  }
}

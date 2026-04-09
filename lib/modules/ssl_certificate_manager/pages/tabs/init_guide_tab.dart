import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../../widgets/shared/premium_card.dart';
import '../../widgets/form/ssl_text_field.dart';

/// Tab page shown when the SSL module is not yet initialized.
class InitGuideTab extends StatefulWidget {
  const InitGuideTab({super.key});

  @override
  State<InitGuideTab> createState() => _InitGuideTabState();
}

class _InitGuideTabState extends State<InitGuideTab> {
  bool _showRootCaPassword = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SslCertificateManagerProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          SslGradientHeader(
            title: LocalizationKeys.initWelcomeTitle.tr(context),
            subtitle: LocalizationKeys.initWelcomeSubtitle.tr(context),
            icon: Icons.verified_user,
          ),
          const SizedBox(height: 20),
          SslPremiumCard(
            title: LocalizationKeys.setupStoragePath.tr(context),
            icon: Icons.folder_outlined,
            child: SslTextField(
              controller: provider.storagePathController,
              label: LocalizationKeys.setupStoragePath.tr(context),
              suffix: IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: () async {
                  final path = await _pickDirectory();
                  if (path != null) {
                    await provider.changeStoragePath(path);
                  }
                },
              ),
            ),
          ),
          SslPremiumCard(
            title: LocalizationKeys.setupRootCA.tr(context),
            icon: Icons.security_outlined,
            child: Column(
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text(LocalizationKeys.generateRootCA.tr(context)),
                      icon: const Icon(Icons.auto_fix_high_outlined),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text(LocalizationKeys.importRootCA.tr(context)),
                      icon: const Icon(Icons.upload_file_outlined),
                    ),
                  ],
                  selected: {provider.importRootCA},
                  onSelectionChanged: (selected) {
                    provider.setImportRootCA(selected.first);
                  },
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(height: 16),
                SslTextField(
                  controller: provider.rootCANameController,
                  label: LocalizationKeys.rootCaName.tr(context),
                ),
                SslTextField(
                  controller: provider.rootCAPasswordController,
                  label: LocalizationKeys.rootCaPassword.tr(context),
                  obscureRootCaPassword: !_showRootCaPassword,
                  onToggleRootCaPassword: () {
                    setState(() {
                      _showRootCaPassword = !_showRootCaPassword;
                    });
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: provider.importRootCA
                      ? Column(
                          children: [
                            SslTextField(
                              controller: provider.rootCACertPathController,
                              label: LocalizationKeys.rootCaCertPath.tr(
                                context,
                              ),
                              suffix: IconButton(
                                icon: const Icon(Icons.upload_file),
                                onPressed: () async {
                                  final path = await _pickCertFile();
                                  if (path != null) {
                                    provider.rootCACertPathController.text =
                                        path;
                                  }
                                },
                              ),
                            ),
                            SslTextField(
                              controller: provider.rootCAKeyPathController,
                              label: LocalizationKeys.rootCaKeyPath.tr(context),
                              suffix: IconButton(
                                icon: const Icon(Icons.upload_file),
                                onPressed: () async {
                                  final path = await _pickKeyFile();
                                  if (path != null) {
                                    provider.rootCAKeyPathController.text =
                                        path;
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 280,
              height: 48,
              child: FilledButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () => _handleCompleteInitialization(provider),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  LocalizationKeys.completeInit.tr(context),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (provider.infoMessage.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.infoMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<String?> _pickDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) return null;
    return FilePicker.platform.getDirectoryPath(
      dialogTitle: LocalizationKeys.setupStoragePath.tr(context),
    );
  }

  Future<String?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pem', 'crt', 'key'],
      allowMultiple: false,
      withData: false,
    );
    return result?.files.single.path;
  }

  Future<String?> _pickCertFile() async {
    final path = await _pickFile();
    if (path == null) return null;
    final lower = p.basename(path).toLowerCase();
    if (lower.endsWith('.crt') || lower.endsWith('.pem')) {
      return path;
    }
    if (!mounted) return null;
    await _showSimpleDialog(
      LocalizationKeys.fileTypeNotAllowed.tr(context),
      LocalizationKeys.rootCertFileAllowedOnly.tr(context),
    );
    return null;
  }

  Future<String?> _pickKeyFile() async {
    final path = await _pickFile();
    if (path == null) return null;
    final lower = p.basename(path).toLowerCase();
    if (lower.endsWith('.key') || lower.endsWith('.pem')) {
      return path;
    }
    if (!mounted) return null;
    await _showSimpleDialog(
      LocalizationKeys.fileTypeNotAllowed.tr(context),
      LocalizationKeys.rootKeyFileAllowedOnly.tr(context),
    );
    return null;
  }

  Future<void> _handleCompleteInitialization(
    SslCertificateManagerProvider provider,
  ) async {
    if (provider.importRootCA) {
      final validation = await provider.inspectImportedRootCA();
      if (!mounted) return;
      if (!validation.isValid) {
        await _showSimpleDialog(
          LocalizationKeys.importRootCaFailed.tr(context),
          validation.message,
        );
        return;
      }
      final confirmed = await _showRootCaConfirmDialog(validation);
      if (!mounted || !confirmed) return;
      await provider.completeInitialization();
      if (!mounted) return;
      if (!provider.isInitialized && provider.infoMessage.trim().isNotEmpty) {
        await _showSimpleDialog(
          LocalizationKeys.initFailed.tr(context),
          provider.infoMessage,
        );
      }
      return;
    }

    if (provider.isRootPasswordEmpty) {
      final acceptedRisk = await _showEmptyPasswordRiskDialog();
      if (!mounted || !acceptedRisk) return;
    }
    await provider.completeInitialization();
    if (!mounted) return;
    if (!provider.isInitialized && provider.infoMessage.trim().isNotEmpty) {
      await _showSimpleDialog(
        LocalizationKeys.initFailed.tr(context),
        provider.infoMessage,
      );
    }
  }

  Future<void> _showSimpleDialog(String title, String message) async {
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

  Future<bool> _showEmptyPasswordRiskDialog() async {
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

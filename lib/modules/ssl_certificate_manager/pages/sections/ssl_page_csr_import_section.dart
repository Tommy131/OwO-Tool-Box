part of '../ssl_certificate_manager_page.dart';

extension _SslPageCsrImportSection on _SslCertificateManagerPageState {
  Widget _buildCsrImportTab(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildGradientHeader(
            title: LocalizationKeys.importCsrTitle.tr(context),
            subtitle: LocalizationKeys.importCsrSubtitle.tr(context),
            icon: Icons.upload_file_outlined,
          ),
          const SizedBox(height: 16),
          _buildPremiumCard(
            title: LocalizationKeys.importCsr.tr(context),
            icon: Icons.description_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: provider.csrFilePathController,
                  label: LocalizationKeys.csrFilePath.tr(context),
                  suffix: IconButton(
                    icon: const Icon(Icons.upload_file),
                    onPressed: () async {
                      final path = await _pickCsrFile();
                      if (path != null) {
                        provider.csrFilePathController.text = path;
                      }
                    },
                  ),
                  requiredField: true,
                ),
                _buildTextField(
                  controller: provider.csrValidDaysController,
                  label: LocalizationKeys.validDays.tr(context),
                  requiredField: true,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => _handleSignCsr(provider),
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

  Future<String?> _pickCsrFile() async {
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
    if (!mounted) return null;
    await _showSimpleDialog(
      LocalizationKeys.fileTypeNotAllowed.tr(context),
      LocalizationKeys.csrFileAllowedOnly.tr(context),
    );
    return null;
  }

  Future<void> _handleSignCsr(SslCertificateManagerProvider provider) async {
    final csrPath = provider.csrFilePathController.text.trim();
    if (csrPath.isEmpty) {
      _showInlineMessage(LocalizationKeys.csrFilePath.tr(context));
      return;
    }
    final days = int.tryParse(provider.csrValidDaysController.text.trim());
    if (days == null || days <= 0) {
      _showInlineMessage(LocalizationKeys.validationValidDays.tr(context));
      return;
    }

    final confirmed = await showAdvancedConfirmDialog(
      context: context,
      style: ConfirmDialogStyle.darkNeon,
      title: LocalizationKeys.importCsrTitle.tr(context),
      content: '${LocalizationKeys.csrFilePath.tr(context)}: $csrPath\n${LocalizationKeys.validDays.tr(context)}: $days',
      icon: Icons.verified_outlined,
      confirmText: LocalizationKeys.signCsr.tr(context),
      cancelText: LocalizationKeys.cancel.tr(context),
    );
    if (!mounted || confirmed != true) return;

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
    if (!mounted) return;
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
}

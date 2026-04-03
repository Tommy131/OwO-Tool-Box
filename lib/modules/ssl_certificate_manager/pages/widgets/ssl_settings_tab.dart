import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';

class SslSettingsTab extends StatelessWidget {
  final SslCertificateManagerProvider provider;
  final Widget Function(
    String label,
    TextEditingController controller, {
    bool obscureText,
    String? helperText,
  })
  fieldBuilder;
  final TextEditingController baseDirController;
  final TextEditingController daysController;
  final TextEditingController domainController;
  final TextEditingController certNameController;
  final TextEditingController rootCaNameController;
  final TextEditingController ipController;
  final TextEditingController ocspServerUrlController;
  final TextEditingController crlUrlController;
  final TextEditingController userConfigPathController;
  final TextEditingController opensslConfigPathController;
  final TextEditingController caKeyPasswordController;
  final TextEditingController pfxPasswordController;
  final Future<void> Function() onInitStorage;
  final Future<void> Function() onSaveConfig;

  const SslSettingsTab({
    super.key,
    required this.provider,
    required this.fieldBuilder,
    required this.baseDirController,
    required this.daysController,
    required this.domainController,
    required this.certNameController,
    required this.rootCaNameController,
    required this.ipController,
    required this.ocspServerUrlController,
    required this.crlUrlController,
    required this.userConfigPathController,
    required this.opensslConfigPathController,
    required this.caKeyPasswordController,
    required this.pfxPasswordController,
    required this.onInitStorage,
    required this.onSaveConfig,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStorageSection(context),
          const SizedBox(height: 12),
          _buildConfigSection(context),
        ],
      ),
    );
  }

  Widget _buildStorageSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationKeys.storageSection.tr(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            fieldBuilder(
              LocalizationKeys.baseDir.tr(context),
              baseDirController,
            ),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: provider.isRunning ? null : onInitStorage,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: Text(LocalizationKeys.initStorage.tr(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationKeys.configSection.tr(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            /* fieldBuilder(
              LocalizationKeys.baseDir.tr(context),
              baseDirController,
            ), */
            fieldBuilder(LocalizationKeys.days.tr(context), daysController),
            fieldBuilder(LocalizationKeys.domain.tr(context), domainController),
            fieldBuilder(
              LocalizationKeys.certName.tr(context),
              certNameController,
            ),
            fieldBuilder(
              LocalizationKeys.rootCaName.tr(context),
              rootCaNameController,
            ),
            fieldBuilder(LocalizationKeys.ip.tr(context), ipController),
            fieldBuilder(
              LocalizationKeys.ocspServerUrl.tr(context),
              ocspServerUrlController,
            ),
            fieldBuilder(LocalizationKeys.crlUrl.tr(context), crlUrlController),
            fieldBuilder(
              LocalizationKeys.userConfigPath.tr(context),
              userConfigPathController,
            ),
            fieldBuilder(
              LocalizationKeys.opensslConfigPath.tr(context),
              opensslConfigPathController,
            ),
            fieldBuilder(
              LocalizationKeys.caKeyPassword.tr(context),
              caKeyPasswordController,
              obscureText: true,
            ),
            fieldBuilder(
              LocalizationKeys.pfxPassword.tr(context),
              pfxPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: provider.isRunning ? null : onSaveConfig,
              icon: const Icon(Icons.save),
              label: Text(LocalizationKeys.saveConfig.tr(context)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../models/ssl_command_result.dart';
import '../../providers/ssl_certificate_manager_provider.dart';

class SslOperationTab extends StatelessWidget {
  final SslCertificateManagerProvider provider;
  final Future<void> Function(
    BuildContext context,
    String title,
    Future<SslCommandResult> Function() runner,
  )
  onRunAction;

  const SslOperationTab({
    super.key,
    required this.provider,
    required this.onRunAction,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusBar(context),
          const SizedBox(height: 12),
          if (provider.canRunActions) ...[
            _buildActionSection(context),
            const SizedBox(height: 12),
            _buildOutputSection(context),
          ] else
            _buildConfigRequiredCard(context),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            provider.isRunning ? Icons.pending : Icons.check_circle_outline,
            color: provider.isRunning
                ? theme.colorScheme.primary
                : Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            provider.isRunning
                ? LocalizationKeys.running.tr(context)
                : LocalizationKeys.idle.tr(context),
          ),
          const Spacer(),
          if (provider.isOcspRunning)
            const Chip(
              label: Text('OCSP:8080'),
              avatar: Icon(Icons.cloud_done, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    final actions = <({String title, Future<SslCommandResult> Function() run})>[
      (
        title: LocalizationKeys.issueCertificate.tr(context),
        run: () => provider.issueCertificate(),
      ),
      (
        title: LocalizationKeys.startOcspServer.tr(context),
        run: () => provider.startOcspServer(),
      ),
      (
        title: LocalizationKeys.stopOcspServer.tr(context),
        run: () => provider.stopOcspServer(),
      ),
      (
        title: LocalizationKeys.verifyUrl.tr(context),
        run: () => provider.verifyUrl(),
      ),
      (
        title: LocalizationKeys.registerToRdpTcp.tr(context),
        run: () => provider.registerToRdpTcp(),
      ),
      (
        title: LocalizationKeys.ocspClientVerify.tr(context),
        run: () => provider.ocspClientVerify(),
      ),
      (
        title: LocalizationKeys.ocspStaplingVerify.tr(context),
        run: () => provider.ocspStaplingVerify(),
      ),
      (
        title: LocalizationKeys.fetchRootCrl.tr(context),
        run: () => provider.fetchRootCrl(),
      ),
      (
        title: LocalizationKeys.generateCrl.tr(context),
        run: () => provider.generateCrl(),
      ),
      (
        title: LocalizationKeys.revokeCertificate.tr(context),
        run: () => provider.revokeCertificate(),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationKeys.actionSection.tr(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in actions)
                  FilledButton(
                    onPressed: provider.isRunning
                        ? null
                        : () => onRunAction(context, action.title, action.run),
                    child: Text(action.title),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputSection(BuildContext context) {
    final outputText = provider.lastOutput.trim().isEmpty
        ? provider.ocspLogs
        : provider.lastOutput;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationKeys.outputSection.tr(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 240),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(outputText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRequiredCard(BuildContext context) {
    final messages = <String>[];
    if (!provider.hasValidRootDir) {
      messages.add(
        '${LocalizationKeys.rootDirMissing.tr(context)}: ${provider.config.baseDir}',
      );
    }
    if (!provider.hasValidUserConfig) {
      messages.add(
        '${LocalizationKeys.userConfigMissing.tr(context)}: ${provider.config.userConfigPath}',
      );
    }
    if (!provider.hasValidOpenSslConfig) {
      messages.add(
        '${LocalizationKeys.opensslConfigMissing.tr(context)}: ${provider.config.opensslConfigPath}',
      );
    }
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationKeys.configRequiredTitle.tr(context),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(LocalizationKeys.configRequiredMessage.tr(context)),
              const SizedBox(height: 8),
              for (final message in messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $message'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

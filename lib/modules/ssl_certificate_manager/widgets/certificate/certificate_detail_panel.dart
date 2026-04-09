import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../models/ssl_models.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../form/ssl_input_config.dart';
import '../shared/section_container.dart';
import '../shared/status_badge.dart';

/// Detail panel for a selected certificate, including subject info, validity,
/// extensions, fingerprints, file paths and action buttons.
class CertificateDetailPanel extends StatelessWidget {
  const CertificateDetailPanel({
    super.key,
    required this.provider,
    required this.onRenew,
    required this.onShowInlineMessage,
  });

  final SslCertificateManagerProvider provider;
  final VoidCallback onRenew;
  final void Function(String message) onShowInlineMessage;

  @override
  Widget build(BuildContext context) {
    final cert = provider.selectedCertificate;
    if (cert == null) {
      return Card(
        child: Center(
          child: Text(
            LocalizationKeys.selectCertificate.tr(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final revokeConfig = SslInputConfigResolver.resolve(
      controller: provider.revokeReasonController,
      provider: provider,
    );

    final daysColor = cert.isExpired
        ? Colors.red
        : (cert.daysRemaining <= 30 ? Colors.amber.shade700 : Colors.green);

    return Card(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          _buildDetailGradientHeader(cert, theme),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject info
                SslSectionContainer(
                  title: LocalizationKeys.sectionSubjectInfo.tr(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SslInfoRow(
                        label: LocalizationKeys.commonName.tr(context),
                        value: cert.commonName,
                        copyable: true,
                      ),
                      SslInfoRow(
                        label: LocalizationKeys.issuer.tr(context),
                        value: cert.issuer,
                      ),
                      SslInfoRow(
                        label: LocalizationKeys.serialNumber.tr(context),
                        value: cert.serialNumber,
                        copyable: true,
                      ),
                    ],
                  ),
                ),

                // Validity
                SslSectionContainer(
                  title: LocalizationKeys.sectionValidity.tr(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SslInfoRow(
                        label: LocalizationKeys.issuedAt.tr(context),
                        value: cert.issuedAt
                            .toLocal()
                            .toString()
                            .split('.')
                            .first,
                      ),
                      SslInfoRow(
                        label: LocalizationKeys.expiresAt.tr(context),
                        value: cert.expiresAt
                            .toLocal()
                            .toString()
                            .split('.')
                            .first,
                      ),
                      _buildDaysRemainingRow(
                        context,
                        cert.daysRemaining,
                        daysColor,
                      ),
                    ],
                  ),
                ),

                // Extensions (async)
                SslSectionContainer(
                  title: LocalizationKeys.sectionExtensions.tr(context),
                  child: FutureBuilder<CertificateDetailInfo?>(
                    future: provider.fetchCertificateDetails(cert.certFilePath),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            LocalizationKeys.loadingDetails.tr(context),
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      }
                      final detail = snapshot.data;
                      if (detail == null) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SslInfoRow(
                            label: LocalizationKeys.certDetailPublicKey.tr(
                              context,
                            ),
                            value: detail.publicKeyAlgorithm,
                          ),
                          SslInfoRow(
                            label: LocalizationKeys.certDetailSignatureAlgo.tr(
                              context,
                            ),
                            value: detail.signatureAlgorithm,
                          ),
                          SslInfoRow(
                            label: LocalizationKeys.certDetailKeyUsage.tr(
                              context,
                            ),
                            value: detail.keyUsage.join(', '),
                          ),
                          SslInfoRow(
                            label: LocalizationKeys.certDetailExtKeyUsage.tr(
                              context,
                            ),
                            value: detail.extendedKeyUsage.join(', '),
                          ),
                          SslInfoRow(
                            label: LocalizationKeys.certDetailSan.tr(context),
                            value: detail.subjectAltNames.join(', '),
                          ),
                          if (detail.basicConstraints != null)
                            SslInfoRow(
                              label: LocalizationKeys.certDetailBasicConstraints
                                  .tr(context),
                              value: detail.basicConstraints!,
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Fingerprint
                FutureBuilder<CertificateDetailInfo?>(
                  future: provider.fetchCertificateDetails(cert.certFilePath),
                  builder: (context, snapshot) {
                    final detail = snapshot.data;
                    if (detail == null || detail.sha256Fingerprint.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return SslSectionContainer(
                      title: LocalizationKeys.sectionFingerprints.tr(context),
                      child: SslInfoRow(
                        label: 'SHA-256',
                        value: detail.sha256Fingerprint,
                        copyable: true,
                      ),
                    );
                  },
                ),

                // File paths
                SslSectionContainer(
                  title: LocalizationKeys.certDetailFilePaths.tr(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SslInfoRow(
                        label: LocalizationKeys.summaryCertPath.tr(context),
                        value: cert.certFilePath,
                        copyable: true,
                      ),
                      SslInfoRow(
                        label: LocalizationKeys.summaryKeyPath.tr(context),
                        value: cert.keyFilePath,
                        copyable: true,
                      ),
                      SslInfoRow(
                        label: LocalizationKeys.summaryConfigPath.tr(context),
                        value: cert.configFilePath,
                        copyable: true,
                      ),
                    ],
                  ),
                ),

                // Actions
                SslSectionContainer(
                  title: LocalizationKeys.sectionActions.tr(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: provider.revokeReasonController,
                        keyboardType: revokeConfig.keyboardType,
                        inputFormatters: revokeConfig.inputFormatters,
                        obscureText: revokeConfig.obscureText,
                        textCapitalization: revokeConfig.textCapitalization,
                        decoration: InputDecoration(
                          labelText: LocalizationKeys.revokeReason.tr(context),
                          suffixIcon: revokeConfig.suffix,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: onRenew,
                            icon: const Icon(Icons.autorenew),
                            label: Text(
                              LocalizationKeys.renewCertificate.tr(context),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _showPfxExportDialog(context, cert.id),
                            icon: const Icon(Icons.download),
                            label: Text(
                              LocalizationKeys.exportPkcs12.tr(context),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final result = await provider
                                  .verifyCertificateChain(cert.id);
                              if (!context.mounted) return;
                              onShowInlineMessage(
                                result.valid
                                    ? LocalizationKeys.verifySuccess.tr(context)
                                    : '${LocalizationKeys.verifyFailed.tr(context)}: ${result.message}',
                              );
                            },
                            icon: const Icon(Icons.verified_outlined),
                            label: Text(
                              LocalizationKeys.verifyCertChain.tr(context),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: cert.status == SslCertStatus.revoked
                                ? null
                                : () => provider.revokeCertificate(cert.id),
                            icon: const Icon(Icons.block),
                            label: Text(LocalizationKeys.revoke.tr(context)),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                provider.deleteCertificate(cert.id),
                            icon: const Icon(Icons.delete_outline),
                            label: Text(LocalizationKeys.delete.tr(context)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailGradientHeader(
    SslCertificateRecord cert,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.16),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.badge_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cert.domain,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SslStatusBadge(cert: cert),
        ],
      ),
    );
  }

  Widget _buildDaysRemainingRow(BuildContext context, int days, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              LocalizationKeys.daysRemaining.tr(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$days',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPfxExportDialog(BuildContext context, String certId) {
    final pfxPasswordController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(LocalizationKeys.exportPkcs12.tr(context)),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: pfxPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: LocalizationKeys.exportPfxPassword.tr(context),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(LocalizationKeys.cancel.tr(context)),
            ),
            FilledButton(
              onPressed: () async {
                final password = pfxPasswordController.text;
                Navigator.of(ctx).pop();
                final path = await provider.exportCertificatePkcs12(
                  certId,
                  password,
                );
                if (!context.mounted) return;
                if (path != null) {
                  onShowInlineMessage(
                    '${LocalizationKeys.exportSuccess.tr(context)}: $path',
                  );
                }
              },
              child: Text(LocalizationKeys.exportCertificate.tr(context)),
            ),
          ],
        );
      },
    ).then((_) => pfxPasswordController.dispose());
  }
}

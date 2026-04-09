import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../../../core/widgets/common/dialog.dart';
import '../../localization/localization_keys.dart';
import '../../models/ssl_models.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../../widgets/certificate/certificate_stats_bar.dart';
import '../../widgets/form/ssl_input_config.dart';
import '../../widgets/shared/section_container.dart';
import '../../widgets/shared/status_badge.dart';

/// Tab page that shows the certificate list with expandable cards.
class CertificateListTab extends StatefulWidget {
  const CertificateListTab({super.key});

  @override
  State<CertificateListTab> createState() => _CertificateListTabState();
}

class _CertificateListTabState extends State<CertificateListTab> {
  String? _expandedCertId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SslCertificateManagerProvider>();
    final data = provider.filteredCertificates;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CertificateStatsBar(
            provider: provider,
            onBatchRevoke: () => _handleBatchRevoke(context, provider),
            onBatchDelete: () => _handleBatchDelete(context, provider),
            showBatchControls: false,
            headerTrailing: _buildTopRightBatchControls(context, provider),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: data.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cert = data[index];
                      final isExpanded = _expandedCertId == cert.id;
                      return _buildCertificateCard(
                        context: context,
                        provider: provider,
                        cert: cert,
                        isExpanded: isExpanded,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRightBatchControls(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        OutlinedButton.icon(
          onPressed: () => provider.toggleBatchMode(),
          icon: Icon(provider.batchMode ? Icons.close : Icons.checklist),
          label: Text(LocalizationKeys.batchMode.tr(context)),
          style: OutlinedButton.styleFrom(
            foregroundColor: provider.batchMode
                ? theme.colorScheme.error
                : null,
          ),
        ),
        if (provider.batchMode) ...[
          TextButton(
            onPressed: provider.batchSelectAll,
            child: Text(LocalizationKeys.batchSelectAll.tr(context)),
          ),
          TextButton(
            onPressed: provider.batchDeselectAll,
            child: Text(LocalizationKeys.batchDeselectAll.tr(context)),
          ),
          Text(
            LocalizationKeys.batchSelectedCount
                .tr(context)
                .replaceAll('@count', '${provider.batchSelectedIds.length}'),
          ),
          FilledButton.icon(
            onPressed: provider.batchSelectedIds.isEmpty
                ? null
                : () => _handleBatchRevoke(context, provider),
            icon: const Icon(Icons.block, size: 16),
            label: Text(LocalizationKeys.batchRevoke.tr(context)),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
          ),
          FilledButton.icon(
            onPressed: provider.batchSelectedIds.isEmpty
                ? null
                : () => _handleBatchDelete(context, provider),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: Text(LocalizationKeys.batchDelete.tr(context)),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget _buildCertificateCard({
    required BuildContext context,
    required SslCertificateManagerProvider provider,
    required SslCertificateRecord cert,
    required bool isExpanded,
  }) {
    final theme = Theme.of(context);
    final statusDotColor = cert.status == SslCertStatus.revoked
        ? Colors.red
        : (cert.isExpired
              ? Colors.red.shade800
              : (cert.isExpiringSoon ? Colors.amber.shade700 : Colors.green));
    final watermarkText = _statusWatermarkText(context, cert);
    final watermarkColor = _statusWatermarkColor(cert).withValues(alpha: 0.18);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (isExpanded)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Transform.rotate(
                    angle: -0.22,
                    child: Text(
                      watermarkText,
                      textAlign: TextAlign.center,
                      style:
                          (theme.textTheme.displayLarge ??
                                  theme.textTheme.headlineLarge)
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                fontSize: 64,
                                fontWeight: FontWeight.w800,
                                color: watermarkColor,
                                letterSpacing: 2.0,
                              ),
                    ),
                  ),
                ),
              ),
            ),
          Column(
            children: [
              InkWell(
                onTap: () {
                  provider.selectCertificate(cert.id);
                  setState(() {
                    _expandedCertId = isExpanded ? null : cert.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? theme.colorScheme.primary.withValues(alpha: 0.08)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (provider.batchMode) ...[
                            Checkbox(
                              value: provider.batchSelectedIds.contains(
                                cert.id,
                              ),
                              onChanged: (_) =>
                                  provider.toggleBatchSelect(cert.id),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 4),
                          ],
                          SizedBox(
                            height: 22,
                            child: Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusDotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                          const SizedBox(width: 8),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'CN: ${cert.commonName}  |  SN: ${cert.serialNumber}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildExpandedContent(context, provider, cert),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    SslCertificateManagerProvider provider,
    SslCertificateRecord cert,
  ) {
    final daysColor = cert.isExpired
        ? Colors.red
        : (cert.daysRemaining <= 30 ? Colors.amber.shade700 : Colors.green);
    final showRevokeActions = cert.status != SslCertStatus.revoked;
    final revokeConfig = showRevokeActions
        ? SslInputConfigResolver.resolve(
            controller: provider.revokeReasonController,
            provider: provider,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SslSectionContainer(
          title: LocalizationKeys.sectionValidity.tr(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SslInfoRow(
                label: LocalizationKeys.issuedAt.tr(context),
                value: cert.issuedAt.toLocal().toString().split('.').first,
              ),
              SslInfoRow(
                label: LocalizationKeys.expiresAt.tr(context),
                value: cert.expiresAt.toLocal().toString().split('.').first,
              ),
              if (cert.status == SslCertStatus.revoked)
                SslInfoRow(
                  label: LocalizationKeys.revokedAt.tr(context),
                  value: _formatDateTimeForDisplay(cert.revokedAt),
                  valueColor: Colors.red,
                ),
              SslInfoRow(
                label: LocalizationKeys.daysRemaining.tr(context),
                value: '${cert.daysRemaining}',
                valueColor: daysColor,
              ),
            ],
          ),
        ),
        SslSectionContainer(
          title: LocalizationKeys.sectionExtensions.tr(context),
          child: FutureBuilder<CertificateDetailInfo?>(
            future: provider.fetchCertificateDetails(cert.certFilePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Text(LocalizationKeys.loadingDetails.tr(context));
              }
              final detail = snapshot.data;
              if (detail == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cert.status == SslCertStatus.revoked)
                    SslInfoRow(
                      label: LocalizationKeys.revokeReason.tr(context),
                      value: (cert.revokeReason ?? '').trim().isEmpty
                          ? '-'
                          : cert.revokeReason!.trim(),
                    ),
                  SslInfoRow(
                    label: LocalizationKeys.ocspResponderUrl.tr(context),
                    value: (detail.ocspResponderUrl ?? '').trim().isEmpty
                        ? '-'
                        : detail.ocspResponderUrl!.trim(),
                    copyable: (detail.ocspResponderUrl ?? '').trim().isNotEmpty,
                  ),
                  SslInfoRow(
                    label: LocalizationKeys.summaryCrlUrl.tr(context),
                    value: (detail.crlDistributionUrl ?? '').trim().isEmpty
                        ? '-'
                        : detail.crlDistributionUrl!.trim(),
                    copyable: (detail.crlDistributionUrl ?? '')
                        .trim()
                        .isNotEmpty,
                  ),
                  SslInfoRow(
                    label: LocalizationKeys.ocspCaIssuersUrl.tr(context),
                    value: (detail.caIssuersUrl ?? '').trim().isEmpty
                        ? '-'
                        : detail.caIssuersUrl!.trim(),
                    copyable: (detail.caIssuersUrl ?? '').trim().isNotEmpty,
                  ),
                  SslInfoRow(
                    label: LocalizationKeys.certDetailPublicKey.tr(context),
                    value: detail.publicKeyAlgorithm,
                  ),
                  SslInfoRow(
                    label: LocalizationKeys.certDetailSignatureAlgo.tr(context),
                    value: detail.signatureAlgorithm,
                  ),
                  SslInfoRow(
                    label: LocalizationKeys.certDetailKeyUsage.tr(context),
                    value: detail.keyUsage.join(', '),
                  ),
                  SslInfoRow(
                    label: LocalizationKeys.certDetailExtKeyUsage.tr(context),
                    value: detail.extendedKeyUsage.join(', '),
                  ),
                  SslInfoRow(
                    label: LocalizationKeys.certDetailSan.tr(context),
                    value: detail.subjectAltNames.join(', '),
                  ),
                ],
              );
            },
          ),
        ),
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
        SslSectionContainer(
          title: LocalizationKeys.sectionActions.tr(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showRevokeActions) ...[
                TextField(
                  controller: provider.revokeReasonController,
                  keyboardType: revokeConfig!.keyboardType,
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
              ],
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            provider.prepareRenewalFromCertificate(cert.id);
                            provider.selectNav(1);
                          },
                          icon: const Icon(Icons.autorenew),
                          label: Text(
                            LocalizationKeys.renewCertificate.tr(context),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showPfxExportDialog(context, provider, cert.id),
                          icon: const Icon(Icons.download),
                          label: Text(
                            LocalizationKeys.exportPkcs12.tr(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await provider
                                .verifyCertificateChain(cert.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.valid
                                      ? LocalizationKeys.verifySuccess.tr(
                                          context,
                                        )
                                      : '${LocalizationKeys.verifyFailed.tr(context)}: ${result.message}',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.verified_outlined),
                          label: Text(
                            LocalizationKeys.verifyCertChain.tr(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (showRevokeActions) ...[
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              final confirmed = await showAdvancedConfirmDialog(
                                context: context,
                                style: ConfirmDialogStyle.material,
                                title: LocalizationKeys.revoke.tr(context),
                                content:
                                    '将撤销证书：${cert.domain}\n序列号：${cert.serialNumber}\n该操作具有风险，是否继续？',
                                icon: Icons.warning_amber_rounded,
                                confirmText: LocalizationKeys.revoke.tr(
                                  context,
                                ),
                                cancelText: LocalizationKeys.cancel.tr(context),
                                confirmColor: Colors.red,
                              );
                              if (!context.mounted || confirmed != true) {
                                return;
                              }
                              await provider.revokeCertificate(cert.id);
                            },
                            icon: const Icon(Icons.block),
                            label: Text(LocalizationKeys.revoke.tr(context)),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirmed = await showAdvancedConfirmDialog(
                              context: context,
                              style: ConfirmDialogStyle.material,
                              title: LocalizationKeys.delete.tr(context),
                              content:
                                  '将删除证书及关联文件：${cert.domain}\n序列号：${cert.serialNumber}\n删除后不可恢复，是否继续？',
                              icon: Icons.warning_amber_rounded,
                              confirmText: LocalizationKeys.delete.tr(context),
                              cancelText: LocalizationKeys.cancel.tr(context),
                              confirmColor: Colors.red,
                            );
                            if (!context.mounted || confirmed != true) {
                              return;
                            }
                            await provider.deleteCertificate(cert.id);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: Text(LocalizationKeys.delete.tr(context)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusWatermarkText(BuildContext context, SslCertificateRecord cert) {
    if (cert.status == SslCertStatus.revoked) {
      return LocalizationKeys.statusRevoked.tr(context);
    }
    if (cert.isExpired) {
      return LocalizationKeys.statusExpired.tr(context);
    }
    if (cert.isExpiringSoon) {
      return LocalizationKeys.statusExpiringSoon.tr(context);
    }
    return LocalizationKeys.statusActive.tr(context);
  }

  Color _statusWatermarkColor(SslCertificateRecord cert) {
    if (cert.status == SslCertStatus.revoked) {
      return Colors.red;
    }
    if (cert.isExpired) {
      return Colors.deepOrange;
    }
    if (cert.isExpiringSoon) {
      return Colors.amber.shade700;
    }
    return Colors.green;
  }

  String _formatDateTimeForDisplay(DateTime? dt) {
    if (dt == null) return '-';
    return dt.toLocal().toString().split('.').first;
  }

  void _showPfxExportDialog(
    BuildContext context,
    SslCertificateManagerProvider provider,
    String certId,
  ) {
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${LocalizationKeys.exportSuccess.tr(context)}: $path',
                      ),
                    ),
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.badge_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          Text(
            LocalizationKeys.noData.tr(context),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBatchRevoke(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) async {
    final count = provider.batchSelectedIds.length;
    final confirmed = await showAdvancedConfirmDialog(
      context: context,
      style: ConfirmDialogStyle.material,
      title: LocalizationKeys.batchRevoke.tr(context),
      content: LocalizationKeys.batchRevokeConfirm
          .tr(context)
          .replaceAll('@count', '$count'),
      icon: Icons.block,
      confirmText: LocalizationKeys.batchRevoke.tr(context),
      cancelText: LocalizationKeys.cancel.tr(context),
      confirmColor: Colors.orange,
    );
    if (!context.mounted || confirmed != true) return;
    final revoked = await provider.batchRevoke('\u6279\u91cf\u64a4\u9500');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocalizationKeys.batchRevokeSuccess
              .tr(context)
              .replaceAll('@count', '$revoked'),
        ),
      ),
    );
  }

  Future<void> _handleBatchDelete(
    BuildContext context,
    SslCertificateManagerProvider provider,
  ) async {
    final count = provider.batchSelectedIds.length;
    final confirmed = await showAdvancedConfirmDialog(
      context: context,
      style: ConfirmDialogStyle.material,
      title: LocalizationKeys.batchDelete.tr(context),
      content: LocalizationKeys.batchDeleteConfirm
          .tr(context)
          .replaceAll('@count', '$count'),
      icon: Icons.delete_forever,
      confirmText: LocalizationKeys.batchDelete.tr(context),
      cancelText: LocalizationKeys.cancel.tr(context),
      confirmColor: Colors.red,
    );
    if (!context.mounted || confirmed != true) return;
    final deleted = await provider.batchDelete();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocalizationKeys.batchDeleteSuccess
              .tr(context)
              .replaceAll('@count', '$deleted'),
        ),
      ),
    );
  }
}

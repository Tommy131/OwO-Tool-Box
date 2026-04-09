import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../../../core/widgets/common/dialog.dart';
import '../../localization/localization_keys.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../../widgets/certificate/certificate_data_list.dart';
import '../../widgets/certificate/certificate_detail_panel.dart';
import '../../widgets/certificate/certificate_stats_bar.dart';

/// Tab page that shows the certificate list, detail panel and batch controls.
class CertificateListTab extends StatelessWidget {
  const CertificateListTab({super.key});

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
          ),
          const SizedBox(height: 12),
          Expanded(
            child: data.isEmpty
                ? _buildEmptyState(context)
                : Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: CertificateDataList(provider: provider),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: CertificateDetailPanel(
                          provider: provider,
                          onRenew: () {
                            final cert = provider.selectedCertificate;
                            if (cert != null) {
                              provider.prepareRenewalFromCertificate(
                                  cert.id);
                              provider.selectNav(1);
                            }
                          },
                          onShowInlineMessage: (msg) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
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
      style: ConfirmDialogStyle.darkNeon,
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
      style: ConfirmDialogStyle.darkNeon,
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

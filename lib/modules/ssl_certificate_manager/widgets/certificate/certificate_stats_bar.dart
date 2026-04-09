import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../models/ssl_models.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../shared/status_badge.dart';

/// Stats bar with chips, expiry warning, search/filter, and batch mode controls.
class CertificateStatsBar extends StatelessWidget {
  const CertificateStatsBar({
    super.key,
    required this.provider,
    required this.onBatchRevoke,
    required this.onBatchDelete,
    this.showBatchControls = true,
    this.headerTrailing,
  });

  final SslCertificateManagerProvider provider;
  final VoidCallback onBatchRevoke;
  final VoidCallback onBatchDelete;
  final bool showBatchControls;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noFilterActive =
        provider.statusFilter.isEmpty && !provider.filterExpiringSoon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats chips + optional trailing actions on the same top row.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SslStatChip(
                    icon: Icons.folder_outlined,
                    label: LocalizationKeys.statsTotalCerts.tr(context),
                    value: '${provider.totalCertCount}',
                    color: Colors.blue,
                  ),
                  SslStatChip(
                    icon: Icons.check_circle_outline,
                    label: LocalizationKeys.statsIssuedCount.tr(context),
                    value: '${provider.issuedCertCount}',
                    color: Colors.green,
                  ),
                  SslStatChip(
                    icon: Icons.block,
                    label: LocalizationKeys.statsRevokedCount.tr(context),
                    value: '${provider.revokedCertCount}',
                    color: Colors.red,
                  ),
                  SslStatChip(
                    icon: Icons.warning_amber,
                    label: LocalizationKeys.statsExpiringSoon.tr(context),
                    value: '${provider.expiringSoonCount}',
                    color: Colors.amber.shade700,
                  ),
                ],
              ),
            ),
            if (headerTrailing != null) ...[
              const SizedBox(width: 10),
              headerTrailing!,
            ],
          ],
        ),

        // Expiry warning banner
        if (provider.expiringSoonCount > 0) ...[
          const SizedBox(height: 8),
          _buildExpiryWarningBanner(context),
        ],

        const SizedBox(height: 12),

        // Search & filter bar
        TextField(
          controller: provider.searchController,
          onChanged: (value) => provider.updateSearchQuery(value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: LocalizationKeys.searchCertificates.tr(context),
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            FilterChip(
              label: Text(LocalizationKeys.filterAll.tr(context)),
              selected: noFilterActive,
              onSelected: (_) => provider.clearFilters(),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            FilterChip(
              label: Text(LocalizationKeys.statusIssued.tr(context)),
              selected: provider.statusFilter.contains(SslCertStatus.issued),
              onSelected: (_) =>
                  provider.toggleStatusFilter(SslCertStatus.issued),
              selectedColor: Colors.green.withValues(alpha: 0.15),
            ),
            FilterChip(
              label: Text(LocalizationKeys.statusRevoked.tr(context)),
              selected: provider.statusFilter.contains(SslCertStatus.revoked),
              onSelected: (_) =>
                  provider.toggleStatusFilter(SslCertStatus.revoked),
              selectedColor: Colors.red.withValues(alpha: 0.15),
            ),
            FilterChip(
              label: Text(LocalizationKeys.filterExpiringSoon.tr(context)),
              selected: provider.filterExpiringSoon,
              onSelected: (v) => provider.setFilterExpiringSoon(v),
              selectedColor: Colors.amber.withValues(alpha: 0.15),
            ),
          ],
        ),
        if (showBatchControls) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => provider.toggleBatchMode(),
                icon: Icon(
                  provider.batchMode ? Icons.close : Icons.checklist,
                  size: 16,
                ),
                label: Text(LocalizationKeys.batchMode.tr(context)),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: provider.batchMode
                      ? theme.colorScheme.error
                      : null,
                ),
              ),
              if (provider.batchMode) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => provider.batchSelectAll(),
                  child: Text(LocalizationKeys.batchSelectAll.tr(context)),
                ),
                TextButton(
                  onPressed: () => provider.batchDeselectAll(),
                  child: Text(LocalizationKeys.batchDeselectAll.tr(context)),
                ),
                const Spacer(),
                Text(
                  LocalizationKeys.batchSelectedCount
                      .tr(context)
                      .replaceAll(
                        '@count',
                        '${provider.batchSelectedIds.length}',
                      ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: provider.batchSelectedIds.isEmpty
                      ? null
                      : onBatchRevoke,
                  icon: const Icon(Icons.block, size: 16),
                  label: Text(LocalizationKeys.batchRevoke.tr(context)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 6),
                FilledButton.icon(
                  onPressed: provider.batchSelectedIds.isEmpty
                      ? null
                      : onBatchDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(LocalizationKeys.batchDelete.tr(context)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildExpiryWarningBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              LocalizationKeys.expiryWarningMessage
                  .tr(context)
                  .replaceAll('@count', '${provider.expiringSoonCount}'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

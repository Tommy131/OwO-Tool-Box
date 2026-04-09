import 'package:flutter/material.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../models/ssl_models.dart';
import '../../providers/ssl_certificate_manager_provider.dart';
import '../shared/status_badge.dart';

/// The scrollable list of certificate items with status dots and selection.
class CertificateDataList extends StatelessWidget {
  const CertificateDataList({super.key, required this.provider});

  final SslCertificateManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = provider.filteredCertificates;
    return Card(
      child: ListView.separated(
        itemCount: data.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = data[index];
          final isSelected = provider.selectedCertId == item.id;

          Color statusDotColor;
          if (item.status == SslCertStatus.revoked) {
            statusDotColor = Colors.red;
          } else if (item.isExpired) {
            statusDotColor = Colors.red.shade800;
          } else if (item.isExpiringSoon) {
            statusDotColor = Colors.amber.shade700;
          } else {
            statusDotColor = Colors.green;
          }

          return InkWell(
            onTap: () => provider.selectCertificate(item.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.06)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (provider.batchMode) ...[
                        Checkbox(
                          value:
                              provider.batchSelectedIds.contains(item.id),
                          onChanged: (_) =>
                              provider.toggleBatchSelect(item.id),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.domain,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SslStatusBadge(cert: item),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      'CN: ${item.commonName}  |  SN: ${item.serialNumber}  |  ${LocalizationKeys.expiresAt.tr(context)}: ${item.expiresAt.toLocal().toString().split(".").first}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

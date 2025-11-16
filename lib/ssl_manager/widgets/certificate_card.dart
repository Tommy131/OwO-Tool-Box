/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-22
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/certificate.dart';
import '../models/certificate_purpose.dart';
import '../../core/i18n/localization_keys.dart';
import '../../core/i18n/app_localization.dart';

class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;

  const CertificateCard({
    super.key,
    required this.certificate,
    this.onTap,
    this.onDelete,
    this.onExport,
  });

  // 添加翻译辅助方法
  String _tr(BuildContext context, String key) {
    return AppLocalization.of(context).translate(key);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    final bool isExpired = certificate.isExpired;
    final bool isExpiringSoon = certificate.daysUntilExpiry <= 30 && !isExpired;

    Color statusColor = theme.colorScheme.primary;
    IconData statusIcon = Icons.check_circle;
    String statusText = _tr(context, L18nKeys.certStatusActive);

    if (isExpired) {
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.error;
      statusText = _tr(context, L18nKeys.certStatusExpired);
    } else if (isExpiringSoon) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = _tr(context, L18nKeys.certStatusExpiringSoon);
    }

    return Card(
      color: isDark ? theme.cardTheme.color : const Color(0xFFFAFAFA),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: certificate.type == 'CA'
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      certificate.type == 'CA'
                          ? Icons.security
                          : Icons.verified_user,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                certificate.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon,
                                      size: 14, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          certificate.type,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant
                      .withOpacity(isDark ? 0.3 : 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      _tr(context, L18nKeys.certCardIssueDate),
                      dateFormat.format(certificate.issueDate),
                      Icons.event,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      _tr(context, L18nKeys.certCardExpiryDate),
                      dateFormat.format(certificate.expiryDate),
                      Icons.event_available,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      _tr(context, L18nKeys.certCardDaysUntilExpiry),
                      '${certificate.daysUntilExpiry} ${_tr(context, L18nKeys.certCardDays)}',
                      Icons.timer,
                    ),
                    if (certificate.isEncrypted) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        _tr(context, L18nKeys.certCardEncrypted),
                        _tr(context, L18nKeys.certYes),
                        Icons.lock,
                      ),
                    ],
                    if (certificate.details['chainLength'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.link,
                                size: 12, color: Colors.purple),
                            const SizedBox(width: 4),
                            Text(
                              '${_tr(context, L18nKeys.certCardChain)}: ${certificate.details['chainLength']} ${_tr(context, L18nKeys.certCardCerts)}',
                              style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (certificate.purposes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: certificate.purposes.map((purposeId) {
                    final purpose = CertificatePurposes.getById(purposeId);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user,
                              size: 12, color: Colors.purple),
                          const SizedBox(width: 4),
                          Text(
                            purpose?.name ?? purposeId,
                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (certificate.details['imported'] == 'true') ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.file_upload,
                          size: 12, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        certificate.details['importedFrom'] ??
                            _tr(context, L18nKeys.certCardImported),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onExport != null)
                    TextButton.icon(
                      onPressed: onExport,
                      icon: const Icon(Icons.file_download, size: 18),
                      label: Text(_tr(context, L18nKeys.certActionExport)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 18),
                      label: Text(_tr(context, L18nKeys.certActionDelete)),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

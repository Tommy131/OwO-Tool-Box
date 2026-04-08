part of '../ssl_certificate_manager_page.dart';

extension _SslPageAuditLogSection on _SslCertificateManagerPageState {
  Widget _buildAuditLogTab(SslCertificateManagerProvider provider) {
    final theme = Theme.of(context);
    final logs = provider.auditLog;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGradientHeader(
            title: LocalizationKeys.auditLog.tr(context),
            icon: Icons.history_outlined,
            trailing: logs.isEmpty
                ? null
                : OutlinedButton.icon(
                    onPressed: () => _handleClearAuditLog(provider),
                    icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                    label: Text(LocalizationKeys.auditClearLog.tr(context)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          LocalizationKeys.auditLogEmpty.tr(context),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : Card(
                    child: ListView.separated(
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = logs[index];
                        return _buildAuditLogItem(entry, theme);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogItem(AuditLogEntry entry, ThemeData theme) {
    final IconData icon;
    final Color color;
    final String actionLabel;
    switch (entry.action) {
      case AuditAction.issue:
        icon = Icons.add_circle_outline;
        color = Colors.green;
        actionLabel = LocalizationKeys.auditActionIssue.tr(context);
      case AuditAction.revoke:
        icon = Icons.block;
        color = Colors.orange;
        actionLabel = LocalizationKeys.auditActionRevoke.tr(context);
      case AuditAction.delete:
        icon = Icons.delete_outline;
        color = Colors.red;
        actionLabel = LocalizationKeys.auditActionDelete.tr(context);
      case AuditAction.export:
        icon = Icons.download;
        color = Colors.blue;
        actionLabel = LocalizationKeys.auditActionExport.tr(context);
      case AuditAction.crl:
        icon = Icons.playlist_remove;
        color = Colors.purple;
        actionLabel = LocalizationKeys.auditActionCrl.tr(context);
      case AuditAction.importCsr:
        icon = Icons.upload_file;
        color = Colors.teal;
        actionLabel = LocalizationKeys.auditActionImportCsr.tr(context);
    }

    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(
        actionLabel,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        entry.detail,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatAuditTimestamp(entry.timestamp),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  String _formatAuditTimestamp(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleClearAuditLog(
    SslCertificateManagerProvider provider,
  ) async {
    final confirmed = await showAdvancedConfirmDialog(
      context: context,
      style: ConfirmDialogStyle.darkNeon,
      title: LocalizationKeys.auditClearLog.tr(context),
      content: LocalizationKeys.auditClearConfirm.tr(context),
      icon: Icons.delete_sweep_outlined,
      confirmText: LocalizationKeys.auditClearLog.tr(context),
      cancelText: LocalizationKeys.cancel.tr(context),
      confirmColor: Colors.red,
    );
    if (!mounted || confirmed != true) return;
    provider.clearAuditLog();
  }
}

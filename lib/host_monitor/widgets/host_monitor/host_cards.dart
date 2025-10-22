import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';

import '../../format_utils.dart';
import '../../my_models/host_model.dart';
import '../../my_services/geoip_service.dart';

class HostCards extends StatelessWidget {
  final HostModel host;
  final GeoIPInfo? geoInfo;
  final BuildContext context;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HostCards({
    super.key,
    required this.host,
    this.geoInfo,
    required this.context,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = FormatUtils.getStatusColor(host.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatusIndicator(color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              host.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildCountryFlag(),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${host.address}:${host.port}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (geoInfo != null && geoInfo?.countryCode != 'LOCAL')
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            geoInfo!.fullLocation,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 6),
                      _buildStatusChip(
                          color, FormatUtils.getStatusText(host.status)),
                    ],
                  ),
                ),
                // 新增：编辑和删除按钮
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: onEdit,
                      tooltip: '编辑',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.delete_rounded,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: onDelete,
                      tooltip: '删除',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)
        ],
      ),
    );
  }

  Widget _buildStatusChip(Color color, String text) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCountryFlag() {
    final theme = Theme.of(context);

    if (geoInfo == null) {
      return Container(
        width: 20,
        height: 14,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation(
                theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ),
      );
    }

    if (geoInfo!.countryCode == 'LOCAL') {
      return _buildFlagContainer(
        icon: Icons.home_rounded,
        bgColor: Colors.blue[50]!,
        borderColor: Colors.blue[200]!,
        iconColor: Colors.blue[700]!,
      );
    }

    if (geoInfo!.countryCode == 'UN') {
      return _buildFlagContainer(
        icon: Icons.public_rounded,
        bgColor: theme.colorScheme.surfaceContainerHighest,
        borderColor: theme.dividerColor,
        iconColor: theme.colorScheme.onSurface.withOpacity(0.6),
      );
    }

    return Tooltip(
      message: geoInfo!.countryName,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor, width: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Flag.fromString(geoInfo!.countryCode,
            height: 14, width: 20, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildFlagContainer({
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Icon(icon, size: 12, color: iconColor),
    );
  }
}

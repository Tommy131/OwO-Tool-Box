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
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';

import '../../format_utils.dart';
import '../../models/host_model.dart';
import '../../services/geoip_service.dart';

class HostCards extends StatefulWidget {
  final HostModel host;
  final GeoIPInfo? geoInfo;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HostCards({
    super.key,
    required this.host,
    this.geoInfo,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<HostCards> createState() => _HostCardsState();
}

class _HostCardsState extends State<HostCards> {
  bool _isIpVisible = true; // IP地址可见性状态

  /// 切换IP可见性
  void _toggleIpVisibility() {
    setState(() {
      _isIpVisible = !_isIpVisible;
    });
  }

  /// 获取显示的地址文本
  String _getDisplayAddress() {
    if (_isIpVisible) {
      return '${widget.host.address}:${widget.host.port}';
    }

    // 隐藏IP地址,保留端口
    final ipParts = widget.host.address.split('.');
    if (ipParts.length == 4) {
      // IPv4地址: 显示为 ***.***.***.***:port
      return '***.***.***.${ipParts[3]}:${widget.host.port}';
    }

    // 如果不是标准IPv4,则完全隐藏
    return '***:${widget.host.port}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = FormatUtils.getStatusColor(widget.host.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
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
                              widget.host.name,
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
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getDisplayAddress(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                fontFamily: _isIpVisible ? 'monospace' : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (widget.geoInfo != null &&
                          widget.geoInfo?.countryCode != 'LOCAL')
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            widget.geoInfo!.fullLocation,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 6),
                      _buildStatusChip(
                        color,
                        FormatUtils.getStatusText(widget.host.status),
                      ),
                    ],
                  ),
                ),
                // 右侧按钮组
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 新增：显示/隐藏IP按钮
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          _isIpVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          key: ValueKey(_isIpVisible),
                          size: 20,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      onPressed: _toggleIpVisibility,
                      tooltip: _isIpVisible ? '隐藏IP地址' : '显示IP地址',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.edit_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: widget.onEdit,
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
                      onPressed: widget.onDelete,
                      tooltip: '删除',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ],
      ),
    );
  }

  Widget _buildStatusChip(Color color, String text) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

    if (widget.geoInfo == null) {
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
                theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.geoInfo!.countryCode == 'LOCAL') {
      return _buildFlagContainer(
        icon: Icons.home_rounded,
        bgColor: Colors.blue[50]!,
        borderColor: Colors.blue[200]!,
        iconColor: Colors.blue[700]!,
      );
    }

    if (widget.geoInfo!.countryCode == 'UN') {
      return _buildFlagContainer(
        icon: Icons.public_rounded,
        bgColor: theme.colorScheme.surfaceContainerHighest,
        borderColor: theme.dividerColor,
        iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      );
    }

    return Tooltip(
      message: widget.geoInfo!.countryName,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor, width: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Flag.fromString(
          widget.geoInfo!.countryCode,
          height: 14,
          width: 20,
          fit: BoxFit.cover,
        ),
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

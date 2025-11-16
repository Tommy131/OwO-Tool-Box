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
// ============================================================================
// 捐赠排行榜卡片组件
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_constants.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../i18n/app_localization.dart';

class DonationCard extends StatefulWidget {
  const DonationCard({super.key});

  @override
  State<DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<DonationCard> {
  List<DonationUser>? _topDonors;
  bool _isLoading = true;
  bool _isFromApi = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadDonors();
  }

  Future<void> _loadDonors() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final result = await DonationService.getTopDonors();

    if (mounted) {
      setState(() {
        _topDonors = result.donors;
        _isFromApi = result.isFromApi;
        _statusMessage = result.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _openDonationUrl() async {
    final uri = Uri.parse(AppConstants.donationUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('无法打开链接');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalization.of(context).translate('cannot_open_url'),
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: AppLocalization.of(context).translate('ok'),
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalization.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: Colors.red.shade400,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('support_development'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizations.translate('donation_description'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 捐赠按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openDonationUrl,
                icon: const Icon(Icons.volunteer_activism_rounded),
                label: Text(localizations.translate('donate_now')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const Divider(height: 32),

            // 排行榜标题和状态
            Row(
              children: [
                Icon(
                  Icons.leaderboard_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('top_donors'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      if (!_isLoading) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              _isFromApi
                                  ? Icons.cloud_done_rounded
                                  : Icons.storage_rounded,
                              size: 14,
                              color: _isFromApi
                                  ? Colors.green
                                  : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isFromApi
                                  ? localizations.translate('data_from_api')
                                  : localizations.translate('data_from_mock'),
                              style: TextStyle(
                                fontSize: 11,
                                color: _isFromApi
                                    ? Colors.green
                                    : Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (!_isLoading && !_isFromApi)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _loadDonors,
                    tooltip: localizations.translate('retry'),
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 排行榜内容
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_topDonors == null || _topDonors!.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.translate('no_donors_yet'),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // 如果使用模拟数据且有错误消息，显示提示
              if (!_isFromApi && _statusMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_statusMessage!}，${localizations.translate('showing_mock_data')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 捐赠者列表
              ..._topDonors!.asMap().entries.map((entry) {
                final index = entry.key;
                final donor = entry.value;
                return _buildDonorItem(context, index + 1, donor, isDark);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDonorItem(
    BuildContext context,
    int rank,
    DonationUser donor,
    bool isDark,
  ) {
    // 前三名的徽章颜色
    Color? badgeColor;
    IconData? badgeIcon;

    if (rank == 1) {
      badgeColor = Colors.amber;
      badgeIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      badgeColor = Colors.grey.shade400;
      badgeIcon = Icons.workspace_premium_rounded;
    } else if (rank == 3) {
      badgeColor = Colors.brown.shade300;
      badgeIcon = Icons.military_tech_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rank <= 3
            ? (badgeColor?.withOpacity(0.1) ?? Colors.transparent)
            : (isDark
                ? Colors.grey.shade900.withOpacity(0.3)
                : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
        border: rank <= 3
            ? Border.all(
                color: badgeColor?.withOpacity(0.3) ?? Colors.transparent,
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          // 排名/徽章
          SizedBox(
            width: 40,
            child: rank <= 3
                ? Icon(
                    badgeIcon,
                    color: badgeColor,
                    size: 28,
                  )
                : Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // 头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                donor.avatar ?? '👤',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (donor.message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    donor.message!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 金额
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '¥${donor.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

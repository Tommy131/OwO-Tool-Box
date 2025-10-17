// ============================================================================
// 统计卡片组件 - StatsCard
// ============================================================================

import 'package:flutter/material.dart';

/// 统计卡片组件
///
/// 使用示例:
/// ```dart
/// StatsCard(
///   title: '总销售额',
///   value: '¥128,500',
///   trend: '+12.5%',
///   isPositive: true,
///   icon: Icons.attach_money,
/// )
/// ```
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final bool isPositive;
  final IconData icon;
  final Color? iconColor;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    this.isPositive = true,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = isPositive ? Colors.green : Colors.red;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 获取屏幕宽度以调整布局
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 10 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部行：图标和趋势
            Row(
              children: [
                // 图标容器
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    // ✅ 修复：使用更清晰的背景色
                    color: (iconColor ?? theme.colorScheme.primary)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
                    size: isSmallScreen ? 16 : 22,
                  ),
                ),

                // 趋势标签
                if (trend != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 4 : 6,
                        vertical: isSmallScreen ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        // ✅ 修复：使用更清晰的背景色
                        color: trendColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: isSmallScreen ? 10 : 12,
                            color: trendColor,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              trend!,
                              style: TextStyle(
                                color: trendColor,
                                fontSize: isSmallScreen ? 9 : 11,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: isSmallScreen ? 6 : 10),

            // 数值
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 16 : 24,
                height: 1.1,
                // ✅ 修复：使用 onSurface 确保清晰
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: isSmallScreen ? 2 : 4),

            // 标题
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                // ✅ 修复：使用更清晰的灰色
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                fontSize: isSmallScreen ? 11 : 13,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

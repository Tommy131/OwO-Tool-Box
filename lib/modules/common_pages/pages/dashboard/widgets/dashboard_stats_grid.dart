import 'package:flutter/material.dart';

import '../../../../../core/services/localization_service.dart';
import '../../../localization/localization_keys.dart';
import 'stat_card.dart';

class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
    required this.deviceData,
    required this.systemData,
    required this.primaryColor,
  });

  final Map<String, dynamic> deviceData;
  final Map<String, dynamic> systemData;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final stats = <Map<String, dynamic>>[];
    final mediaQuery = MediaQuery.of(context);
    final useNarrowLayout = mediaQuery.size.width < 1020;

    if (deviceData.containsKey('numberOfCores')) {
      stats.add({
        'id': 'processor',
        'icon': Icons.memory_rounded,
        'label': LocalizationKeys.processor.tr(context),
        'value':
            '${deviceData['numberOfCores']} ${LocalizationKeys.coresUnit.tr(context)}',
        'color': Colors.blue,
      });
    }

    if (systemData.containsKey('totalPhysicalMemory') &&
        systemData.containsKey('freePhysicalMemory')) {
      final totalGB = systemData['totalPhysicalMemory'] / (1024 * 1024 * 1024);
      final freeGB = systemData['freePhysicalMemory'] / (1024 * 1024 * 1024);
      if (totalGB > 0) {
        final usedGB = totalGB - freeGB;
        final usagePercent = (usedGB / totalGB * 100).toStringAsFixed(1);

        stats.add({
          'id': 'memory',
          'icon': Icons.storage_rounded,
          'label': LocalizationKeys.memoryUsage.tr(context),
          'value': '$usagePercent%',
          'color': Colors.green,
        });
      }
    } else if (systemData.containsKey('totalPhysicalMemory')) {
      final totalGB = (systemData['totalPhysicalMemory'] / (1024 * 1024 * 1024))
          .toStringAsFixed(1);
      stats.add({
        'id': 'memory',
        'icon': Icons.storage_rounded,
        'label': LocalizationKeys.totalMemory.tr(context),
        'value': '$totalGB GB',
        'color': Colors.green,
      });
    } else if (deviceData.containsKey('systemMemoryInMegabytes')) {
      final totalGB = (deviceData['systemMemoryInMegabytes'] / 1024)
          .toStringAsFixed(1);
      stats.add({
        'id': 'memory',
        'icon': Icons.storage_rounded,
        'label': LocalizationKeys.totalMemory.tr(context),
        'value': '$totalGB GB',
        'color': Colors.green,
      });
    } else if (deviceData.containsKey('memorySize')) {
      final totalGB = (deviceData['memorySize'] / (1024 * 1024 * 1024))
          .toStringAsFixed(1);
      stats.add({
        'id': 'memory',
        'icon': Icons.storage_rounded,
        'label': LocalizationKeys.totalMemory.tr(context),
        'value': '$totalGB GB',
        'color': Colors.green,
      });
    }

    if (systemData.containsKey('kernelArchitecture')) {
      stats.add({
        'id': 'architecture',
        'icon': Icons.architecture_rounded,
        'label': LocalizationKeys.systemArchitecture.tr(context),
        'value': systemData['kernelArchitecture'],
        'color': Colors.orange,
      });
    } else if (deviceData.containsKey('arch')) {
      stats.add({
        'id': 'architecture',
        'icon': Icons.architecture_rounded,
        'label': LocalizationKeys.systemArchitecture.tr(context),
        'value': deviceData['arch'],
        'color': Colors.orange,
      });
    }

    stats.add({
      'id': 'platform',
      'icon': Icons.computer_rounded,
      'label': LocalizationKeys.platform.tr(context),
      'value':
          deviceData['platform'] ?? LocalizationKeys.unknownValue.tr(context),
      'color': primaryColor,
    });

    const narrowLayoutTargetIds = {
      'processor',
      'memory',
      'architecture',
      'platform',
    };
    final shouldUseColumnLayout =
        useNarrowLayout &&
        stats.every((stat) => narrowLayoutTargetIds.contains(stat['id']));

    if (shouldUseColumnLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < stats.length; index++) ...[
            StatCard(
              icon: stats[index]['icon'],
              label: stats[index]['label'],
              value: stats[index]['value'],
              color: stats[index]['color'],
              horizontalLayout: true,
            ),
            if (index != stats.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mediaQuery.size.width > 600 ? 4 : 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return StatCard(
          icon: stat['icon'],
          label: stat['label'],
          value: stat['value'],
          color: stat['color'],
        );
      },
    );
  }
}

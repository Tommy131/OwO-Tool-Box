import 'package:flutter/material.dart';

import '../../../../../core/services/localization_service.dart';
import '../../../localization/localization_keys.dart';
import 'info_card.dart';

class DashboardHardwareInfoCard extends StatelessWidget {
  const DashboardHardwareInfoCard({super.key, required this.systemData});

  final Map<String, dynamic> systemData;

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[];

    if (systemData.containsKey('motherboard')) {
      items.add({
        'label': LocalizationKeys.motherboard.tr(context),
        'value': systemData['motherboard'],
      });
    }

    if (systemData.containsKey('processorModel')) {
      items.add({
        'label': LocalizationKeys.processorModel.tr(context),
        'value': systemData['processorModel'],
      });
    }

    if (systemData.containsKey('totalPhysicalMemory')) {
      final total = systemData['totalPhysicalMemory'] / (1024 * 1024 * 1024);
      final free = systemData['freePhysicalMemory'] / (1024 * 1024 * 1024);
      final used = total - free;

      items.add({
        'label': LocalizationKeys.memoryTotal.tr(context),
        'value': '${total.toStringAsFixed(2)} GB',
      });
      items.add({
        'label': LocalizationKeys.memoryUsed.tr(context),
        'value':
            '${used.toStringAsFixed(2)} GB (${(used / total * 100).toStringAsFixed(1)}%)',
      });
      items.add({
        'label': LocalizationKeys.memoryFree.tr(context),
        'value': '${free.toStringAsFixed(2)} GB',
      });
    }

    if (systemData.containsKey('operatingSystemName')) {
      items.add({
        'label': LocalizationKeys.osName.tr(context),
        'value': systemData['operatingSystemName'],
      });
    }

    if (systemData.containsKey('operatingSystemVersion')) {
      items.add({
        'label': LocalizationKeys.osVersion.tr(context),
        'value': systemData['operatingSystemVersion'],
      });
    }

    if (systemData.containsKey('kernelArchitecture')) {
      items.add({
        'label': LocalizationKeys.kernelArchitecture.tr(context),
        'value': systemData['kernelArchitecture'],
      });
    }

    return InfoCard(
      title: LocalizationKeys.hardwareDetails.tr(context),
      icon: Icons.settings_input_component_rounded,
      color: Colors.teal,
      items: items,
    );
  }
}

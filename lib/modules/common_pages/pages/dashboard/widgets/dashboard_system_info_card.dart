import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/services/localization_service.dart';
import '../../../localization/localization_keys.dart';
import 'info_card.dart';

class DashboardSystemInfoCard extends StatelessWidget {
  const DashboardSystemInfoCard({
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
    final items = <Map<String, String>>[];

    if (Platform.isWindows) {
      if (deviceData.containsKey('productName')) {
        items.add({
          'label': LocalizationKeys.operatingSystem.tr(context),
          'value': deviceData['productName'],
        });
      }
      if (deviceData.containsKey('displayVersion')) {
        items.add({
          'label': LocalizationKeys.version.tr(context),
          'value': deviceData['displayVersion'],
        });
      }
      if (deviceData.containsKey('buildNumber')) {
        items.add({
          'label': LocalizationKeys.build.tr(context),
          'value': deviceData['buildNumber'].toString(),
        });
      }
      if (deviceData.containsKey('computerName')) {
        items.add({
          'label': LocalizationKeys.hostname.tr(context),
          'value': deviceData['computerName'],
        });
      }
      if (deviceData.containsKey('userName')) {
        items.add({
          'label': LocalizationKeys.user.tr(context),
          'value': deviceData['userName'],
        });
      }
    } else if (Platform.isLinux) {
      if (deviceData.containsKey('prettyName')) {
        items.add({
          'label': LocalizationKeys.operatingSystem.tr(context),
          'value': deviceData['prettyName'],
        });
      }
      if (deviceData.containsKey('versionCodename')) {
        items.add({
          'label': LocalizationKeys.codename.tr(context),
          'value': deviceData['versionCodename'],
        });
      }
      if (deviceData.containsKey('id')) {
        items.add({
          'label': LocalizationKeys.distributionId.tr(context),
          'value': deviceData['id'],
        });
      }
      if (deviceData.containsKey('machineId')) {
        items.add({
          'label': LocalizationKeys.machineId.tr(context),
          'value': deviceData['machineId'],
        });
      }
    } else if (Platform.isMacOS) {
      if (deviceData.containsKey('model')) {
        items.add({
          'label': LocalizationKeys.model.tr(context),
          'value': deviceData['model'],
        });
      }
      if (deviceData.containsKey('osRelease')) {
        items.add({
          'label': LocalizationKeys.operatingSystem.tr(context),
          'value': 'macOS ${deviceData['osRelease']}',
        });
      }
      if (deviceData.containsKey('computerName')) {
        items.add({
          'label': LocalizationKeys.hostname.tr(context),
          'value': deviceData['computerName'],
        });
      }
      if (deviceData.containsKey('hostName')) {
        items.add({
          'label': LocalizationKeys.hostname.tr(context),
          'value': deviceData['hostName'],
        });
      }
    } else if (Platform.isAndroid) {
      if (deviceData.containsKey('manufacturer') &&
          deviceData.containsKey('model')) {
        items.add({
          'label': LocalizationKeys.device.tr(context),
          'value': '${deviceData['manufacturer']} ${deviceData['model']}',
        });
      }
      if (deviceData.containsKey('versionRelease')) {
        items.add({
          'label': LocalizationKeys.androidVersion.tr(context),
          'value': deviceData['versionRelease'],
        });
      }
      if (deviceData.containsKey('versionSdkInt')) {
        items.add({
          'label': LocalizationKeys.sdkLevel.tr(context),
          'value': deviceData['versionSdkInt'].toString(),
        });
      }
      if (deviceData.containsKey('brand')) {
        items.add({
          'label': LocalizationKeys.brand.tr(context),
          'value': deviceData['brand'],
        });
      }
    } else if (Platform.isIOS) {
      if (deviceData.containsKey('name')) {
        items.add({
          'label': LocalizationKeys.deviceName.tr(context),
          'value': deviceData['name'],
        });
      }
      if (deviceData.containsKey('systemVersion')) {
        items.add({
          'label': LocalizationKeys.iosVersion.tr(context),
          'value': deviceData['systemVersion'],
        });
      }
      if (deviceData.containsKey('model')) {
        items.add({
          'label': LocalizationKeys.model.tr(context),
          'value': deviceData['model'],
        });
      }
      if (deviceData.containsKey('localizedModel')) {
        items.add({
          'label': LocalizationKeys.localizedModel.tr(context),
          'value': deviceData['localizedModel'],
        });
      }
    }

    if (systemData.containsKey('kernelVersion')) {
      items.add({
        'label': LocalizationKeys.kernelVersion.tr(context),
        'value': systemData['kernelVersion'],
      });
    }

    return InfoCard(
      title: LocalizationKeys.systemInfo.tr(context),
      icon: Icons.info_outline_rounded,
      color: primaryColor,
      items: items,
    );
  }
}

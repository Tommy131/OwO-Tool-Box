import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/services/localization_service.dart';
import '../../../localization/localization_keys.dart';
import 'info_card.dart';

class DashboardDeviceDetailsCard extends StatelessWidget {
  const DashboardDeviceDetailsCard({super.key, required this.deviceData});

  final Map<String, dynamic> deviceData;

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[];

    if (Platform.isAndroid) {
      if (deviceData.containsKey('hardware')) {
        items.add({
          'label': LocalizationKeys.hardware.tr(context),
          'value': deviceData['hardware'],
        });
      }
      if (deviceData.containsKey('board')) {
        items.add({
          'label': LocalizationKeys.board.tr(context),
          'value': deviceData['board'],
        });
      }
      if (deviceData.containsKey('bootloader')) {
        items.add({
          'label': LocalizationKeys.bootloader.tr(context),
          'value': deviceData['bootloader'],
        });
      }
      if (deviceData.containsKey('display')) {
        items.add({
          'label': LocalizationKeys.display.tr(context),
          'value': deviceData['display'],
        });
      }
      if (deviceData.containsKey('fingerprint')) {
        items.add({
          'label': LocalizationKeys.fingerprint.tr(context),
          'value': deviceData['fingerprint'],
        });
      }
      if (deviceData.containsKey('host')) {
        items.add({
          'label': LocalizationKeys.host.tr(context),
          'value': deviceData['host'],
        });
      }
      if (deviceData.containsKey('product')) {
        items.add({
          'label': LocalizationKeys.product.tr(context),
          'value': deviceData['product'],
        });
      }
      if (deviceData.containsKey('tags')) {
        items.add({
          'label': LocalizationKeys.tags.tr(context),
          'value': deviceData['tags'],
        });
      }
      if (deviceData.containsKey('type')) {
        items.add({
          'label': LocalizationKeys.type.tr(context),
          'value': deviceData['type'],
        });
      }
      if (deviceData.containsKey('androidId')) {
        items.add({
          'label': LocalizationKeys.androidId.tr(context),
          'value': deviceData['androidId'],
        });
      }
    } else if (Platform.isIOS) {
      if (deviceData.containsKey('identifierForVendor')) {
        items.add({
          'label': LocalizationKeys.identifier.tr(context),
          'value': deviceData['identifierForVendor'],
        });
      }
      if (deviceData.containsKey('isPhysicalDevice')) {
        items.add({
          'label': LocalizationKeys.physicalDevice.tr(context),
          'value': deviceData['isPhysicalDevice'].toString(),
        });
      }
      if (deviceData.containsKey('utsname.sysname')) {
        items.add({
          'label': LocalizationKeys.systemName.tr(context),
          'value': deviceData['utsname.sysname'],
        });
      }
      if (deviceData.containsKey('utsname.machine')) {
        items.add({
          'label': LocalizationKeys.machine.tr(context),
          'value': deviceData['utsname.machine'],
        });
      }
    } else if (Platform.isLinux) {
      if (deviceData.containsKey('idLike')) {
        items.add({
          'label': LocalizationKeys.idLike.tr(context),
          'value': deviceData['idLike'],
        });
      }
      if (deviceData.containsKey('variant')) {
        items.add({
          'label': LocalizationKeys.variant.tr(context),
          'value': deviceData['variant'],
        });
      }
      if (deviceData.containsKey('buildId')) {
        items.add({
          'label': LocalizationKeys.buildId.tr(context),
          'value': deviceData['buildId'],
        });
      }
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return InfoCard(
      title: LocalizationKeys.deviceDetails.tr(context),
      icon: Icons.devices_rounded,
      color: Colors.purple,
      items: items,
    );
  }
}

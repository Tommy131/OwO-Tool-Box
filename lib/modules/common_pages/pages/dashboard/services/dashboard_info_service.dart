import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:system_info2/system_info2.dart';

import '../models/dashboard_view_state.dart';
import 'windows_hardware_info_service.dart';

class DashboardInfoService {
  DashboardInfoService({
    DeviceInfoPlugin? deviceInfoPlugin,
    WindowsHardwareInfoService? windowsHardwareInfoService,
  }) : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin(),
       _windowsHardwareInfoService =
           windowsHardwareInfoService ?? WindowsHardwareInfoService();

  final DeviceInfoPlugin _deviceInfoPlugin;
  final WindowsHardwareInfoService _windowsHardwareInfoService;

  Future<DashboardViewState> loadAll() async {
    final deviceData = <String, dynamic>{};
    final systemData = <String, dynamic>{};

    await _loadDeviceData(deviceData);
    await _loadSystemData(systemData);

    return DashboardViewState(
      isLoading: false,
      deviceData: deviceData,
      systemData: systemData,
    );
  }

  Map<String, dynamic> loadMemorySnapshot() {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return const {};
    }

    try {
      return {
        'totalPhysicalMemory': SysInfo.getTotalPhysicalMemory(),
        'freePhysicalMemory': SysInfo.getFreePhysicalMemory(),
      };
    } catch (e) {
      debugPrint('Error updating memory info: $e');
      return const {};
    }
  }

  Future<void> _loadDeviceData(Map<String, dynamic> deviceData) async {
    if (Platform.isWindows) {
      final info = await _deviceInfoPlugin.windowsInfo;
      deviceData['platform'] = 'Windows';
      deviceData['computerName'] = info.computerName;
      deviceData['numberOfCores'] = info.numberOfCores;
      deviceData['systemMemoryInMegabytes'] = info.systemMemoryInMegabytes;
      deviceData['userName'] = info.userName;
      deviceData['majorVersion'] = info.majorVersion;
      deviceData['minorVersion'] = info.minorVersion;
      deviceData['buildNumber'] = info.buildNumber;
      deviceData['platformId'] = info.platformId;
      deviceData['productName'] = info.productName;
      deviceData['releaseId'] = info.releaseId;
      deviceData['displayVersion'] = info.displayVersion;
      return;
    }

    if (Platform.isLinux) {
      final info = await _deviceInfoPlugin.linuxInfo;
      deviceData['platform'] = 'Linux';
      deviceData['name'] = info.name;
      deviceData['version'] = info.version;
      deviceData['id'] = info.id;
      deviceData['idLike'] = info.idLike?.join(', ') ?? '';
      deviceData['versionCodename'] = info.versionCodename;
      deviceData['versionId'] = info.versionId;
      deviceData['prettyName'] = info.prettyName;
      deviceData['buildId'] = info.buildId;
      deviceData['variant'] = info.variant;
      deviceData['variantId'] = info.variantId;
      deviceData['machineId'] = info.machineId;
      return;
    }

    if (Platform.isMacOS) {
      final info = await _deviceInfoPlugin.macOsInfo;
      deviceData['platform'] = 'macOS';
      deviceData['computerName'] = info.computerName;
      deviceData['hostName'] = info.hostName;
      deviceData['arch'] = info.arch;
      deviceData['model'] = info.model;
      deviceData['kernelVersion'] = info.kernelVersion;
      deviceData['osRelease'] = info.osRelease;
      deviceData['majorVersion'] = info.majorVersion;
      deviceData['minorVersion'] = info.minorVersion;
      deviceData['patchVersion'] = info.patchVersion;
      deviceData['activeCPUs'] = info.activeCPUs;
      deviceData['memorySize'] = info.memorySize;
      deviceData['cpuFrequency'] = info.cpuFrequency;
      return;
    }

    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      deviceData['platform'] = 'Android';
      deviceData['brand'] = info.brand;
      deviceData['device'] = info.device;
      deviceData['model'] = info.model;
      deviceData['manufacturer'] = info.manufacturer;
      deviceData['product'] = info.product;
      deviceData['androidId'] = info.id;
      deviceData['versionRelease'] = info.version.release;
      deviceData['versionSdkInt'] = info.version.sdkInt;
      deviceData['versionCodename'] = info.version.codename;
      deviceData['board'] = info.board;
      deviceData['bootloader'] = info.bootloader;
      deviceData['display'] = info.display;
      deviceData['fingerprint'] = info.fingerprint;
      deviceData['hardware'] = info.hardware;
      deviceData['host'] = info.host;
      deviceData['tags'] = info.tags;
      deviceData['type'] = info.type;
      return;
    }

    if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;
      deviceData['platform'] = 'iOS';
      deviceData['name'] = info.name;
      deviceData['systemName'] = info.systemName;
      deviceData['systemVersion'] = info.systemVersion;
      deviceData['model'] = info.model;
      deviceData['localizedModel'] = info.localizedModel;
      deviceData['identifierForVendor'] = info.identifierForVendor;
      deviceData['isPhysicalDevice'] = info.isPhysicalDevice;
      deviceData['utsname.sysname'] = info.utsname.sysname;
      deviceData['utsname.nodename'] = info.utsname.nodename;
      deviceData['utsname.release'] = info.utsname.release;
      deviceData['utsname.version'] = info.utsname.version;
      deviceData['utsname.machine'] = info.utsname.machine;
    }
  }

  Future<void> _loadSystemData(Map<String, dynamic> systemData) async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return;
    }

    try {
      systemData['kernelName'] = SysInfo.kernelName;
      systemData['kernelVersion'] = SysInfo.kernelVersion;
      systemData['kernelArchitecture'] = SysInfo.kernelArchitecture
          .toString()
          .split('.')
          .last;
      systemData['operatingSystemName'] = SysInfo.operatingSystemName;
      systemData['operatingSystemVersion'] = SysInfo.operatingSystemVersion;
      systemData['totalPhysicalMemory'] = SysInfo.getTotalPhysicalMemory();
      systemData['freePhysicalMemory'] = SysInfo.getFreePhysicalMemory();

      await _loadMotherboard(systemData);
      await _loadProcessorModel(systemData);
    } catch (e) {
      debugPrint('Error loading system info: $e');
    }
  }

  Future<void> _loadMotherboard(Map<String, dynamic> systemData) async {
    if (Platform.isWindows) {
      final hardware = await _windowsHardwareInfoService.load();
      if (hardware['motherboard']?.isNotEmpty == true) {
        systemData['motherboard'] = hardware['motherboard'];
      }
      if (hardware['processorModel']?.isNotEmpty == true) {
        systemData['processorModel'] = hardware['processorModel'];
      }
      return;
    }

    if (Platform.isLinux) {
      try {
        final vendor = await File(
          '/sys/class/dmi/id/board_vendor',
        ).readAsString();
        final name = await File('/sys/class/dmi/id/board_name').readAsString();
        systemData['motherboard'] = '${vendor.trim()} ${name.trim()}';
      } catch (_) {}
    }
  }

  Future<void> _loadProcessorModel(Map<String, dynamic> systemData) async {
    if (systemData['processorModel']?.toString().isNotEmpty == true) {
      return;
    }

    if (Platform.isLinux) {
      try {
        final cpuInfo = await File('/proc/cpuinfo').readAsString();
        final lines = cpuInfo.split('\n');
        for (final line in lines) {
          if (!line.contains('model name')) {
            continue;
          }
          final parts = line.split(':');
          if (parts.length > 1) {
            systemData['processorModel'] = parts[1].trim();
            break;
          }
        }
      } catch (_) {}
      return;
    }

    if (Platform.isMacOS) {
      final result = await Process.run('sysctl', [
        '-n',
        'machdep.cpu.brand_string',
      ]);
      if (result.exitCode == 0) {
        systemData['processorModel'] = result.stdout.toString().trim();
      }
    }
  }
}

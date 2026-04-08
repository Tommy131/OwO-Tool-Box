import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:system_info2/system_info2.dart';

import '../models/dashboard_view_state.dart';
import 'windows_native_memory_service.dart';
import 'windows_hardware_info_service.dart';

class DashboardInfoService {
  DashboardInfoService({
    DeviceInfoPlugin? deviceInfoPlugin,
    WindowsHardwareInfoService? windowsHardwareInfoService,
    WindowsNativeMemoryService? windowsNativeMemoryService,
  }) : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin(),
       _windowsNativeMemoryService =
           windowsNativeMemoryService ?? WindowsNativeMemoryService(),
       _windowsHardwareInfoService =
           windowsHardwareInfoService ?? WindowsHardwareInfoService();

  final DeviceInfoPlugin _deviceInfoPlugin;
  final WindowsNativeMemoryService _windowsNativeMemoryService;
  final WindowsHardwareInfoService _windowsHardwareInfoService;

  Future<DashboardViewState> loadAll() async {
    final deviceData = <String, dynamic>{};
    final systemData = <String, dynamic>{};

    await _loadDeviceData(deviceData);
    await _loadSystemData(systemData, deviceData);

    return DashboardViewState(
      isLoading: false,
      deviceData: deviceData,
      systemData: systemData,
    );
  }

  Map<String, dynamic> loadMemorySnapshot() {
    if (!Platform.isWindows &&
        !Platform.isLinux &&
        !Platform.isMacOS &&
        !Platform.isAndroid) {
      return const {};
    }

    int? totalBytes;
    int? freeBytes;

    try {
      totalBytes = SysInfo.getTotalPhysicalMemory();
    } catch (_) {}

    try {
      freeBytes = SysInfo.getFreePhysicalMemory();
    } catch (_) {}

    if ((totalBytes == null || freeBytes == null) && Platform.isWindows) {
      final nativeFallback = _windowsNativeMemoryService.loadMemory();
      totalBytes ??= nativeFallback['totalBytes'];
      freeBytes ??= nativeFallback['freeBytes'];
    }

    if ((totalBytes == null || freeBytes == null) && Platform.isWindows) {
      final wmicFallback = _loadWindowsMemoryWithWmicSync();
      totalBytes ??= wmicFallback['totalBytes'];
      freeBytes ??= wmicFallback['freeBytes'];
    }

    if ((totalBytes == null || freeBytes == null) && Platform.isWindows) {
      final fallback = _loadWindowsMemoryFallbackSync();
      totalBytes ??= fallback['totalBytes'];
      freeBytes ??= fallback['freeBytes'];
    }
    if ((totalBytes == null || freeBytes == null) && Platform.isLinux) {
      final fallback = _loadLinuxMemoryFallbackSync();
      totalBytes ??= fallback['totalBytes'];
      freeBytes ??= fallback['freeBytes'];
    }
    if ((totalBytes == null || freeBytes == null) && Platform.isMacOS) {
      final fallback = _loadMacMemoryFallbackSync();
      totalBytes ??= fallback['totalBytes'];
      freeBytes ??= fallback['freeBytes'];
    }
    if ((totalBytes == null || freeBytes == null) && Platform.isAndroid) {
      final fallback = _loadLinuxMemoryFallbackSync();
      totalBytes ??= fallback['totalBytes'];
      freeBytes ??= fallback['freeBytes'];
    }

    final normalized = _normalizeMemoryValues(totalBytes, freeBytes);
    if (normalized == null) {
      return const {};
    }

    return {
      'totalPhysicalMemory': normalized.$1,
      if (normalized.$2 != null) 'freePhysicalMemory': normalized.$2!,
    };
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
      deviceData['supportedAbis'] = info.supportedAbis.join(', ');
      deviceData['supported32BitAbis'] = info.supported32BitAbis.join(', ');
      deviceData['supported64BitAbis'] = info.supported64BitAbis.join(', ');
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

  Future<void> _loadSystemData(
    Map<String, dynamic> systemData,
    Map<String, dynamic> deviceData,
  ) async {
    if (!Platform.isWindows &&
        !Platform.isLinux &&
        !Platform.isMacOS &&
        !Platform.isAndroid) {
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
    } catch (e) {
      debugPrint('Error loading basic system info: $e');
    }

    await _loadKernelArchitectureData(systemData, deviceData);
    await _loadKernelVersionData(systemData, deviceData);
    await _loadOperatingSystemData(systemData, deviceData);
    await _loadMemoryData(systemData, deviceData);
    await _loadMotherboard(systemData, deviceData);
    await _loadProcessorModel(systemData, deviceData);
  }

  Future<void> _loadKernelArchitectureData(
    Map<String, dynamic> systemData,
    Map<String, dynamic> deviceData,
  ) async {
    String? architecture = _normalizeArchitecture(
      _toNonEmptyString(systemData['kernelArchitecture']),
    );
    architecture ??= _normalizeArchitecture(
      _toNonEmptyString(deviceData['arch']),
    );
    architecture ??= _normalizeArchitecture(
      _toNonEmptyString(deviceData['supportedAbis'])?.split(',').first,
    );
    architecture ??= _normalizeArchitecture(
      _toNonEmptyString(deviceData['supported64BitAbis'])?.split(',').first,
    );

    if (architecture == null && Platform.isWindows) {
      architecture = _normalizeArchitecture(
        await _loadWindowsKernelArchitectureFallback(),
      );
    } else if (architecture == null && (Platform.isLinux || Platform.isMacOS)) {
      architecture = _normalizeArchitecture(
        await _loadUnixKernelArchitecture(),
      );
    }

    if (architecture != null) {
      systemData['kernelArchitecture'] = architecture;
    }
  }

  Future<void> _loadKernelVersionData(
    Map<String, dynamic> systemData,
    Map<String, dynamic> deviceData,
  ) async {
    String? kernelVersion = _toNonEmptyString(systemData['kernelVersion']);

    if (Platform.isWindows) {
      final fallback = await _loadWindowsOperatingSystemFallback();
      kernelVersion =
          kernelVersion ??
          _toNonEmptyString(fallback['version']) ??
          _toNonEmptyString(deviceData['buildNumber']) ??
          _toNonEmptyString(deviceData['displayVersion']);
    } else if (Platform.isAndroid) {
      kernelVersion ??=
          await _loadAndroidKernelVersion() ??
          _toNonEmptyString(deviceData['display']);
    } else if (Platform.isLinux || Platform.isMacOS) {
      kernelVersion ??= await _loadUnixKernelVersion();
      if (kernelVersion == null && Platform.isMacOS) {
        kernelVersion = _toNonEmptyString(deviceData['kernelVersion']);
      }
    }

    if (kernelVersion != null) {
      systemData['kernelVersion'] = kernelVersion;
    }
  }

  Future<void> _loadOperatingSystemData(
    Map<String, dynamic> systemData,
    Map<String, dynamic> deviceData,
  ) async {
    String? osName = _toNonEmptyString(systemData['operatingSystemName']);
    String? osVersion = _toNonEmptyString(systemData['operatingSystemVersion']);

    if (Platform.isWindows) {
      osName ??= _toNonEmptyString(deviceData['productName']);
      osVersion ??=
          _toNonEmptyString(deviceData['displayVersion']) ??
          _toNonEmptyString(deviceData['releaseId']);

      if (osVersion == null) {
        final major = _toNonEmptyString(deviceData['majorVersion']);
        final minor = _toNonEmptyString(deviceData['minorVersion']);
        final build = _toNonEmptyString(deviceData['buildNumber']);
        final parts = [major, minor, build]
            .where((value) => value != null && value.isNotEmpty)
            .cast<String>()
            .toList();
        if (parts.isNotEmpty) {
          osVersion = parts.join('.');
        }
      }

      if (osName == null || osVersion == null) {
        final fallback = await _loadWindowsOperatingSystemFallback();
        osName ??= fallback['name'];
        osVersion ??= fallback['version'];
      }
    } else if (Platform.isLinux) {
      osName ??=
          _toNonEmptyString(deviceData['prettyName']) ??
          _toNonEmptyString(deviceData['name']);
      osVersion ??=
          _toNonEmptyString(deviceData['version']) ??
          _toNonEmptyString(deviceData['versionId']);
    } else if (Platform.isMacOS) {
      osName ??= 'macOS';
      osVersion ??=
          _toNonEmptyString(deviceData['osRelease']) ??
          _toNonEmptyString(deviceData['majorVersion']);
    } else if (Platform.isAndroid) {
      osName ??= 'Android';
      osVersion ??=
          _toNonEmptyString(deviceData['versionRelease']) ??
          _toNonEmptyString(deviceData['versionSdkInt']);
    }

    if (osName != null) {
      systemData['operatingSystemName'] = osName;
    }
    if (osVersion != null) {
      systemData['operatingSystemVersion'] = osVersion;
    }
  }

  Future<Map<String, String>> _loadWindowsOperatingSystemFallback() async {
    try {
      const script = r'''
$os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($null -eq $os) {
  $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
}
if ($null -ne $os) {
  $caption = $os.Caption.ToString().Trim()
  $version = $os.Version.ToString().Trim()
  Write-Output "$caption`n$version"
}
''';

      final result = await Process.run('powershell', [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script.trim(),
      ]);

      if (result.exitCode != 0) {
        return const {};
      }

      final lines = result.stdout
          .toString()
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isEmpty) {
        return const {};
      }

      return {
        if (lines.isNotEmpty) 'name': lines.first,
        if (lines.length > 1) 'version': lines[1],
      };
    } catch (_) {
      return const {};
    }
  }

  Future<String?> _loadWindowsKernelArchitectureFallback() async {
    try {
      const script = r'''
$arch = $env:PROCESSOR_ARCHITECTURE
if ([string]::IsNullOrWhiteSpace($arch) -and -not [string]::IsNullOrWhiteSpace($env:PROCESSOR_ARCHITEW6432)) {
  $arch = $env:PROCESSOR_ARCHITEW6432
}
if ([string]::IsNullOrWhiteSpace($arch)) {
  $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -eq $cpu) {
    $cpu = Get-WmiObject -Class Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
  }
  if ($null -ne $cpu -and $null -ne $cpu.Architecture) {
    $arch = $cpu.Architecture.ToString().Trim()
  }
}
if (-not [string]::IsNullOrWhiteSpace($arch)) {
  Write-Output $arch
}
''';

      final result = await Process.run('powershell', [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script.trim(),
      ]);

      if (result.exitCode != 0) {
        return null;
      }

      return _toNonEmptyString(result.stdout);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _loadUnixKernelArchitecture() async {
    try {
      final result = await Process.run('uname', ['-m']);
      if (result.exitCode != 0) {
        return null;
      }
      return _toNonEmptyString(result.stdout);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _loadUnixKernelVersion() async {
    try {
      final result = await Process.run('uname', ['-r']);
      if (result.exitCode != 0) {
        return null;
      }
      return _toNonEmptyString(result.stdout);
    } catch (_) {
      return null;
    }
  }

  String? _normalizeArchitecture(String? raw) {
    if (raw == null) {
      return null;
    }

    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty || _isUnknownLike(normalized)) {
      return null;
    }

    final code = int.tryParse(normalized);
    if (code != null) {
      switch (code) {
        case 0:
          return 'x86';
        case 5:
          return 'arm';
        case 9:
          return 'x64';
        case 12:
          return 'arm64';
      }
    }

    if (normalized.contains('aarch64') || normalized.contains('arm64')) {
      return 'arm64';
    }
    if (normalized == 'x86' ||
        normalized == 'i386' ||
        normalized == 'i486' ||
        normalized == 'i586' ||
        normalized == 'i686') {
      return 'x86';
    }
    if (normalized.contains('x86_64') ||
        normalized.contains('amd64') ||
        normalized == 'x64') {
      return 'x64';
    }
    if (normalized.contains('arm')) {
      return 'arm';
    }

    return raw.trim();
  }

  String? _toNonEmptyString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || _isUnknownLike(text.toLowerCase())) {
      return null;
    }
    return text;
  }

  bool _isUnknownLike(String value) {
    return value == 'unknown' ||
        value == 'unk' ||
        value == 'n/a' ||
        value == 'na' ||
        value == 'not available' ||
        value == 'undefined' ||
        value == 'null' ||
        value == '-';
  }

  (int, int?)? _normalizeMemoryValues(int? totalBytes, int? freeBytes) {
    if (totalBytes == null || totalBytes <= 0) {
      return null;
    }

    int? normalizedFree;
    if (freeBytes != null && freeBytes >= 0) {
      normalizedFree = freeBytes > totalBytes ? totalBytes : freeBytes;
    }

    return (totalBytes, normalizedFree);
  }

  Future<void> _loadMemoryData(
    Map<String, dynamic> systemData,
    Map<String, dynamic> deviceData,
  ) async {
    int? totalBytes;
    int? freeBytes;

    try {
      totalBytes = SysInfo.getTotalPhysicalMemory();
    } catch (_) {}

    try {
      freeBytes = SysInfo.getFreePhysicalMemory();
    } catch (_) {}

    if ((totalBytes == null || freeBytes == null) && Platform.isWindows) {
      final nativeFallback = _windowsNativeMemoryService.loadMemory();
      totalBytes ??= nativeFallback['totalBytes'];
      freeBytes ??= nativeFallback['freeBytes'];
    }

    if ((totalBytes == null || freeBytes == null) && Platform.isWindows) {
      final wmicFallback = await _loadWindowsMemoryWithWmic();
      totalBytes ??= wmicFallback['totalBytes'];
      freeBytes ??= wmicFallback['freeBytes'];
    }

    if ((totalBytes == null || freeBytes == null) && Platform.isWindows) {
      final fallback = await _loadWindowsMemoryFallback();
      totalBytes ??= fallback['totalBytes'];
      freeBytes ??= fallback['freeBytes'];
    }
    if ((totalBytes == null || freeBytes == null) && Platform.isLinux) {
      final fallback = await _loadLinuxMemoryFallback();
      totalBytes ??= fallback['totalBytes'];
      freeBytes ??= fallback['freeBytes'];
    }
    if ((totalBytes == null || freeBytes == null) && Platform.isMacOS) {
      final fallback = await _loadMacMemoryFallback();
      totalBytes ??= fallback['totalBytes'];
      freeBytes ??= fallback['freeBytes'];
    }
    if ((totalBytes == null || freeBytes == null) && Platform.isAndroid) {
      final fallback = await _loadLinuxMemoryFallback();
      totalBytes ??= fallback['totalBytes'];
      freeBytes ??= fallback['freeBytes'];
    }

    totalBytes ??= _extractTotalMemoryHintFromDeviceData(deviceData);
    final normalized = _normalizeMemoryValues(totalBytes, freeBytes);
    if (normalized != null) {
      systemData['totalPhysicalMemory'] = normalized.$1;
      if (normalized.$2 != null) {
        systemData['freePhysicalMemory'] = normalized.$2!;
      }
    }
  }

  int? _extractTotalMemoryHintFromDeviceData(Map<String, dynamic> deviceData) {
    if (deviceData['systemMemoryInMegabytes'] is num) {
      return (deviceData['systemMemoryInMegabytes'] as num).toInt() *
          1024 *
          1024;
    }

    if (deviceData['memorySize'] is num) {
      return (deviceData['memorySize'] as num).toInt();
    }

    return null;
  }

  Future<Map<String, int>> _loadWindowsMemoryFallback() async {
    try {
      const script = r'''
$os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($null -eq $os) {
  $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
}

$totalKb = $null
$freeKb = $null
$freeBytes = $null
$committedPercent = $null

if ($null -ne $os) {
  if ($os.TotalVisibleMemorySize) { $totalKb = [int64]$os.TotalVisibleMemorySize }
  if ($os.FreePhysicalMemory) { $freeKb = [int64]$os.FreePhysicalMemory }
}

if ($null -eq $freeKb) {
  try {
    $perfMem = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Memory -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $perfMem) {
      $perfMem = Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_Memory -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    if ($null -ne $perfMem -and $perfMem.AvailableBytes) {
      $freeBytes = [int64]$perfMem.AvailableBytes
    }
  } catch {}
}

if ($null -eq $freeKb -and $null -eq $freeBytes) {
  try {
    $counter = Get-Counter '\Memory\Available Bytes' -ErrorAction Stop
    if ($null -ne $counter -and $counter.CounterSamples.Count -gt 0) {
      $freeBytes = [int64]$counter.CounterSamples[0].CookedValue
    }
  } catch {}
}

if ($null -eq $freeKb -and $null -eq $freeBytes) {
  try {
    $counter2 = Get-Counter '\Memory\% Committed Bytes In Use' -ErrorAction Stop
    if ($null -ne $counter2 -and $counter2.CounterSamples.Count -gt 0) {
      $committedPercent = [double]$counter2.CounterSamples[0].CookedValue
    }
  } catch {}
}

$obj = [pscustomobject]@{
  totalKb = $totalKb
  freeKb = $freeKb
  freeBytes = $freeBytes
  committedPercent = $committedPercent
}

$json = $obj | ConvertTo-Json -Compress
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json))
''';

      final result = await Process.run('powershell', [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script.trim(),
      ]);

      if (result.exitCode != 0) {
        return const {};
      }

      final base64Text = _extractLastNonEmptyLine(result.stdout.toString());
      if (base64Text.isEmpty) {
        return const {};
      }

      final jsonText = utf8.decode(base64Decode(base64Text));
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) {
        return const {};
      }

      final totalKb = _toInt64(decoded['totalKb']);
      final freeKb = _toInt64(decoded['freeKb']);
      final freeBytesCounter = _toInt64(decoded['freeBytes']);
      final committedPercent = _toDouble(decoded['committedPercent']);

      int? freeBytes;
      if (freeKb != null && freeKb >= 0) {
        freeBytes = freeKb * 1024;
      } else if (freeBytesCounter != null && freeBytesCounter >= 0) {
        freeBytes = freeBytesCounter;
      } else if (totalKb != null &&
          totalKb > 0 &&
          committedPercent != null &&
          committedPercent >= 0 &&
          committedPercent <= 100) {
        final totalBytes = totalKb * 1024;
        freeBytes = (totalBytes * (100 - committedPercent) / 100).round();
      }

      if (totalKb == null && freeBytes == null) {
        return const {};
      }

      return {
        if (totalKb != null && totalKb > 0) 'totalBytes': totalKb * 1024,
        if (freeBytes != null && freeBytes >= 0) 'freeBytes': freeBytes,
      };
    } catch (_) {
      return const {};
    }
  }

  Map<String, int> _loadWindowsMemoryFallbackSync() {
    try {
      final result = Process.runSync('powershell', [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        r'''
$os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($null -eq $os) {
  $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
}

$totalKb = $null
$freeKb = $null
$freeBytes = $null
$committedPercent = $null

if ($null -ne $os) {
  if ($os.TotalVisibleMemorySize) { $totalKb = [int64]$os.TotalVisibleMemorySize }
  if ($os.FreePhysicalMemory) { $freeKb = [int64]$os.FreePhysicalMemory }
}

if ($null -eq $freeKb) {
  try {
    $perfMem = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Memory -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $perfMem) {
      $perfMem = Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_Memory -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    if ($null -ne $perfMem -and $perfMem.AvailableBytes) {
      $freeBytes = [int64]$perfMem.AvailableBytes
    }
  } catch {}
}

if ($null -eq $freeKb -and $null -eq $freeBytes) {
  try {
    $counter = Get-Counter '\Memory\Available Bytes' -ErrorAction Stop
    if ($null -ne $counter -and $counter.CounterSamples.Count -gt 0) {
      $freeBytes = [int64]$counter.CounterSamples[0].CookedValue
    }
  } catch {}
}

if ($null -eq $freeKb -and $null -eq $freeBytes) {
  try {
    $counter2 = Get-Counter '\Memory\% Committed Bytes In Use' -ErrorAction Stop
    if ($null -ne $counter2 -and $counter2.CounterSamples.Count -gt 0) {
      $committedPercent = [double]$counter2.CounterSamples[0].CookedValue
    }
  } catch {}
}

$obj = [pscustomobject]@{
  totalKb = $totalKb
  freeKb = $freeKb
  freeBytes = $freeBytes
  committedPercent = $committedPercent
}

$json = $obj | ConvertTo-Json -Compress
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json))
'''
            .trim(),
      ]);

      if (result.exitCode != 0) {
        return const {};
      }

      final base64Text = _extractLastNonEmptyLine(result.stdout.toString());
      if (base64Text.isEmpty) {
        return const {};
      }

      final jsonText = utf8.decode(base64Decode(base64Text));
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) {
        return const {};
      }

      final totalKb = _toInt64(decoded['totalKb']);
      final freeKb = _toInt64(decoded['freeKb']);
      final freeBytesCounter = _toInt64(decoded['freeBytes']);
      final committedPercent = _toDouble(decoded['committedPercent']);

      int? freeBytes;
      if (freeKb != null && freeKb >= 0) {
        freeBytes = freeKb * 1024;
      } else if (freeBytesCounter != null && freeBytesCounter >= 0) {
        freeBytes = freeBytesCounter;
      } else if (totalKb != null &&
          totalKb > 0 &&
          committedPercent != null &&
          committedPercent >= 0 &&
          committedPercent <= 100) {
        final totalBytes = totalKb * 1024;
        freeBytes = (totalBytes * (100 - committedPercent) / 100).round();
      }

      return {
        if (totalKb != null && totalKb > 0) 'totalBytes': totalKb * 1024,
        if (freeBytes != null && freeBytes >= 0) 'freeBytes': freeBytes,
      };
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, int>> _loadWindowsMemoryWithWmic() async {
    try {
      final result = await Process.run('wmic', [
        'OS',
        'get',
        'FreePhysicalMemory,TotalVisibleMemorySize',
        '/value',
      ]);
      if (result.exitCode != 0) {
        return const {};
      }
      return _parseWindowsMemoryWmicOutput(result.stdout.toString());
    } catch (_) {
      return const {};
    }
  }

  Map<String, int> _loadWindowsMemoryWithWmicSync() {
    try {
      final result = Process.runSync('wmic', [
        'OS',
        'get',
        'FreePhysicalMemory,TotalVisibleMemorySize',
        '/value',
      ]);
      if (result.exitCode != 0) {
        return const {};
      }
      return _parseWindowsMemoryWmicOutput(result.stdout.toString());
    } catch (_) {
      return const {};
    }
  }

  Map<String, int> _parseWindowsMemoryWmicOutput(String output) {
    int? totalKb;
    int? freeKb;
    for (final rawLine in output.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      if (line.isEmpty || !line.contains('=')) {
        continue;
      }
      final index = line.indexOf('=');
      final key = line.substring(0, index).trim();
      final value = line.substring(index + 1).trim();
      if (key == 'TotalVisibleMemorySize') {
        totalKb = int.tryParse(value);
      } else if (key == 'FreePhysicalMemory') {
        freeKb = int.tryParse(value);
      }
    }
    return {
      if (totalKb != null && totalKb > 0) 'totalBytes': totalKb * 1024,
      if (freeKb != null && freeKb >= 0) 'freeBytes': freeKb * 1024,
    };
  }

  Future<Map<String, int>> _loadLinuxMemoryFallback() async {
    try {
      final content = await File('/proc/meminfo').readAsString();
      return _parseLinuxMemInfo(content);
    } catch (_) {
      return const {};
    }
  }

  Map<String, int> _loadLinuxMemoryFallbackSync() {
    try {
      final content = File('/proc/meminfo').readAsStringSync();
      return _parseLinuxMemInfo(content);
    } catch (_) {
      return const {};
    }
  }

  Map<String, int> _parseLinuxMemInfo(String content) {
    int? totalKb;
    int? availableKb;
    int? freeKb;
    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.startsWith('MemTotal:')) {
        totalKb = _parseKbValue(line);
      } else if (line.startsWith('MemAvailable:')) {
        availableKb = _parseKbValue(line);
      } else if (line.startsWith('MemFree:')) {
        freeKb = _parseKbValue(line);
      }
    }

    final effectiveFreeKb = availableKb ?? freeKb;
    return {
      if (totalKb != null && totalKb > 0) 'totalBytes': totalKb * 1024,
      if (effectiveFreeKb != null && effectiveFreeKb >= 0)
        'freeBytes': effectiveFreeKb * 1024,
    };
  }

  Future<Map<String, int>> _loadMacMemoryFallback() async {
    try {
      final totalResult = await Process.run('sysctl', ['-n', 'hw.memsize']);
      if (totalResult.exitCode != 0) {
        return const {};
      }
      final totalBytes = int.tryParse(totalResult.stdout.toString().trim());

      final vmStatResult = await Process.run('vm_stat', const []);
      if (vmStatResult.exitCode != 0) {
        return {
          if (totalBytes != null && totalBytes > 0) 'totalBytes': totalBytes,
        };
      }

      return _parseMacVmStat(
        vmStatResult.stdout.toString(),
        totalBytes: totalBytes,
      );
    } catch (_) {
      return const {};
    }
  }

  Future<String?> _loadAndroidKernelVersion() async {
    try {
      final content = await File('/proc/version').readAsString();
      final value = _toNonEmptyString(content);
      if (value == null) {
        return null;
      }
      return value.replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (_) {
      return null;
    }
  }

  Map<String, int> _loadMacMemoryFallbackSync() {
    try {
      final totalResult = Process.runSync('sysctl', ['-n', 'hw.memsize']);
      if (totalResult.exitCode != 0) {
        return const {};
      }
      final totalBytes = int.tryParse(totalResult.stdout.toString().trim());

      final vmStatResult = Process.runSync('vm_stat', const []);
      if (vmStatResult.exitCode != 0) {
        return {
          if (totalBytes != null && totalBytes > 0) 'totalBytes': totalBytes,
        };
      }

      return _parseMacVmStat(
        vmStatResult.stdout.toString(),
        totalBytes: totalBytes,
      );
    } catch (_) {
      return const {};
    }
  }

  Map<String, int> _parseMacVmStat(String vmStatOutput, {int? totalBytes}) {
    final pageSize = _parseMacPageSize(vmStatOutput) ?? 4096;
    int freePages = 0;
    int inactivePages = 0;
    int speculativePages = 0;

    for (final rawLine in vmStatOutput.split('\n')) {
      final line = rawLine.trim();
      if (line.startsWith('Pages free:')) {
        freePages = _parseVmStatPages(line) ?? freePages;
      } else if (line.startsWith('Pages inactive:')) {
        inactivePages = _parseVmStatPages(line) ?? inactivePages;
      } else if (line.startsWith('Pages speculative:')) {
        speculativePages = _parseVmStatPages(line) ?? speculativePages;
      }
    }

    final freeBytes = (freePages + inactivePages + speculativePages) * pageSize;
    return {
      if (totalBytes != null && totalBytes > 0) 'totalBytes': totalBytes,
      if (freeBytes >= 0) 'freeBytes': freeBytes,
    };
  }

  int? _toInt64(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString().trim());
  }

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().trim());
  }

  int? _parseKbValue(String line) {
    final match = RegExp(r'(\d+)').firstMatch(line);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1)!);
  }

  int? _parseMacPageSize(String vmStatOutput) {
    final match = RegExp(
      r'page size of\s+(\d+)\s+bytes',
      caseSensitive: false,
    ).firstMatch(vmStatOutput);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1)!);
  }

  int? _parseVmStatPages(String line) {
    final match = RegExp(r':\s*([0-9]+)\.?').firstMatch(line);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1)!);
  }

  String _extractLastNonEmptyLine(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    for (var i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].trim();
      if (line.isNotEmpty) {
        return line;
      }
    }
    return '';
  }

  Future<void> _loadMotherboard(
    Map<String, dynamic> systemData,
    Map<String, dynamic> deviceData,
  ) async {
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
      return;
    }

    if (Platform.isAndroid) {
      final board = _toNonEmptyString(deviceData['board']);
      _toNonEmptyString(systemData['androidBoard']);
      if (board != null) {
        systemData['motherboard'] = board;
      }
    }
  }

  Future<void> _loadProcessorModel(
    Map<String, dynamic> systemData,
    Map<String, dynamic> deviceData,
  ) async {
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
      return;
    }

    if (Platform.isAndroid) {
      final processorModel =
          _toNonEmptyString(deviceData['hardware']) ??
          _toNonEmptyString(deviceData['model']) ??
          _toNonEmptyString(deviceData['product']);
      if (processorModel != null) {
        systemData['processorModel'] = processorModel;
      }
    }
  }
}

/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-30
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2026-01-30
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:system_info2/system_info2.dart';

import '../../../../core/services/localization_service.dart';
import '../../../../core/theme/theme_provider.dart';

import '../../localization/localization_keys.dart';
import 'widgets/info_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/animated_dashboard_background.dart';

/// 设备信息仪表板页面
/// 显示当前设备的详细信息，包括CPU、内存、系统等
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  bool _isLoading = true;
  Map<String, dynamic> _deviceData = {};
  Map<String, dynamic> _systemData = {};
  Timer? _memoryTimer;

  Future<Map<String, String>> _loadWindowsHardwareInfo() async {
    final data = <String, String>{};

    try {
      final baseboardResult = await Process.run('wmic', [
        'baseboard',
        'get',
        'product,Manufacturer',
        '/format:list',
      ]);
      if (baseboardResult.exitCode == 0) {
        final lines = baseboardResult.stdout.toString().split(RegExp(r'\r?\n'));
        String manufacturer = '';
        String product = '';
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('Manufacturer=')) {
            manufacturer = trimmed.substring('Manufacturer='.length).trim();
          } else if (trimmed.startsWith('Product=')) {
            product = trimmed.substring('Product='.length).trim();
          }
        }
        final motherboard = '$manufacturer $product'.trim();
        if (motherboard.isNotEmpty) {
          data['motherboard'] = motherboard;
        }
      }
    } catch (_) {}

    try {
      final cpuResult = await Process.run('wmic', ['cpu', 'get', 'name']);
      if (cpuResult.exitCode == 0) {
        final lines = cpuResult.stdout.toString().split(RegExp(r'\r?\n'));
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && trimmed != 'Name') {
            data['processorModel'] = trimmed;
            break;
          }
        }
      }
    } catch (_) {}

    if (data['motherboard']?.isNotEmpty == true &&
        data['processorModel']?.isNotEmpty == true) {
      return data;
    }

    try {
      const script = r'''
function Get-First([string] $className) {
  try {
    return Get-CimInstance -ClassName $className -ErrorAction Stop | Select-Object -First 1
  } catch {
    try {
      return Get-WmiObject -Class $className -ErrorAction Stop | Select-Object -First 1
    } catch {
      return $null
    }
  }
}

$bb = Get-First 'Win32_BaseBoard'
$cpu = Get-First 'Win32_Processor'

$motherboard = ''
if ($bb -ne $null) {
  $parts = @()
  if ($bb.Manufacturer) { $parts += ($bb.Manufacturer.ToString().Trim()) }
  if ($bb.Product) { $parts += ($bb.Product.ToString().Trim()) }
  $motherboard = ($parts | Where-Object { $_ -and $_.Trim() -ne '' } | ForEach-Object { $_.Trim() }) -join ' '
}

$processorModel = ''
if ($cpu -ne $null -and $cpu.Name) {
  $processorModel = $cpu.Name.ToString().Trim()
}

$obj = [pscustomobject]@{
  motherboard = $motherboard
  processorModel = $processorModel
}

$json = $obj | ConvertTo-Json -Compress
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json))
''';

      final psCommand =
          '[Console]::OutputEncoding=[Text.Encoding]::UTF8; \$OutputEncoding=[Console]::OutputEncoding; \$ProgressPreference="SilentlyContinue"; ${script.trim()}';

      final psResult = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-NonInteractive',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          psCommand,
        ],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      if (psResult.exitCode == 0) {
        final base64Text = psResult.stdout.toString().trim();
        if (base64Text.isNotEmpty) {
          final jsonText = utf8.decode(base64Decode(base64Text));
          final decoded = jsonDecode(jsonText);
          if (decoded is Map) {
            final motherboard = decoded['motherboard']?.toString().trim() ?? '';
            final processorModel =
                decoded['processorModel']?.toString().trim() ?? '';
            if (data['motherboard']?.isNotEmpty != true &&
                motherboard.isNotEmpty) {
              data['motherboard'] = motherboard;
            }
            if (data['processorModel']?.isNotEmpty != true &&
                processorModel.isNotEmpty) {
              data['processorModel'] = processorModel;
            }
          }
        }
      }
    } catch (_) {}

    return data;
  }

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
    _startMemoryTimer();
  }

  @override
  void dispose() {
    _memoryTimer?.cancel();
    super.dispose();
  }

  /// 启动实时内存更新定时器
  void _startMemoryTimer() {
    _memoryTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && !_isLoading) {
        _updateMemoryInfo();
      }
    });
  }

  /// 仅更新内存信息
  void _updateMemoryInfo() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        setState(() {
          _systemData['totalPhysicalMemory'] = SysInfo.getTotalPhysicalMemory();
          _systemData['freePhysicalMemory'] = SysInfo.getFreePhysicalMemory();
        });
      } catch (e) {
        debugPrint('Error updating memory info: $e');
      }
    }
  }

  String _tr(String key) => key.tr(context);

  Future<void> _loadDeviceInfo() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final deviceData = <String, dynamic>{};
      final systemData = <String, dynamic>{};

      // 获取系统信息
      if (Platform.isWindows) {
        final info = await _deviceInfo.windowsInfo;
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
      } else if (Platform.isLinux) {
        final info = await _deviceInfo.linuxInfo;
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
      } else if (Platform.isMacOS) {
        final info = await _deviceInfo.macOsInfo;
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
      } else if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
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
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
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

      // 获取系统硬件信息 (仅桌面平台)
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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

          if (Platform.isWindows) {
            final hardware = await _loadWindowsHardwareInfo();
            if (hardware['motherboard']?.isNotEmpty == true) {
              systemData['motherboard'] = hardware['motherboard'];
            }
            if (hardware['processorModel']?.isNotEmpty == true) {
              systemData['processorModel'] = hardware['processorModel'];
            }
          } else if (Platform.isLinux) {
            try {
              final vendor = await File(
                '/sys/class/dmi/id/board_vendor',
              ).readAsString();
              final name = await File(
                '/sys/class/dmi/id/board_name',
              ).readAsString();
              systemData['motherboard'] = '${vendor.trim()} ${name.trim()}';
            } catch (_) {
              // Ignore if not accessible
            }
          }

          if (Platform.isLinux) {
            try {
              final cpuInfo = await File('/proc/cpuinfo').readAsString();
              final lines = cpuInfo.split('\n');
              for (var line in lines) {
                if (line.contains('model name')) {
                  final parts = line.split(':');
                  if (parts.length > 1) {
                    systemData['processorModel'] = parts[1].trim();
                    break;
                  }
                }
              }
            } catch (_) {}
          } else if (Platform.isMacOS) {
            final result = await Process.run('sysctl', [
              '-n',
              'machdep.cpu.brand_string',
            ]);
            if (result.exitCode == 0) {
              systemData['processorModel'] = result.stdout.toString().trim();
            }
          }
        } catch (e) {
          debugPrint('Error loading system info: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _deviceData = deviceData;
        _systemData = systemData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading device info: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.currentTheme.primaryColor;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedDashboardBackground(),
          SafeArea(
            child: _isLoading
                ? _buildLoadingState(theme, primaryColor)
                : RefreshIndicator(
                    onRefresh: _loadDeviceInfo,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme, primaryColor),
                          const SizedBox(height: 24),
                          _buildStatsOverview(theme, primaryColor),
                          const SizedBox(height: 24),
                          _buildSystemInfo(theme, primaryColor),
                          const SizedBox(height: 24),
                          _buildDeviceDetails(theme, primaryColor),
                          if (_systemData.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildHardwareInfo(theme, primaryColor),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation(primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _tr(LocalizationKeys.loadingDeviceInfo),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.dashboard_rounded, size: 40, color: primaryColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr(LocalizationKeys.deviceInfo),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _deviceData['platform'] ??
                      _tr(LocalizationKeys.unknownPlatform),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryColor),
            onPressed: _loadDeviceInfo,
            tooltip: _tr(LocalizationKeys.refreshDeviceInfo),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(ThemeData theme, Color primaryColor) {
    final stats = <Map<String, dynamic>>[];

    // CPU信息
    if (_deviceData.containsKey('numberOfCores')) {
      stats.add({
        'icon': Icons.memory_rounded,
        'label': _tr(LocalizationKeys.processor),
        'value':
            '${_deviceData['numberOfCores']} ${_tr(LocalizationKeys.coresUnit)}',
        'color': Colors.blue,
      });
    }

    // 内存信息
    if (_systemData.containsKey('totalPhysicalMemory')) {
      final totalGB =
          (_systemData['totalPhysicalMemory'] / (1024 * 1024 * 1024));
      final freeGB = (_systemData['freePhysicalMemory'] / (1024 * 1024 * 1024));
      final usedGB = totalGB - freeGB;
      final usagePercent = (usedGB / totalGB * 100).toStringAsFixed(1);

      stats.add({
        'icon': Icons.storage_rounded,
        'label': _tr(LocalizationKeys.memoryUsage),
        'value': '$usagePercent%',
        'color': Colors.green,
      });
    } else if (_deviceData.containsKey('systemMemoryInMegabytes')) {
      final totalGB = (_deviceData['systemMemoryInMegabytes'] / 1024)
          .toStringAsFixed(1);
      stats.add({
        'icon': Icons.storage_rounded,
        'label': _tr(LocalizationKeys.totalMemory),
        'value': '$totalGB GB',
        'color': Colors.green,
      });
    } else if (_deviceData.containsKey('memorySize')) {
      final totalGB = (_deviceData['memorySize'] / (1024 * 1024 * 1024))
          .toStringAsFixed(1);
      stats.add({
        'icon': Icons.storage_rounded,
        'label': _tr(LocalizationKeys.totalMemory),
        'value': '$totalGB GB',
        'color': Colors.green,
      });
    }

    // 系统架构
    if (_systemData.containsKey('kernelArchitecture')) {
      stats.add({
        'icon': Icons.architecture_rounded,
        'label': _tr(LocalizationKeys.systemArchitecture),
        'value': _systemData['kernelArchitecture'],
        'color': Colors.orange,
      });
    } else if (_deviceData.containsKey('arch')) {
      stats.add({
        'icon': Icons.architecture_rounded,
        'label': _tr(LocalizationKeys.systemArchitecture),
        'value': _deviceData['arch'],
        'color': Colors.orange,
      });
    }

    // 平台
    stats.add({
      'icon': Icons.computer_rounded,
      'label': _tr(LocalizationKeys.platform),
      'value': _deviceData['platform'] ?? _tr(LocalizationKeys.unknownValue),
      'color': primaryColor,
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
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

  Widget _buildSystemInfo(ThemeData theme, Color primaryColor) {
    final items = <Map<String, String>>[];

    if (Platform.isWindows) {
      if (_deviceData.containsKey('productName')) {
        items.add({
          'label': _tr(LocalizationKeys.operatingSystem),
          'value': _deviceData['productName'],
        });
      }
      if (_deviceData.containsKey('displayVersion')) {
        items.add({
          'label': _tr(LocalizationKeys.version),
          'value': _deviceData['displayVersion'],
        });
      }
      if (_deviceData.containsKey('buildNumber')) {
        items.add({
          'label': _tr(LocalizationKeys.build),
          'value': _deviceData['buildNumber'].toString(),
        });
      }
      if (_deviceData.containsKey('computerName')) {
        items.add({
          'label': _tr(LocalizationKeys.hostname),
          'value': _deviceData['computerName'],
        });
      }
      if (_deviceData.containsKey('userName')) {
        items.add({
          'label': _tr(LocalizationKeys.user),
          'value': _deviceData['userName'],
        });
      }
    } else if (Platform.isLinux) {
      if (_deviceData.containsKey('prettyName')) {
        items.add({
          'label': _tr(LocalizationKeys.operatingSystem),
          'value': _deviceData['prettyName'],
        });
      }
      if (_deviceData.containsKey('versionCodename')) {
        items.add({
          'label': _tr(LocalizationKeys.codename),
          'value': _deviceData['versionCodename'],
        });
      }
      if (_deviceData.containsKey('id')) {
        items.add({
          'label': _tr(LocalizationKeys.distributionId),
          'value': _deviceData['id'],
        });
      }
      if (_deviceData.containsKey('machineId')) {
        items.add({
          'label': _tr(LocalizationKeys.machineId),
          'value': _deviceData['machineId'],
        });
      }
    } else if (Platform.isMacOS) {
      if (_deviceData.containsKey('model')) {
        items.add({
          'label': _tr(LocalizationKeys.model),
          'value': _deviceData['model'],
        });
      }
      if (_deviceData.containsKey('osRelease')) {
        items.add({
          'label': _tr(LocalizationKeys.operatingSystem),
          'value': 'macOS ${_deviceData['osRelease']}',
        });
      }
      if (_deviceData.containsKey('computerName')) {
        items.add({
          'label': _tr(LocalizationKeys.hostname),
          'value': _deviceData['computerName'],
        });
      }
      if (_deviceData.containsKey('hostName')) {
        items.add({
          'label': _tr(LocalizationKeys.hostname),
          'value': _deviceData['hostName'],
        });
      }
    } else if (Platform.isAndroid) {
      if (_deviceData.containsKey('manufacturer') &&
          _deviceData.containsKey('model')) {
        items.add({
          'label': _tr(LocalizationKeys.device),
          'value': '${_deviceData['manufacturer']} ${_deviceData['model']}',
        });
      }
      if (_deviceData.containsKey('versionRelease')) {
        items.add({
          'label': _tr(LocalizationKeys.androidVersion),
          'value': _deviceData['versionRelease'],
        });
      }
      if (_deviceData.containsKey('versionSdkInt')) {
        items.add({
          'label': _tr(LocalizationKeys.sdkLevel),
          'value': _deviceData['versionSdkInt'].toString(),
        });
      }
      if (_deviceData.containsKey('brand')) {
        items.add({
          'label': _tr(LocalizationKeys.brand),
          'value': _deviceData['brand'],
        });
      }
    } else if (Platform.isIOS) {
      if (_deviceData.containsKey('name')) {
        items.add({
          'label': _tr(LocalizationKeys.deviceName),
          'value': _deviceData['name'],
        });
      }
      if (_deviceData.containsKey('systemVersion')) {
        items.add({
          'label': _tr(LocalizationKeys.iosVersion),
          'value': _deviceData['systemVersion'],
        });
      }
      if (_deviceData.containsKey('model')) {
        items.add({
          'label': _tr(LocalizationKeys.model),
          'value': _deviceData['model'],
        });
      }
      if (_deviceData.containsKey('localizedModel')) {
        items.add({
          'label': _tr(LocalizationKeys.localizedModel),
          'value': _deviceData['localizedModel'],
        });
      }
    }

    if (_systemData.containsKey('kernelVersion')) {
      items.add({
        'label': _tr(LocalizationKeys.kernelVersion),
        'value': _systemData['kernelVersion'],
      });
    }

    return InfoCard(
      title: _tr(LocalizationKeys.systemInfo),
      icon: Icons.info_outline_rounded,
      color: primaryColor,
      items: items,
    );
  }

  Widget _buildDeviceDetails(ThemeData theme, Color primaryColor) {
    final items = <Map<String, String>>[];

    if (Platform.isAndroid) {
      if (_deviceData.containsKey('hardware')) {
        items.add({
          'label': _tr(LocalizationKeys.hardware),
          'value': _deviceData['hardware'],
        });
      }
      if (_deviceData.containsKey('board')) {
        items.add({
          'label': _tr(LocalizationKeys.board),
          'value': _deviceData['board'],
        });
      }
      if (_deviceData.containsKey('bootloader')) {
        items.add({
          'label': _tr(LocalizationKeys.bootloader),
          'value': _deviceData['bootloader'],
        });
      }
      if (_deviceData.containsKey('display')) {
        items.add({
          'label': _tr(LocalizationKeys.display),
          'value': _deviceData['display'],
        });
      }
      if (_deviceData.containsKey('fingerprint')) {
        items.add({
          'label': _tr(LocalizationKeys.fingerprint),
          'value': _deviceData['fingerprint'],
        });
      }
      if (_deviceData.containsKey('host')) {
        items.add({
          'label': _tr(LocalizationKeys.host),
          'value': _deviceData['host'],
        });
      }
      if (_deviceData.containsKey('product')) {
        items.add({
          'label': _tr(LocalizationKeys.product),
          'value': _deviceData['product'],
        });
      }
      if (_deviceData.containsKey('tags')) {
        items.add({
          'label': _tr(LocalizationKeys.tags),
          'value': _deviceData['tags'],
        });
      }
      if (_deviceData.containsKey('type')) {
        items.add({
          'label': _tr(LocalizationKeys.type),
          'value': _deviceData['type'],
        });
      }
      if (_deviceData.containsKey('androidId')) {
        items.add({
          'label': _tr(LocalizationKeys.androidId),
          'value': _deviceData['androidId'],
        });
      }
    } else if (Platform.isIOS) {
      if (_deviceData.containsKey('identifierForVendor')) {
        items.add({
          'label': _tr(LocalizationKeys.identifier),
          'value': _deviceData['identifierForVendor'],
        });
      }
      if (_deviceData.containsKey('isPhysicalDevice')) {
        items.add({
          'label': _tr(LocalizationKeys.physicalDevice),
          'value': _deviceData['isPhysicalDevice'].toString(),
        });
      }
      if (_deviceData.containsKey('utsname.sysname')) {
        items.add({
          'label': _tr(LocalizationKeys.systemName),
          'value': _deviceData['utsname.sysname'],
        });
      }
      if (_deviceData.containsKey('utsname.machine')) {
        items.add({
          'label': _tr(LocalizationKeys.machine),
          'value': _deviceData['utsname.machine'],
        });
      }
    } else if (Platform.isLinux) {
      if (_deviceData.containsKey('idLike')) {
        items.add({
          'label': _tr(LocalizationKeys.idLike),
          'value': _deviceData['idLike'],
        });
      }
      if (_deviceData.containsKey('variant')) {
        items.add({
          'label': _tr(LocalizationKeys.variant),
          'value': _deviceData['variant'],
        });
      }
      if (_deviceData.containsKey('buildId')) {
        items.add({
          'label': _tr(LocalizationKeys.buildId),
          'value': _deviceData['buildId'],
        });
      }
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return InfoCard(
      title: _tr(LocalizationKeys.deviceDetails),
      icon: Icons.devices_rounded,
      color: Colors.purple,
      items: items,
    );
  }

  Widget _buildHardwareInfo(ThemeData theme, Color primaryColor) {
    final items = <Map<String, String>>[];

    if (_systemData.containsKey('motherboard')) {
      items.add({
        'label': _tr(LocalizationKeys.motherboard),
        'value': _systemData['motherboard'],
      });
    }

    if (_systemData.containsKey('processorModel')) {
      items.add({
        'label': _tr(LocalizationKeys.processorModel),
        'value': _systemData['processorModel'],
      });
    }

    if (_systemData.containsKey('totalPhysicalMemory')) {
      final total = _systemData['totalPhysicalMemory'] / (1024 * 1024 * 1024);
      final free = _systemData['freePhysicalMemory'] / (1024 * 1024 * 1024);
      final used = total - free;

      items.add({
        'label': _tr(LocalizationKeys.memoryTotal),
        'value': '${total.toStringAsFixed(2)} GB',
      });
      items.add({
        'label': _tr(LocalizationKeys.memoryUsed),
        'value':
            '${used.toStringAsFixed(2)} GB (${(used / total * 100).toStringAsFixed(1)}%)',
      });
      items.add({
        'label': _tr(LocalizationKeys.memoryFree),
        'value': '${free.toStringAsFixed(2)} GB',
      });
    }

    if (_systemData.containsKey('operatingSystemName')) {
      items.add({
        'label': _tr(LocalizationKeys.osName),
        'value': _systemData['operatingSystemName'],
      });
    }

    if (_systemData.containsKey('operatingSystemVersion')) {
      items.add({
        'label': _tr(LocalizationKeys.osVersion),
        'value': _systemData['operatingSystemVersion'],
      });
    }

    if (_systemData.containsKey('kernelArchitecture')) {
      items.add({
        'label': _tr(LocalizationKeys.kernelArchitecture),
        'value': _systemData['kernelArchitecture'],
      });
    }

    return InfoCard(
      title: _tr(LocalizationKeys.hardwareDetails),
      icon: Icons.settings_input_component_rounded,
      color: Colors.teal,
      items: items,
    );
  }
}

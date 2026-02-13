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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../format_utils.dart';
import '../models/system_info_model.dart';
import '../providers/host_monitor_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/metric_chart.dart';
import '../../../core/services/localization_service.dart';
import '../localization/localization_keys.dart';

// ==================== 常量配置 ====================
class _Constants {
  static const double cardBorderRadius = 16.0;
  static const double smallCardBorderRadius = 14.0;
  static const double itemBorderRadius = 10.0;
  static const double chipBorderRadius = 8.0;

  static const double standardPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double miniPadding = 4.0;

  static const double iconSize = 18.0;
  static const double smallIconSize = 14.0;

  static const double progressBarHeight = 8.0;
  static const double smallProgressBarHeight = 6.0;

  static const double wideScreenBreakpoint = 600.0;
}

// ==================== 主屏幕组件 ====================
class HostDetailPage extends StatefulWidget {
  final VoidCallback onDisconnect;
  const HostDetailPage({super.key, required this.onDisconnect});

  @override
  State<HostDetailPage> createState() => _HostDetailPageState();
}

class _HostDetailPageState extends State<HostDetailPage> {
  bool _isWaitingSystemInfo = false;
  late SystemInfoModel _systemInfo;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _initializeDataRefresh();
  }

  void _initializeDataRefresh() {
    final provider = context.read<HostMonitorProvider>();
    setState(() => _isWaitingSystemInfo = true);

    _timer = Timer.periodic(
      // Duration(seconds: provider.settings.refreshInterval),
      const Duration(milliseconds: 300),
      (_) => _updateSystemInfo(provider),
    );
  }

  void _updateSystemInfo(HostMonitorProvider provider) {
    if (provider.systemInfo != null) {
      setState(() {
        _systemInfo = provider.systemInfo!;
        _isWaitingSystemInfo = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: _isWaitingSystemInfo ? _WaitingCard() : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_Constants.standardPadding),
      child: Column(
        children: [
          _ConnectionCard(),
          const SizedBox(height: _Constants.standardPadding),
          _ChartsSection(),
          const SizedBox(height: _Constants.standardPadding),
          _InfoCardsSection(systemInfo: _systemInfo),
          const SizedBox(height: _Constants.standardPadding),
          _DisconnectButton(onDisconnect: widget.onDisconnect),
        ],
      ),
    );
  }
}

// ==================== 等待数据卡片 ====================
class _WaitingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String tr(String key) => LocalizationService().translate(key);

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: _Constants.standardPadding),
              Text(
                tr(LocalizationKeys.waitingSystemData),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: _Constants.smallPadding),
              Text(
                tr(LocalizationKeys.connectedGettingSystemInfo),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 连接状态卡片 ====================
class _ConnectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final host = context.read<HostMonitorProvider>().currentHost;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String tr(String key) => LocalizationService().translate(key);

    return _StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusIndicator(context, colorScheme),
          const SizedBox(height: 12),
          Text(
            host?.name ?? tr(LocalizationKeys.unnamedHost),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: _Constants.smallPadding),
          Text(
            '${host?.address}:${host?.port}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, ColorScheme colorScheme) {
    const statusColor = Colors.green;
    String tr(String key) => LocalizationService().translate(key);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: statusColor, blurRadius: 6, spreadRadius: 1),
            ],
          ),
        ),
        const SizedBox(width: _Constants.smallPadding),
        Text(
          tr(LocalizationKeys.connected),
          style: const TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ==================== 图表区域 ====================
class _ChartsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<HostMonitorProvider>();
    final history = provider.metricsHistory;

    return Column(
      children: [
        ..._buildMetricCharts(context, history),
        const SizedBox(height: 12),
        _buildLoadCharts(context, history),
      ],
    );
  }

  List<Widget> _buildMetricCharts(BuildContext context, dynamic history) {
    String tr(String key) => LocalizationService().translate(key);

    final charts = [
      _ChartConfig(
        tr(LocalizationKeys.cpuUsageTrend),
        history.cpuHistory,
        Colors.blue,
        unit: '%',
      ),
      _ChartConfig(
        tr(LocalizationKeys.memoryUsageTrend),
        history.memoryHistory,
        Colors.orange,
        unit: '%',
      ),
      _ChartConfig(
        tr(LocalizationKeys.diskUsageTrend),
        history.diskHistory,
        Colors.purple,
        unit: '%',
      ),
      _ChartConfig(
        tr(LocalizationKeys.uploadSpeedLabel),
        history.uploadHistory,
        Colors.green,
        isSpeed: true,
      ),
      _ChartConfig(
        tr(LocalizationKeys.downloadSpeedLabel),
        history.downloadHistory,
        Colors.cyan,
        isSpeed: true,
      ),
    ];

    return charts
        .map(
          (config) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MetricsChart(
              dataPoints: config.data,
              title: config.title,
              lineColor: config.color,
              gradientStartColor: config.color,
              gradientEndColor: config.darkColor,
              unit: config.unit,
              isNetworkSpeed: config.isSpeed,
            ),
          ),
        )
        .toList();
  }

  Widget _buildLoadCharts(BuildContext context, dynamic history) {
    String tr(String key) => LocalizationService().translate(key);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > _Constants.wideScreenBreakpoint;
        final charts = [
          _LoadChartConfig(
            tr(LocalizationKeys.load1min),
            history.load1History,
            Colors.amber,
          ),
          _LoadChartConfig(
            tr(LocalizationKeys.load5min),
            history.load5History,
            Colors.deepOrange,
          ),
          _LoadChartConfig(
            tr(LocalizationKeys.load15min),
            history.load15History,
            Colors.red,
          ),
        ];

        if (isWide) {
          return Row(
            children: charts
                .map(
                  (config) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildLoadChart(config),
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: charts
              .map(
                (config) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLoadChart(config),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildLoadChart(_LoadChartConfig config) {
    return MetricsChart(
      dataPoints: config.data,
      title: config.title,
      lineColor: config.color,
      gradientStartColor: config.color,
      gradientEndColor: config.darkColor,
      unit: '',
      isNetworkSpeed: false,
    );
  }
}

// ==================== 信息卡片区域 ====================
class _InfoCardsSection extends StatelessWidget {
  final SystemInfoModel systemInfo;

  const _InfoCardsSection({required this.systemInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (systemInfo.cpu.perCoreUsage.isNotEmpty) ...[
          _CPUCoresCard(cores: systemInfo.cpu.perCoreUsage),
          const SizedBox(height: _Constants.standardPadding),
        ],
        _SystemInfoCard(systemInfo: systemInfo),
        const SizedBox(height: _Constants.standardPadding),
        _MemoryCard(memory: systemInfo.memory),
        const SizedBox(height: _Constants.standardPadding),
        if (systemInfo.disks.isNotEmpty) ...[
          _DisksCard(disks: systemInfo.disks),
          const SizedBox(height: _Constants.standardPadding),
        ],
        if (systemInfo.networks.isNotEmpty)
          _NetworkCard(networks: systemInfo.networks),
      ],
    );
  }
}

// ==================== CPU核心卡片 ====================
class _CPUCoresCard extends StatelessWidget {
  final List<double> cores;

  const _CPUCoresCard({required this.cores});

  @override
  Widget build(BuildContext context) {
    String tr(String key) => LocalizationService().translate(key);

    return _StyledCard(
      borderRadius: _Constants.smallCardBorderRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.memory,
            title: tr(LocalizationKeys.cpuCoreUsage),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: _Constants.smallPadding,
            runSpacing: _Constants.smallPadding,
            children: cores
                .asMap()
                .entries
                .map((entry) => _CoreChip(index: entry.key, usage: entry.value))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CoreChip extends StatelessWidget {
  final int index;
  final double usage;

  const _CoreChip({required this.index, required this.usage});

  @override
  Widget build(BuildContext context) {
    final color = FormatUtils.getColorForUsage(usage);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(_Constants.chipBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$index',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: _Constants.miniPadding),
          Text(
            '${usage.toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ==================== 系统信息卡片 ====================
class _SystemInfoCard extends StatelessWidget {
  final SystemInfoModel systemInfo;

  const _SystemInfoCard({required this.systemInfo});

  @override
  Widget build(BuildContext context) {
    final system = systemInfo.system;
    final cpu = systemInfo.cpu;
    final load = systemInfo.loadAverage;

    String tr(String key) => LocalizationService().translate(key);

    return _StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.info_outline,
            title: tr(LocalizationKeys.systemInfo),
          ),
          const SizedBox(height: _Constants.standardPadding),
          ..._buildInfoRows([
            (tr(LocalizationKeys.processor), cpu.modelName),
            (
              tr(LocalizationKeys.processorCores),
              '${cpu.cores} ${tr(LocalizationKeys.coresUnit)}',
            ),
            (
              tr(LocalizationKeys.processorFrequency),
              '${cpu.frequencyMhz.toStringAsFixed(0)} MHz',
            ),
            (
              tr(LocalizationKeys.processCount),
              '${systemInfo.processCount} ${tr(LocalizationKeys.countUnit)}',
            ),
            (
              tr(LocalizationKeys.systemLoad),
              '${load.load1min.toStringAsFixed(2)} / '
                  '${load.load5min.toStringAsFixed(2)} / '
                  '${load.load15min.toStringAsFixed(2)}',
            ),
            (tr(LocalizationKeys.systemArchitecture), system.kernelArch),
            (
              tr(LocalizationKeys.operatingSystem),
              '${system.platform} ${system.platformVersion}',
            ),
            (tr(LocalizationKeys.kernelVersion), system.kernelVersion),
            (tr(LocalizationKeys.hostname), system.hostname),
            (
              tr(LocalizationKeys.uptime),
              FormatUtils.formatUptime(systemInfo.uptime),
            ),
          ]),
        ],
      ),
    );
  }

  List<Widget> _buildInfoRows(List<(String, String)> items) {
    return items
        .expand(
          (item) => [
            _DetailRow(label: item.$1, value: item.$2),
            if (item != items.last) const SizedBox(height: 10),
          ],
        )
        .toList();
  }
}

// ==================== 内存卡片 ====================
class _MemoryCard extends StatelessWidget {
  final MemoryInfo memory;

  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    String tr(String key) => LocalizationService().translate(key);

    return _StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.memory,
            title: tr(LocalizationKeys.memoryDetails),
          ),
          const SizedBox(height: _Constants.standardPadding),
          _ProgressBar(
            label: tr(LocalizationKeys.usageRate),
            value: memory.usageRate,
            height: _Constants.progressBarHeight,
          ),
          const SizedBox(height: 12),
          ..._buildInfoRows(context, [
            (tr(LocalizationKeys.totalMemory), '${memory.total} MB'),
            (tr(LocalizationKeys.usedMemory), '${memory.used} MB'),
            (tr(LocalizationKeys.availableMemory), '${memory.available} MB'),
          ]),
        ],
      ),
    );
  }

  List<Widget> _buildInfoRows(
    BuildContext context,
    List<(String, String)> items,
  ) {
    return items
        .expand(
          (item) => [
            _DetailRow(label: item.$1, value: item.$2),
            if (item != items.last)
              const SizedBox(height: _Constants.smallPadding),
          ],
        )
        .toList();
  }
}

// ==================== 磁盘卡片 ====================
class _DisksCard extends StatelessWidget {
  final List<DiskInfo> disks;

  const _DisksCard({required this.disks});

  @override
  Widget build(BuildContext context) {
    String tr(String key) => LocalizationService().translate(key);

    return _StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.storage,
            title: tr(LocalizationKeys.diskDetails),
          ),
          const SizedBox(height: _Constants.standardPadding),
          ...disks.map(
            (disk) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DiskItem(disk: disk),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiskItem extends StatelessWidget {
  final DiskInfo disk;

  const _DiskItem({required this.disk});

  @override
  Widget build(BuildContext context) {
    final color = FormatUtils.getColorForUsage(disk.usageRate);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String tr(String key) => LocalizationService().translate(key);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(_Constants.itemBorderRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  disk.mountPoint,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${disk.usageRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: _Constants.miniPadding),
          Text(
            disk.device,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: _Constants.smallPadding),
          _ProgressBar(
            value: disk.usageRate,
            height: _Constants.smallProgressBarHeight,
            showLabel: false,
          ),
          const SizedBox(height: _Constants.smallPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tr(LocalizationKeys.used)}: ${disk.used} GB',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
              Text(
                '${tr(LocalizationKeys.total)}: ${disk.total} GB',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== 网络卡片 ====================
class _NetworkCard extends StatelessWidget {
  final List<NetworkInfo> networks;

  const _NetworkCard({required this.networks});

  @override
  Widget build(BuildContext context) {
    String tr(String key) => LocalizationService().translate(key);

    return _StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.network_check,
            title: tr(LocalizationKeys.networkDetails),
          ),
          const SizedBox(height: _Constants.standardPadding),
          ...networks.map((network) => _NetworkItem(network: network)),
        ],
      ),
    );
  }
}

class _NetworkItem extends StatelessWidget {
  final NetworkInfo network;

  const _NetworkItem({required this.network});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String tr(String key) => LocalizationService().translate(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(_Constants.itemBorderRadius),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(network.interface, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NetworkSpeedInfo(
                  icon: Icons.upload,
                  label: tr(LocalizationKeys.upload),
                  speed: network.uploadSpeed,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _NetworkSpeedInfo(
                  icon: Icons.download,
                  label: tr(LocalizationKeys.download),
                  speed: network.downloadSpeed,
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: tr(LocalizationKeys.bytesSent),
            value: FormatUtils.formatBytes(network.bytesSent),
          ),
          const SizedBox(height: 6),
          _DetailRow(
            label: tr(LocalizationKeys.bytesReceived),
            value: FormatUtils.formatBytes(network.bytesReceived),
          ),
        ],
      ),
    );
  }
}

class _NetworkSpeedInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final double speed;
  final Color color;

  const _NetworkSpeedInfo({
    required this.icon,
    required this.label,
    required this.speed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: _Constants.smallIconSize),
            const SizedBox(width: _Constants.miniPadding),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: _Constants.miniPadding),
        Text(
          FormatUtils.formatNetworkSpeed(speed),
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ==================== 断开连接按钮 ====================
class _DisconnectButton extends StatelessWidget {
  final VoidCallback onDisconnect;

  const _DisconnectButton({required this.onDisconnect});

  @override
  Widget build(BuildContext context) {
    String tr(String key) => LocalizationService().translate(key);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onDisconnect,
        child: Text(
          tr(LocalizationKeys.disconnect),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ==================== 通用UI组件 ====================
class _StyledCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const _StyledCard({
    required this.child,
    this.borderRadius = _Constants.cardBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(_Constants.standardPadding),
        child: child,
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: _Constants.iconSize),
        const SizedBox(width: _Constants.smallPadding),
        Text(title, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String? label;
  final double value;
  final double height;
  final bool showLabel;

  const _ProgressBar({
    this.label,
    required this.value,
    required this.height,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = FormatUtils.getColorForUsage(value);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        if (showLabel && label != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        if (showLabel && label != null)
          const SizedBox(height: _Constants.smallPadding),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: height,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ==================== 配置类 ====================
class _ChartConfig {
  final String title;
  final dynamic data;
  final Color color;
  final bool isSpeed;
  final String unit;

  _ChartConfig(
    this.title,
    this.data,
    this.color, {
    this.isSpeed = false,
    String? unit,
  }) : unit = unit ?? (isSpeed ? ' KB/s' : '');

  Color get darkColor => Color.lerp(color, Colors.black, 0.5)!;
}

class _LoadChartConfig {
  final String title;
  final dynamic data;
  final Color color;

  _LoadChartConfig(this.title, this.data, this.color);

  Color get darkColor => Color.lerp(color, Colors.black, 0.5)!;
}

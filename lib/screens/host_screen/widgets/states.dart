import 'package:flutter/material.dart' hide ConnectionState;
import 'package:provider/provider.dart';

import '../../../models/host_config.dart';
import '../../../models/system_info.dart';
import '../../../providers/system_provider.dart';

import '../../../utils/format_utils.dart';
import '../host_theme.dart';
import 'metrics_chart.dart';

class States {
  final BuildContext context;
  final SystemProvider provider;
  final bool isDark;
  late Color cardColor;

  States(this.context, this.provider, this.isDark);

  // 断开连接状态
  Widget buildDisconnectedState({
    required bool isLoadingHosts,
    required List<HostConfig> savedHosts,
    required VoidCallback onShowConnectionDialog,
    required Function(HostConfig) onConnectToHost,
  }) {
    if (isLoadingHosts) {
      return const Center(
        child: CircularProgressIndicator(color: HostTheme.primaryColor),
      );
    }

    if (savedHosts.isEmpty) {
      return _buildEmptyState(onShowConnectionDialog);
    }

    return _buildHostsList(savedHosts, onConnectToHost);
  }

  // 空状态
  Widget _buildEmptyState(VoidCallback onShowConnectionDialog) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                HostTheme.primaryGradient.createShader(bounds),
            child: const Icon(Icons.cloud_off, size: 100, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            '暂无保存的主机',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            '点击右下角按钮添加主机',
            style: TextStyle(fontSize: 16, color: Colors.white60),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: HostTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: onShowConnectionDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('添加主机',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

// 主机列表
  Widget _buildHostsList(
    List<HostConfig> savedHosts,
    Function(HostConfig) onConnectToHost,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedHosts.length,
      itemBuilder: (context, index) {
        final host = savedHosts[index];
        return _buildHostCard(host, onConnectToHost);
      },
    );
  }

// 主机卡片
  Widget _buildHostCard(
    HostConfig host,
    Function(HostConfig) onConnectToHost,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HostTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onConnectToHost(host),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: HostTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dns, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 状态指示器（根据不同状态显示不同颜色）
                        if (host.status != HostStatus.unknown) ...[
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: FormatUtils.getStatusColor(host.status),
                              shape: BoxShape.circle,
                              boxShadow: host.status == HostStatus.online
                                  ? [
                                      BoxShadow(
                                        color: FormatUtils.getStatusColor(
                                            host.status),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            host.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Token错误时显示警告图标
                        if (host.status == HostStatus.authFailed) ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Token验证失败',
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red.shade400,
                              size: 18,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${host.host}:${host.port}',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (host.lastConnected != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '最后连接: ${FormatUtils.formatDateTime(host.lastConnected!)}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                    // 显示状态文字
                    if (host.status != HostStatus.unknown) ...[
                      const SizedBox(height: 4),
                      Text(
                        FormatUtils.getStatusText(host.status),
                        style: TextStyle(
                          color: FormatUtils.getStatusColor(host.status)
                              .withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: HostTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: () => onConnectToHost(host),
                  tooltip: '连接',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// 连接中状态
  Widget buildConnectingState() {
    final host = provider.currentHost;

    return Center(
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '正在连接至服务器: ${host?.name}...',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

// 错误状态
  Widget buildErrorState({
    required Function(HostConfig) onReconnect,
    required Function(HostConfig) onEditHost,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: HostTheme.accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: HostTheme.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '连接失败',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? '未知错误',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 32),
            if (provider.currentHost != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onEditHost(provider.currentHost!),
                    icon: const Icon(Icons.edit),
                    label: const Text('修改配置'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: HostTheme.primaryColor.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: HostTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => onReconnect(provider.currentHost!),
                      icon: const Icon(Icons.refresh),
                      label: const Text('重新连接'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  gradient: HostTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () => provider.disconnect(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('返回'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

// 已连接状态
  Widget buildConnectedState() {
    return (provider.systemInfo != null)
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildConnectionCard(),
                const SizedBox(height: 16),
                ...[_buildColumnLayout(provider.systemInfo!)],
                const SizedBox(height: 16),
                _buildDisconnectButton(),
              ],
            ),
          )
        : _buildWaitingForDataCard();
  }

  Widget _buildConnectionCard() {
    final host = provider.currentHost;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: HostTheme.primaryColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: HostTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.green, blurRadius: 6, spreadRadius: 1)
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '已连接',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            host?.name ?? '未命名主机',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${host?.host}:${host?.port}',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForDataCard() {
    return Center(
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                '等待系统数据...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '已连接到服务器，正在获取系统信息',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 修改后的布局：图表保持不变，信息卡片改为单列
  Widget _buildColumnLayout(
    SystemInfo systemInfo,
  ) {
    return Column(
      children: [
        // 图表区域（保持不变）
        _buildChartsSection(),
        const SizedBox(height: 16),

        // 以下所有信息卡片改为单列显示
        if (systemInfo.cpu.usageRate.isNotEmpty) ...[
          _buildCPUCoresCard(systemInfo.cpu),
          const SizedBox(height: 16),
        ],

        _buildSystemInfoCard(systemInfo),
        const SizedBox(height: 16),

        _buildMemoryCard(systemInfo.memory),
        const SizedBox(height: 16),

        if (systemInfo.disks.isNotEmpty) ...[
          _buildDisksCard(systemInfo.disks),
          const SizedBox(height: 16),
        ],

        if (systemInfo.network.isNotEmpty)
          _buildNetworkCard(systemInfo.network),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        MetricsChart(
          dataPoints: provider.metricsHistory.cpuHistory,
          title: 'CPU 使用率趋势',
          cardColor: cardColor,
          lineColor: Colors.blue,
          gradientStartColor: Colors.blue,
          gradientEndColor: Colors.blue.shade900,
        ),
        const SizedBox(height: 12),
        MetricsChart(
          dataPoints: provider.metricsHistory.memoryHistory,
          title: '内存使用率趋势',
          cardColor: cardColor,
          lineColor: Colors.orange,
          gradientStartColor: Colors.orange,
          gradientEndColor: Colors.orange.shade900,
        ),
        const SizedBox(height: 12),
        MetricsChart(
          dataPoints: provider.metricsHistory.diskHistory,
          title: '磁盘使用率趋势',
          cardColor: cardColor,
          lineColor: Colors.purple,
          gradientStartColor: Colors.purple,
          gradientEndColor: Colors.purple.shade900,
        ),
        const SizedBox(height: 12),
        MetricsChart(
          dataPoints: provider.metricsHistory.uploadHistory,
          title: '上传速率',
          cardColor: cardColor,
          lineColor: Colors.green,
          gradientStartColor: Colors.green,
          gradientEndColor: Colors.green.shade900,
          unit: ' KB/s',
          isNetworkSpeed: true,
        ),
        const SizedBox(height: 12),
        MetricsChart(
          dataPoints: provider.metricsHistory.downloadHistory,
          title: '下载速率',
          cardColor: cardColor,
          lineColor: Colors.cyan,
          gradientStartColor: Colors.cyan,
          gradientEndColor: Colors.cyan.shade900,
          unit: ' KB/s',
          isNetworkSpeed: true,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            // 如果宽度大于600px，显示三列；否则显示一列
            final isWideScreen = constraints.maxWidth > 600;

            if (isWideScreen) {
              // 横屏或平板：三个图表并排
              return Row(
                children: [
                  Expanded(child: _buildLoadChart1()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildLoadChart5()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildLoadChart15()),
                ],
              );
            } else {
              // 竖屏手机：垂直排列
              return Column(
                children: [
                  _buildLoadChart1(),
                  const SizedBox(height: 12),
                  _buildLoadChart5(),
                  const SizedBox(height: 12),
                  _buildLoadChart15(),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  // 辅助方法：1分钟负载图表
  Widget _buildLoadChart1() {
    return MetricsChart(
      dataPoints: provider.metricsHistory.load1History,
      title: '负载(1分钟)',
      cardColor: cardColor,
      lineColor: Colors.amber,
      gradientStartColor: Colors.amber,
      gradientEndColor: Colors.amber.shade900,
      unit: '',
      isNetworkSpeed: false,
    );
  }

// 辅助方法：5分钟负载图表
  Widget _buildLoadChart5() {
    return MetricsChart(
      dataPoints: provider.metricsHistory.load5History,
      title: '负载(5分钟)',
      cardColor: cardColor,
      lineColor: Colors.deepOrange,
      gradientStartColor: Colors.deepOrange,
      gradientEndColor: Colors.deepOrange.shade900,
      unit: '',
      isNetworkSpeed: false,
    );
  }

// 辅助方法：15分钟负载图表
  Widget _buildLoadChart15() {
    return MetricsChart(
      dataPoints: provider.metricsHistory.load15History,
      title: '负载(15分钟)',
      cardColor: cardColor,
      lineColor: Colors.red,
      gradientStartColor: Colors.red,
      gradientEndColor: Colors.red.shade900,
      unit: '',
      isNetworkSpeed: false,
    );
  }

  Widget _buildCPUCoresCard(CPUInfo cpu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HostTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.memory, color: HostTheme.primaryColor, size: 18),
              SizedBox(width: 8),
              Text(
                'CPU 核心使用率',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cpu.usageRate.asMap().entries.map((entry) {
              final index = entry.key;
              final usage = entry.value;
              return _buildCoreChip(index, usage);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreChip(int index, double usage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: FormatUtils.getColorForUsage(usage).withOpacity(0.2),
        border: Border.all(
          color: FormatUtils.getColorForUsage(usage),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$index',
            style: TextStyle(
              color: FormatUtils.getColorForUsage(usage),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${usage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoCard(SystemInfo systemInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HostTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: HostTheme.primaryColor, size: 18),
              SizedBox(width: 8),
              Text(
                '系统信息',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('处理器', systemInfo.cpu.modelName),
          const SizedBox(height: 10),
          _buildDetailRow('处理器核心', '${systemInfo.cpu.cores} 核心'),
          const SizedBox(height: 10),
          _buildDetailRow(
              '处理器频率', '${systemInfo.cpu.frequency.toStringAsFixed(0)} MHz'),
          const SizedBox(height: 10),
          _buildDetailRow('进程数量', '${systemInfo.processCount} 个'),
          const SizedBox(height: 10),
          _buildDetailRow(
              '系统负载',
              '${systemInfo.loadAverage.load1.toStringAsFixed(2)} / '
                  '${systemInfo.loadAverage.load5.toStringAsFixed(2)} / '
                  '${systemInfo.loadAverage.load15.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildDetailRow('系统架构', systemInfo.mainboard.kernelArch),
          const SizedBox(height: 10),
          _buildDetailRow('操作系统',
              '${systemInfo.mainboard.platform} ${systemInfo.mainboard.platformVersion}'),
          const SizedBox(height: 10),
          _buildDetailRow('内核版本', systemInfo.mainboard.kernelVersion),
          const SizedBox(height: 10),
          _buildDetailRow('主机名', systemInfo.mainboard.hostname),
          const SizedBox(height: 10),
          _buildDetailRow('运行时间', FormatUtils.formatUptime(systemInfo.uptime)),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(MemoryInfo memory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HostTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.memory, color: HostTheme.primaryColor, size: 18),
              SizedBox(width: 8),
              Text(
                '内存详情',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMemoryBar(memory),
          const SizedBox(height: 12),
          _buildDetailRow('总内存', '${memory.total} MB'),
          const SizedBox(height: 8),
          _buildDetailRow('已使用', '${memory.used} MB'),
          const SizedBox(height: 8),
          _buildDetailRow('可用内存', '${memory.available} MB'),
        ],
      ),
    );
  }

  Widget _buildMemoryBar(MemoryInfo memory) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '使用率',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            Text(
              '${memory.usageRate.toStringAsFixed(1)}%',
              style: TextStyle(
                color: FormatUtils.getColorForUsage(memory.usageRate),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: memory.usageRate / 100,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              FormatUtils.getColorForUsage(memory.usageRate),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisksCard(List<DiskInfo> disks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HostTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storage, color: HostTheme.primaryColor, size: 18),
              SizedBox(width: 8),
              Text(
                '磁盘详情',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...disks.map((disk) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDiskItem(disk),
              )),
        ],
      ),
    );
  }

  Widget _buildDiskItem(DiskInfo disk) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: FormatUtils.getColorForUsage(disk.usageRate).withOpacity(0.3),
          width: 1,
        ),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${disk.usageRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: FormatUtils.getColorForUsage(disk.usageRate),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            disk.device,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: disk.usageRate / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                FormatUtils.getColorForUsage(disk.usageRate),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已用: ${disk.used} GB',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              Text(
                '总计: ${disk.total} GB',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(List<NetworkInfo> networks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HostTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.network_check,
                  color: HostTheme.primaryColor, size: 18),
              SizedBox(width: 8),
              Text(
                '网络详情',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...networks.map((network) => _buildNetworkItem(network)),
        ],
      ),
    );
  }

  Widget _buildNetworkItem(NetworkInfo network) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: HostTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            network.interface,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.upload, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '上传',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FormatUtils.formatNetworkSpeed(network.uploadSpeed),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.download, color: Colors.cyan, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '下载',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FormatUtils.formatNetworkSpeed(network.downloadSpeed),
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('已发送', FormatUtils.formatBytes(network.bytesSent)),
          const SizedBox(height: 6),
          _buildDetailRow('已接收', FormatUtils.formatBytes(network.bytesRecv)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 14)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDisconnectButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => context.read<SystemProvider>().disconnect(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: HostTheme.accentColor),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          '断开连接',
          style: TextStyle(
              color: HostTheme.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../network_input_rules.dart';
import '../../providers/perf_test_provider.dart';
import '../shared/network_tool_widgets.dart';

class PerfTestTab extends StatelessWidget {
  const PerfTestTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerfTestProvider>();
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useStandardDesktopLayout = constraints.maxWidth >= 780;
        if (useStandardDesktopLayout) {
          return _buildStandardDesktopLayout(
            context: context,
            provider: provider,
            theme: theme,
          );
        }

        final compact = constraints.maxWidth < 780;
        final chartColumns = constraints.maxWidth < 1050 ? 1 : 2;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题与控制栏
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    LocalizationKeys.networkPerformanceTest.tr(context),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: provider.testMode,
                    items: [
                      DropdownMenuItem(
                        value: 'Client',
                        child: Text(LocalizationKeys.modeClient.tr(context)),
                      ),
                      DropdownMenuItem(
                        value: 'Server',
                        child: Text(LocalizationKeys.modeServer.tr(context)),
                      ),
                    ].toList(),
                    onChanged: (v) {
                      if (v != null) provider.testMode = v;
                    },
                    underline: const SizedBox(),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    onPressed: provider.isPerfRunning
                        ? provider.stopPerfTest
                        : provider.runPerfTest,
                    icon: provider.isPerfRunning
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    label: provider.isPerfRunning
                        ? LocalizationKeys.stopTest.tr(context)
                        : (provider.testMode == 'Server'
                              ? LocalizationKeys.startMonitor.tr(context)
                              : LocalizationKeys.startSend.tr(context)),
                    color: provider.isPerfRunning
                        ? Colors.redAccent.withValues(alpha: 0.9)
                        : Colors.green.withValues(alpha: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildControlBar(context, provider),
              const SizedBox(height: 24),

              // 数据监控区域
              Wrap(
                runSpacing: 16,
                spacing: 16,
                children: compact
                    ? [
                        SizedBox(
                          width: constraints.maxWidth,
                          child: _buildLogArea(context, provider),
                        ),
                        SizedBox(
                          width: constraints.maxWidth,
                          child: _buildStatsHierarchy(context, provider),
                        ),
                      ]
                    : [
                        SizedBox(
                          width: (constraints.maxWidth - 16) * 2 / 3,
                          child: _buildLogArea(context, provider),
                        ),
                        SizedBox(
                          width: (constraints.maxWidth - 16) / 3,
                          child: _buildStatsHierarchy(context, provider),
                        ),
                      ],
              ),
              const SizedBox(height: 24),

              // 图表网格
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: chartColumns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.8,
                children: [
                  _buildChartCard(
                    context,
                    LocalizationKeys.socketSend.tr(context),
                    provider.socketSendHistory,
                    Colors.blue,
                    ' Pkt/s',
                  ),
                  _buildChartCard(
                    context,
                    LocalizationKeys.socketReceive.tr(context),
                    provider.socketReceiveHistory,
                    Colors.green,
                    ' Pkt/s',
                  ),
                  _buildChartCard(
                    context,
                    LocalizationKeys.sendSpeed.tr(context),
                    provider.sendBytesHistory,
                    Colors.orange,
                    ' MB/s',
                  ),
                  _buildChartCard(
                    context,
                    LocalizationKeys.receiveSpeed.tr(context),
                    provider.receiveBytesHistory,
                    Colors.cyan,
                    ' MB/s',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStandardDesktopLayout({
    required BuildContext context,
    required PerfTestProvider provider,
    required ThemeData theme,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  LocalizationKeys.networkPerformanceTest.tr(context),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: provider.testMode,
                items: [
                  DropdownMenuItem(
                    value: 'Client',
                    child: Text(LocalizationKeys.modeClient.tr(context)),
                  ),
                  DropdownMenuItem(
                    value: 'Server',
                    child: Text(LocalizationKeys.modeServer.tr(context)),
                  ),
                ].toList(),
                onChanged: (v) {
                  if (v != null) provider.testMode = v;
                },
                underline: const SizedBox(),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                onPressed: provider.isPerfRunning
                    ? provider.stopPerfTest
                    : provider.runPerfTest,
                icon: provider.isPerfRunning
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                label: provider.isPerfRunning
                    ? LocalizationKeys.stopTest.tr(context)
                    : (provider.testMode == 'Server'
                          ? LocalizationKeys.startMonitor.tr(context)
                          : LocalizationKeys.startSend.tr(context)),
                color: provider.isPerfRunning
                    ? Colors.redAccent.withValues(alpha: 0.9)
                    : Colors.green.withValues(alpha: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildControlBar(context, provider),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildLogArea(context, provider)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildStatsHierarchy(context, provider)),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildChartCard(
                context,
                LocalizationKeys.socketSend.tr(context),
                provider.socketSendHistory,
                Colors.blue,
                ' Pkt/s',
              ),
              _buildChartCard(
                context,
                LocalizationKeys.socketReceive.tr(context),
                provider.socketReceiveHistory,
                Colors.green,
                ' Pkt/s',
              ),
              _buildChartCard(
                context,
                LocalizationKeys.sendSpeed.tr(context),
                provider.sendBytesHistory,
                Colors.orange,
                ' MB/s',
              ),
              _buildChartCard(
                context,
                LocalizationKeys.receiveSpeed.tr(context),
                provider.receiveBytesHistory,
                Colors.cyan,
                ' MB/s',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, PerfTestProvider provider) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownButton<String>(
            value: provider.protocol,
            items: [
              'TCP',
              'UDP',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {
              if (v != null) provider.protocol = v;
            },
            underline: const SizedBox(),
          ),
          CompactInput(
            controller: provider.perfHostController,
            label: provider.testMode == 'Client' ? 'Target' : 'Listen',
            width: 130,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                NetworkInputRules.hostAllowedCharsRegExp,
              ),
            ],
          ),
          CompactInput(
            controller: provider.perfPortController,
            label: 'Port',
            width: 40,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          if (provider.testMode == 'Client') ...[
            NumericStepper(
              controller: provider.perfConnectionsController,
              label: LocalizationKeys.connections.tr(context),
              width: 10,
            ),
            NumericStepper(
              controller: provider.perfIntervalController,
              label: LocalizationKeys.intervalMs.tr(context),
              width: 10,
            ),
            NumericStepper(
              controller: provider.perfDataSizeController,
              label: LocalizationKeys.dataSize.tr(context),
              width: 10,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogArea(BuildContext context, PerfTestProvider provider) {
    final theme = Theme.of(context);
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: NetworkTextArea(
        controller: provider.perfOutputController,
        hintText: 'Socket data stream...',
        readOnly: true,
      ),
    );
  }

  Widget _buildStatsHierarchy(BuildContext context, PerfTestProvider provider) {
    final theme = Theme.of(context);
    return Container(
      height: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ListView(
        children: [
          _buildStatHeader(context, Icons.download_rounded, 'receive data'),
          _buildStatRow(
            'Received',
            provider.totalSocketReceive.toInt().toString(),
          ),
          _buildStatRow(
            'ReceivedBytes',
            formatBytes(provider.totalReceiveBytes),
          ),
          _buildStatRow(
            'Receiving...',
            '${provider.socketReceivePerSec.toInt()} pkt/s',
          ),
          const Divider(height: 24),
          _buildStatHeader(context, Icons.upload_rounded, 'send data'),
          _buildStatRow('Sent', provider.totalSocketSend.toInt().toString()),
          _buildStatRow('SentBytes', formatBytes(provider.totalSendBytes)),
          _buildStatRow(
            'Sending...',
            '${provider.socketSendPerSec.toInt()} pkt/s',
          ),
        ],
      ),
    );
  }

  Widget _buildStatHeader(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    String title,
    List<double> history,
    Color color,
    String unit,
  ) {
    final theme = Theme.of(context);
    final lastVal = history.isNotEmpty ? history.last : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor.withValues(alpha: 0.6),
            theme.cardColor.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${lastVal.toStringAsFixed(1)}$unit',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: history
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

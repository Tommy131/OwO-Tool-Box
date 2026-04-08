import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/services/localization_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/navigation/module_side_nav.dart';

import '../localization/localization_keys.dart';
import '../providers/network_tools_provider.dart';

class NetworkToolsPage extends StatefulWidget {
  const NetworkToolsPage({super.key});

  @override
  State<NetworkToolsPage> createState() => _NetworkToolsPageState();
}

class _NetworkToolsPageState extends State<NetworkToolsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isNavExpanded = false;
  static const double _compactNavWidth = 68;
  static const double _expandedNavWidth = 200;
  static const double _navHeaderHeight = 60;
  static const double _mainContentPadding = 16;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useCompactNav = screenWidth < 1100;

    final content = TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildPingTool(),
        _buildPerformanceTool(),
        _buildSiteTool(),
        _buildPortScanTool(),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveSidebarShell(
        isCompact: useCompactNav,
        isExpanded: _isNavExpanded,
        compactWidth: _compactNavWidth,
        expandedWidth: _expandedNavWidth,
        content: content,
        onCollapse: () => setState(() => _isNavExpanded = false),
        buildPanel:
            ({
              required bool useCompactNav,
              required bool showLabel,
              required bool isFloating,
            }) => _buildNavPanel(
              useCompactNav: useCompactNav,
              showLabel: showLabel,
              isFloating: isFloating,
            ),
      ),
    );
  }

  Widget _buildNavPanel({
    required bool useCompactNav,
    required bool showLabel,
    bool isFloating = false,
  }) {
    final primaryColor = context
        .watch<ThemeProvider>()
        .currentTheme
        .primaryColor;
    final width = showLabel ? _expandedNavWidth : _compactNavWidth;
    return SidebarPanelContainer(
      width: width,
      isFloating: isFloating,
      onBlankTap: isFloating
          ? () => setState(() => _isNavExpanded = false)
          : null,
      topSlot: !showLabel
          ? _buildNavToggle(showLabel: showLabel, useCompactNav: useCompactNav)
          : (isFloating
                ? const SizedBox(height: _navHeaderHeight)
                : const SizedBox(height: 8)),
      children: [
        SidebarNavItemTile(
          icon: Icons.speed_rounded,
          label: LocalizationKeys.networkPing.tr(context),
          isSelected: _tabController.index == 0,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(0, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.bolt_rounded,
          label: LocalizationKeys.networkPerformanceTest.tr(context),
          isSelected: _tabController.index == 1,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(1, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.security_rounded,
          label: LocalizationKeys.networkSiteTest.tr(context),
          isSelected: _tabController.index == 2,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(2, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.lan_rounded,
          label: LocalizationKeys.networkPortScan.tr(context),
          isSelected: _tabController.index == 3,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(3, useCompactNav, showLabel),
        ),
      ],
    );
  }

  void _onNavSelect(int index, bool useCompactNav, bool showLabel) {
    setState(() => _tabController.index = index);
    if (useCompactNav && showLabel) {
      setState(() => _isNavExpanded = false);
    }
  }

  Widget _buildNavToggle({
    required bool showLabel,
    required bool useCompactNav,
  }) {
    return SidebarToggleButton(
      showLabel: showLabel,
      enabled: useCompactNav,
      isExpanded: _isNavExpanded,
      onPressed: () => setState(() => _isNavExpanded = !_isNavExpanded),
    );
  }

  // --- 工具页面构建 ---

  Widget _buildPingTool() {
    final provider = context.watch<NetworkToolsProvider>();
    return _buildToolLayout(
      title: LocalizationKeys.networkPing.tr(context),
      onClear: provider.clearPing,
      topContent: Column(
        children: [
          TextField(
            controller: provider.pingHostController,
            decoration: InputDecoration(
              labelText: LocalizationKeys.targetHost.tr(context),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          _buildNumericStepper(
            provider.pingCountController,
            LocalizationKeys.pingCount.tr(context),
            80,
          ),
        ],
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.isPingRunning
              ? provider.stopPing
              : provider.runPing,
          icon: Icon(
            provider.isPingRunning
                ? Icons.stop_rounded
                : Icons.play_arrow_rounded,
          ),
          label: Text(
            provider.isPingRunning
                ? LocalizationKeys.stopTest.tr(context)
                : LocalizationKeys.startTest.tr(context),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: provider.isPingRunning ? Colors.redAccent : null,
            foregroundColor: provider.isPingRunning ? Colors.white : null,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _copyToClipboard(provider.pingOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.pingOutputController,
        hintText: LocalizationKeys.outputHint.tr(context),
        readOnly: true,
      ),
    );
  }

  Widget _buildPerformanceTool() {
    final provider = context.watch<NetworkToolsProvider>();
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final chartColumns = constraints.maxWidth < 1050 ? 1 : 2;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(_mainContentPadding),
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
                      if (v != null) setState(() => provider.testMode = v);
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
              _buildControlBar(provider),
              const SizedBox(height: 24),

              // 数据监控区域 (发送/接收 详情)
              Wrap(
                runSpacing: 16,
                spacing: 16,
                children: compact
                    ? [
                        SizedBox(
                          width: constraints.maxWidth,
                          child: _buildLogArea(provider),
                        ),
                        SizedBox(
                          width: constraints.maxWidth,
                          child: _buildStatsHierarchy(provider),
                        ),
                      ]
                    : [
                        SizedBox(
                          width: (constraints.maxWidth - 16) * 2 / 3,
                          child: _buildLogArea(provider),
                        ),
                        SizedBox(
                          width: (constraints.maxWidth - 16) / 3,
                          child: _buildStatsHierarchy(provider),
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
                    LocalizationKeys.socketSend.tr(context),
                    provider.socketSendHistory,
                    Colors.blue,
                    ' Pkt/s',
                  ),
                  _buildChartCard(
                    LocalizationKeys.socketReceive.tr(context),
                    provider.socketReceiveHistory,
                    Colors.green,
                    ' Pkt/s',
                  ),
                  _buildChartCard(
                    LocalizationKeys.sendSpeed.tr(context),
                    provider.sendBytesHistory,
                    Colors.orange,
                    ' MB/s',
                  ),
                  _buildChartCard(
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

  Widget _buildControlBar(NetworkToolsProvider provider) {
    final theme = Theme.of(context);
    return Container(
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
              if (v != null) setState(() => provider.protocol = v);
            },
            underline: const SizedBox(),
          ),
          _buildCompactInput(
            provider.perfHostController,
            provider.testMode == 'Client' ? 'Target' : 'Listen',
            110,
          ),
          _buildCompactInput(provider.perfPortController, 'Port', 40),
          if (provider.testMode == 'Client') ...[
            _buildNumericStepper(
              provider.perfConnectionsController,
              LocalizationKeys.connections.tr(context),
              10,
            ),
            _buildNumericStepper(
              provider.perfIntervalController,
              LocalizationKeys.intervalMs.tr(context),
              10,
            ),
            _buildNumericStepper(
              provider.perfDataSizeController,
              LocalizationKeys.dataSize.tr(context),
              10,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNumericStepper(
    TextEditingController controller,
    String label,
    double width,
  ) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Container(
          width: width + 40,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      int val = int.tryParse(controller.text) ?? 0;
                      controller.text = (val + 1).toString();
                    },
                    child: const Icon(Icons.arrow_drop_up, size: 18),
                  ),
                  InkWell(
                    onTap: () {
                      int val = int.tryParse(controller.text) ?? 0;
                      if (val > 1) {
                        controller.text = (val - 1).toString();
                      }
                    },
                    child: const Icon(Icons.arrow_drop_down, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactInput(
    TextEditingController controller,
    String label,
    double width,
  ) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: width,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
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

  Widget _buildLogArea(NetworkToolsProvider provider) {
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
      child: _buildTextArea(
        controller: provider.perfOutputController,
        hintText: 'Socket data stream...',
        readOnly: true,
      ),
    );
  }

  Widget _buildStatsHierarchy(NetworkToolsProvider provider) {
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
          _buildStatHeader(Icons.download_rounded, 'receive data'),
          _buildStatRow(
            'Received',
            provider.totalSocketReceive.toInt().toString(),
          ),
          _buildStatRow(
            'ReceivedBytes',
            _formatBytes(provider.totalReceiveBytes),
          ),
          _buildStatRow(
            'Receiving...',
            '${provider.socketReceivePerSec.toInt()} pkt/s',
          ),
          const Divider(height: 24),
          _buildStatHeader(Icons.upload_rounded, 'send data'),
          _buildStatRow('Sent', provider.totalSocketSend.toInt().toString()),
          _buildStatRow('SentBytes', _formatBytes(provider.totalSendBytes)),
          _buildStatRow(
            'Sending...',
            '${provider.socketSendPerSec.toInt()} pkt/s',
          ),
        ],
      ),
    );
  }

  Widget _buildStatHeader(IconData icon, String title) {
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

  // --- 通用组件 ---

  Widget _buildToolLayout({
    required String title,
    Widget? topContent,
    required List<Widget> actions,
    required Widget bottomContent,
    VoidCallback? onClear,
  }) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final actionWidgets = _normalizeActions(actions);
        return Padding(
          padding: const EdgeInsets.all(_mainContentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                runSpacing: 8,
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (onClear != null)
                    TextButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.clear_all_rounded, size: 20),
                      label: Text(LocalizationKeys.clear.tr(context)),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (topContent != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: topContent,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: actionWidgets,
                ),
              ),
              Expanded(child: bottomContent),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _normalizeActions(List<Widget> actions) {
    final normalized = <Widget>[];
    for (final action in actions) {
      if (action is Spacer) {
        normalized.add(const SizedBox(width: 12));
        continue;
      }
      normalized.add(action);
    }
    return normalized;
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        readOnly: readOnly,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Colors.greenAccent,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSiteTool() {
    final provider = context.watch<NetworkToolsProvider>();
    return _buildToolLayout(
      title: LocalizationKeys.networkSiteTest.tr(context),
      onClear: provider.clearSite,
      topContent: TextField(
        controller: provider.siteUrlController,
        decoration: const InputDecoration(
          labelText: 'Site URL',
          hintText: 'https://example.com',
          isDense: true,
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.isSiteTesting ? null : provider.runSiteTest,
          icon: const Icon(Icons.health_and_safety_rounded),
          label: Text(LocalizationKeys.startTest.tr(context)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _copyToClipboard(provider.siteOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.siteOutputController,
        hintText: LocalizationKeys.outputHint.tr(context),
        readOnly: true,
      ),
    );
  }

  Widget _buildPortScanTool() {
    final provider = context.watch<NetworkToolsProvider>();
    return _buildToolLayout(
      title: LocalizationKeys.networkPortScan.tr(context),
      onClear: provider.clearPort,
      topContent: Column(
        children: [
          TextField(
            controller: provider.portHostController,
            decoration: InputDecoration(
              labelText: LocalizationKeys.targetHost.tr(context),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: provider.portRangeController,
            decoration: InputDecoration(
              labelText: LocalizationKeys.portRange.tr(context),
              hintText: '80, 443',
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.isPortScanning
              ? provider.stopPortScan
              : provider.runPortScan,
          icon: Icon(
            provider.isPortScanning ? Icons.stop_rounded : Icons.search_rounded,
          ),
          label: Text(
            provider.isPortScanning
                ? LocalizationKeys.stopTest.tr(context)
                : LocalizationKeys.scanPorts.tr(context),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _copyToClipboard(provider.portOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.portOutputController,
        hintText: LocalizationKeys.outputHint.tr(context),
        readOnly: true,
      ),
    );
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toInt()} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationKeys.copySuccess.tr(context)),
        behavior: SnackBarBehavior.floating,
        width: 230,
      ),
    );
  }
}

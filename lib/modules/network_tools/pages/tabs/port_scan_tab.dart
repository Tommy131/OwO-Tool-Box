import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../network_input_rules.dart';
import '../../providers/port_scan_provider.dart';
import '../shared/network_tool_widgets.dart';

class PortScanTab extends StatelessWidget {
  const PortScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortScanProvider>();
    return NetworkToolLayout(
      title: LocalizationKeys.networkPortScan.tr(context),
      onClear: provider.clearPort,
      topContent: Column(
        children: [
          TextField(
            groupId: provider.portHostController,
            controller: provider.portHostController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                NetworkInputRules.hostAllowedCharsRegExp,
              ),
            ],
            decoration: InputDecoration(
              labelText: LocalizationKeys.targetHost.tr(context),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            groupId: provider.portRangeController,
            controller: provider.portRangeController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                NetworkInputRules.portRangeAllowedCharsRegExp,
              ),
            ],
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
        const SizedBox(width: 12),
        IconButton(
          onPressed: () =>
              _copyToClipboard(context, provider.portOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: NetworkTextArea(
        controller: provider.portOutputController,
        hintText: LocalizationKeys.outputHint.tr(context),
        readOnly: true,
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
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

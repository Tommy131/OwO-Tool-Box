import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../network_input_rules.dart';
import '../../providers/ping_provider.dart';
import '../shared/network_tool_widgets.dart';

class PingTab extends StatelessWidget {
  const PingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PingProvider>();
    return NetworkToolLayout(
      title: LocalizationKeys.networkPing.tr(context),
      onClear: provider.clearPing,
      topContent: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return Column(
              children: [
                TextField(
                  groupId: provider.pingHostController,
                  controller: provider.pingHostController,
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
                NumericStepper(
                  controller: provider.pingCountController,
                  label: LocalizationKeys.pingCount.tr(context),
                  width: 80,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  groupId: provider.pingHostController,
                  controller: provider.pingHostController,
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
              ),
              const SizedBox(width: 24),
              NumericStepper(
                controller: provider.pingCountController,
                label: LocalizationKeys.pingCount.tr(context),
                width: 80,
              ),
            ],
          );
        },
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
        const SizedBox(width: 12),
        IconButton(
          onPressed: () =>
              _copyToClipboard(context, provider.pingOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: NetworkTextArea(
        controller: provider.pingOutputController,
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

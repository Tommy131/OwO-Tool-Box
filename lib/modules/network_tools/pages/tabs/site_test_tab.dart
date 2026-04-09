import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';
import '../../network_input_rules.dart';
import '../../providers/site_test_provider.dart';
import '../shared/network_tool_widgets.dart';

class SiteTestTab extends StatelessWidget {
  const SiteTestTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SiteTestProvider>();
    return NetworkToolLayout(
      title: LocalizationKeys.networkSiteTest.tr(context),
      onClear: provider.clearSite,
      topContent: TextField(
        groupId: provider.siteUrlController,
        controller: provider.siteUrlController,
        keyboardType: TextInputType.url,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            NetworkInputRules.siteUrlAllowedCharsRegExp,
          ),
        ],
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
        const SizedBox(width: 12),
        IconButton(
          onPressed: () =>
              _copyToClipboard(context, provider.siteOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: NetworkTextArea(
        controller: provider.siteOutputController,
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

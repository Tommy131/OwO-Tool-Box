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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../core/services/localization_service.dart';
import '../../../core/widgets/navigation/module_side_nav.dart';

import '../localization/localization_keys.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/dev_tools_provider.dart';

class DevToolsPage extends StatefulWidget {
  const DevToolsPage({super.key});

  @override
  State<DevToolsPage> createState() => _DevToolsPageState();
}

class _DevToolsPageState extends State<DevToolsPage>
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
    _tabController = TabController(length: 6, vsync: this);
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
        _buildBase64Tool(),
        _buildUrlTool(),
        _buildJsonTool(),
        _buildUuidTool(),
        _buildHashTool(),
        _buildPasswordTool(),
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
          icon: Icons.code_rounded,
          label: LocalizationKeys.devToolsBase64.tr(context),
          isSelected: _tabController.index == 0,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(0, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.link_rounded,
          label: LocalizationKeys.devToolsUrl.tr(context),
          isSelected: _tabController.index == 1,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(1, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.data_object_rounded,
          label: LocalizationKeys.devToolsJson.tr(context),
          isSelected: _tabController.index == 2,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(2, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.fingerprint_rounded,
          label: LocalizationKeys.devToolsUuid.tr(context),
          isSelected: _tabController.index == 3,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(3, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.security_rounded,
          label: LocalizationKeys.hashTool.tr(context),
          isSelected: _tabController.index == 4,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(4, useCompactNav, showLabel),
        ),
        SidebarNavItemTile(
          icon: Icons.password_rounded,
          label: LocalizationKeys.devToolsPassword.tr(context),
          isSelected: _tabController.index == 5,
          primaryColor: primaryColor,
          showLabel: showLabel,
          onTap: () => _onNavSelect(5, useCompactNav, showLabel),
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

  // 通用输入输出布局
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
              if (topContent != null) Expanded(child: topContent),
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
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // --- 各个工具的具体实现 ---

  Widget _buildBase64Tool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: LocalizationKeys.devToolsBase64.tr(context),
      onClear: provider.clearBase64,
      topContent: _buildTextArea(
        controller: provider.base64InputController,
        hintText: LocalizationKeys.inputHint.tr(context),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.base64Encode,
          icon: const Icon(Icons.lock_outline),
          label: Text(LocalizationKeys.encode.tr(context)),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: provider.base64Decode,
          icon: const Icon(Icons.lock_open_outlined),
          label: Text(LocalizationKeys.decode.tr(context)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () =>
              _copyToClipboard(provider.base64OutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.base64OutputController,
        hintText: LocalizationKeys.outputHint.tr(context),
        readOnly: true,
      ),
    );
  }

  Widget _buildUrlTool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: LocalizationKeys.devToolsUrl.tr(context),
      onClear: provider.clearUrl,
      topContent: _buildTextArea(
        controller: provider.urlInputController,
        hintText: LocalizationKeys.inputHint.tr(context),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.urlEncode,
          icon: const Icon(Icons.link_rounded),
          label: Text(LocalizationKeys.encode.tr(context)),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: provider.urlDecode,
          icon: const Icon(Icons.link_off_rounded),
          label: Text(LocalizationKeys.decode.tr(context)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _copyToClipboard(provider.urlOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.urlOutputController,
        hintText: LocalizationKeys.outputHint.tr(context),
        readOnly: true,
      ),
    );
  }

  Widget _buildJsonTool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: LocalizationKeys.devToolsJson.tr(context),
      onClear: provider.clearJson,
      topContent: _buildTextArea(
        controller: provider.jsonInputController,
        hintText: LocalizationKeys.inputHint.tr(context),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.formatJson,
          icon: const Icon(Icons.format_align_left_rounded),
          label: Text(LocalizationKeys.format.tr(context)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _copyToClipboard(provider.jsonOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.jsonOutputController,
        hintText: LocalizationKeys.outputHint.tr(context),
        readOnly: true,
      ),
    );
  }

  Widget _buildUuidTool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: LocalizationKeys.devToolsUuid.tr(context),
      onClear: provider.clearUuid,
      topContent: null, // UUID 不需要顶部输入
      actions: [
        ElevatedButton(
          onPressed: provider.generateUuidV4,
          child: const Text('Generate UUID v4'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: provider.generateUuidV1,
          child: const Text('Generate UUID v1'),
        ),
      ],
      bottomContent: ListView.builder(
        itemCount: provider.uuidList.length,
        itemBuilder: (context, index) {
          final uuid = provider.uuidList[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(uuid, style: const TextStyle(fontFamily: 'monospace')),
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: () => _copyToClipboard(uuid),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHashTool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: LocalizationKeys.hashTool.tr(context),
      onClear: provider.clearHash,
      topContent: _buildTextArea(
        controller: provider.hashInputController,
        hintText: LocalizationKeys.inputHint.tr(context),
      ),
      actions: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'MD5', label: Text('MD5')),
            ButtonSegment(value: 'SHA1', label: Text('SHA1')),
            ButtonSegment(value: 'SHA256', label: Text('SHA256')),
          ],
          selected: {provider.selectedHashAlgo},
          onSelectionChanged: (value) => provider.setHashAlgo(value.first),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: provider.calculateHash,
          child: Text(LocalizationKeys.generate.tr(context)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _copyToClipboard(provider.hashOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.hashOutputController,
        hintText: LocalizationKeys.outputHint.tr(context),
        readOnly: true,
      ),
    );
  }

  Widget _buildPasswordTool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: LocalizationKeys.devToolsPassword.tr(context),
      onClear: provider.clearPassword,
      topContent: Column(
        children: [
          Row(
            children: [
              Text(
                '${LocalizationKeys.passwordLength.tr(context)}: ${provider.passwordLength.toInt()}',
              ),
              Expanded(
                child: Slider(
                  value: provider.passwordLength,
                  min: 8,
                  max: 64,
                  onChanged: (v) => provider.setPasswordLength(v),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            children: [
              FilterChip(
                label: const Text('Upper Case'),
                selected: provider.passIncludeUpper,
                onSelected: (v) => provider.setPassIncludeUpper(v),
              ),
              FilterChip(
                label: const Text('Lower Case'),
                selected: provider.passIncludeLower,
                onSelected: (v) => provider.setPassIncludeLower(v),
              ),
              FilterChip(
                label: const Text('Numbers'),
                selected: provider.passIncludeNumbers,
                onSelected: (v) => provider.setPassIncludeNumbers(v),
              ),
              FilterChip(
                label: const Text('Symbols'),
                selected: provider.passIncludeSymbols,
                onSelected: (v) => provider.setPassIncludeSymbols(v),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.generatePassword,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(LocalizationKeys.generate.tr(context)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () =>
              _copyToClipboard(provider.passwordOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: LocalizationKeys.copySuccess.tr(context),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.passwordOutputController,
        hintText: LocalizationKeys.outputHint.tr(context),
        readOnly: true,
      ),
    );
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationKeys.copySuccess.tr(context)),
        behavior: SnackBarBehavior.floating,
        width: 200,
      ),
    );
  }
}

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

import '../../../core/i18n/app_localization.dart';
import '../../../core/i18n/localization_keys.dart';
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

  String _tr(String key) => AppLocalization.of(context).translate(key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.currentTheme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // 左侧导航
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.5),
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _tr(L18nKeys.devTools),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavItem(
                        0,
                        Icons.code_rounded,
                        _tr(L18nKeys.devToolsBase64),
                      ),
                      _buildNavItem(
                        1,
                        Icons.link_rounded,
                        _tr(L18nKeys.devToolsUrl),
                      ),
                      _buildNavItem(
                        2,
                        Icons.data_object_rounded,
                        _tr(L18nKeys.devToolsJson),
                      ),
                      _buildNavItem(
                        3,
                        Icons.fingerprint_rounded,
                        _tr(L18nKeys.devToolsUuid),
                      ),
                      _buildNavItem(
                        4,
                        Icons.security_rounded,
                        _tr(L18nKeys.hashTool),
                      ),
                      _buildNavItem(
                        5,
                        Icons.password_rounded,
                        _tr(L18nKeys.devToolsPassword),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 右侧内容
          Expanded(
            child: TabBarView(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _tabController.index == index;
    final primaryColor = context
        .watch<ThemeProvider>()
        .currentTheme
        .primaryColor;

    return InkWell(
      onTap: () => setState(() => _tabController.index = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? primaryColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? primaryColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onClear != null)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear_all_rounded, size: 20),
                  label: Text(_tr(L18nKeys.clear)),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (topContent != null) Expanded(child: topContent),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(children: actions),
          ),
          Expanded(child: bottomContent),
        ],
      ),
    );
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
      title: _tr(L18nKeys.devToolsBase64),
      onClear: provider.clearBase64,
      topContent: _buildTextArea(
        controller: provider.base64InputController,
        hintText: _tr(L18nKeys.inputHint),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.base64Encode,
          icon: const Icon(Icons.lock_outline),
          label: Text(_tr(L18nKeys.encode)),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: provider.base64Decode,
          icon: const Icon(Icons.lock_open_outlined),
          label: Text(_tr(L18nKeys.decode)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () =>
              _copyToClipboard(provider.base64OutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: _tr(L18nKeys.copySuccess),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.base64OutputController,
        hintText: _tr(L18nKeys.outputHint),
        readOnly: true,
      ),
    );
  }

  Widget _buildUrlTool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: _tr(L18nKeys.devToolsUrl),
      onClear: provider.clearUrl,
      topContent: _buildTextArea(
        controller: provider.urlInputController,
        hintText: _tr(L18nKeys.inputHint),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.urlEncode,
          icon: const Icon(Icons.link_rounded),
          label: Text(_tr(L18nKeys.encode)),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: provider.urlDecode,
          icon: const Icon(Icons.link_off_rounded),
          label: Text(_tr(L18nKeys.decode)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _copyToClipboard(provider.urlOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: _tr(L18nKeys.copySuccess),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.urlOutputController,
        hintText: _tr(L18nKeys.outputHint),
        readOnly: true,
      ),
    );
  }

  Widget _buildJsonTool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: _tr(L18nKeys.devToolsJson),
      onClear: provider.clearJson,
      topContent: _buildTextArea(
        controller: provider.jsonInputController,
        hintText: _tr(L18nKeys.inputHint),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: provider.formatJson,
          icon: const Icon(Icons.format_align_left_rounded),
          label: Text(_tr(L18nKeys.format)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _copyToClipboard(provider.jsonOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: _tr(L18nKeys.copySuccess),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.jsonOutputController,
        hintText: _tr(L18nKeys.outputHint),
        readOnly: true,
      ),
    );
  }

  Widget _buildUuidTool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: _tr(L18nKeys.devToolsUuid),
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
      title: _tr(L18nKeys.hashTool),
      onClear: provider.clearHash,
      topContent: _buildTextArea(
        controller: provider.hashInputController,
        hintText: _tr(L18nKeys.inputHint),
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
          child: Text(_tr(L18nKeys.generate)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _copyToClipboard(provider.hashOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: _tr(L18nKeys.copySuccess),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.hashOutputController,
        hintText: _tr(L18nKeys.outputHint),
        readOnly: true,
      ),
    );
  }

  Widget _buildPasswordTool() {
    final provider = context.watch<DevToolsProvider>();
    return _buildToolLayout(
      title: _tr(L18nKeys.devToolsPassword),
      onClear: provider.clearPassword,
      topContent: Column(
        children: [
          Row(
            children: [
              Text(
                '${_tr(L18nKeys.passwordLength)}: ${provider.passwordLength.toInt()}',
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
          label: Text(_tr(L18nKeys.generate)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () =>
              _copyToClipboard(provider.passwordOutputController.text),
          icon: const Icon(Icons.copy_rounded),
          tooltip: _tr(L18nKeys.copySuccess),
        ),
      ],
      bottomContent: _buildTextArea(
        controller: provider.passwordOutputController,
        hintText: _tr(L18nKeys.outputHint),
        readOnly: true,
      ),
    );
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_tr(L18nKeys.copySuccess)),
        behavior: SnackBarBehavior.floating,
        width: 200,
      ),
    );
  }
}

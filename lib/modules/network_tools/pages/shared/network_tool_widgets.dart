import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/localization_service.dart';
import '../../localization/localization_keys.dart';

/// 通用工具页面布局
class NetworkToolLayout extends StatelessWidget {
  final String title;
  final Widget? topContent;
  final List<Widget> actions;
  final Widget bottomContent;
  final VoidCallback? onClear;

  const NetworkToolLayout({
    super.key,
    required this.title,
    this.topContent,
    required this.actions,
    required this.bottomContent,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionWidgets = _normalizeActions(actions);
    return Padding(
      padding: const EdgeInsets.all(16),
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
              child: topContent!,
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
}

/// 通用终端风格文本区域
class NetworkTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;

  const NetworkTextArea({
    super.key,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// 数值步进器
class NumericStepper extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double width;
  final List<TextInputFormatter>? inputFormatters;

  const NumericStepper({
    super.key,
    required this.controller,
    required this.label,
    required this.width,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
                  groupId: controller,
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters:
                      inputFormatters ??
                      <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
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
                      final next = (val + 1).toString();
                      controller.value = TextEditingValue(
                        text: next,
                        selection: TextSelection.collapsed(offset: next.length),
                      );
                    },
                    child: const Icon(Icons.arrow_drop_up, size: 18),
                  ),
                  InkWell(
                    onTap: () {
                      int val = int.tryParse(controller.text) ?? 0;
                      if (val > 1) {
                        final next = (val - 1).toString();
                        controller.value = TextEditingValue(
                          text: next,
                          selection: TextSelection.collapsed(
                            offset: next.length,
                          ),
                        );
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
}

/// 紧凑输入框
class CompactInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double width;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CompactInput({
    super.key,
    required this.controller,
    required this.label,
    required this.width,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: width,
          child: TextField(
            groupId: controller,
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
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
}

/// 格式化字节数
String formatBytes(double bytes) {
  if (bytes < 1024) return '${bytes.toInt()} B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

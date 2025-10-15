// ============================================================================
// 自定义单选框组 - CustomRadioGroup
// ============================================================================

import 'package:flutter/material.dart';

/// 自定义单选框组
class CustomRadioGroup<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T? value;
  final void Function(T?) onChanged;
  final String Function(T)? labelBuilder;

  const CustomRadioGroup({
    super.key,
    required this.label,
    required this.options,
    this.value,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) {
          return RadioListTile<T>(
            title: Text(labelBuilder?.call(option) ?? option.toString()),
            value: option,
            groupValue: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          );
        }),
      ],
    );
  }
}

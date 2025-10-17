// ============================================================================
// 自定义复选框组 - CustomCheckboxGroup
// ============================================================================

import 'package:flutter/material.dart';

/// 自定义复选框组
class CustomCheckboxGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedValues;
  final void Function(String, bool) onChanged;

  const CustomCheckboxGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
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
          final isSelected = selectedValues.contains(option);
          return CheckboxListTile(
            title: Text(option),
            value: isSelected,
            onChanged: (value) => onChanged(option, value ?? false),
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

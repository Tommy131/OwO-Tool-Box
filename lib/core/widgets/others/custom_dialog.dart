// ============================================================================
// 自定义弹窗组件 - Custom Dialog
// 文件路径: lib/widgets/dialogs/custom_dialog.dart
// 版本: 1.0.0
// 说明: 提供多种类型的弹窗组件（警告、确认、成功、表单）
// ============================================================================

import 'package:flutter/material.dart';
import '../buttons/custom_button.dart';
import 'custom_text_field.dart';
import '../selections/custom_dropdown.dart';

/// 弹窗类型枚举
enum DialogType {
  warning, // 警告弹窗
  confirm, // 确认弹窗
  success, // 成功弹窗
  info, // 信息弹窗
  error, // 错误弹窗
}

/// 自定义弹窗组件
class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogType type;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? customContent;
  final bool showCancelButton;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = DialogType.info,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.customContent,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            _buildIcon(context),
            const SizedBox(height: 16),

            // 标题
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 消息内容
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),

            // 自定义内容
            if (customContent != null) ...[
              const SizedBox(height: 16),
              customContent!,
            ],

            const SizedBox(height: 24),

            // 按钮组
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case DialogType.warning:
        iconData = Icons.warning_rounded;
        iconColor = Colors.orange;
        break;
      case DialogType.confirm:
        iconData = Icons.help_outline_rounded;
        iconColor = Colors.blue;
        break;
      case DialogType.success:
        iconData = Icons.check_circle_outline_rounded;
        iconColor = Colors.green;
        break;
      case DialogType.error:
        iconData = Icons.error_outline_rounded;
        iconColor = Colors.red;
        break;
      case DialogType.info:
        iconData = Icons.info_outline_rounded;
        iconColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 48,
        color: iconColor,
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (!showCancelButton) {
      return CustomButton(
        text: confirmText ?? '确定',
        onPressed: () {
          onConfirm?.call();
          Navigator.of(context).pop(true);
        },
        style: _getButtonStyle(),
        width: double.infinity,
      );
    }

    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: cancelText ?? '取消',
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
            style: CustomButtonStyle.outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: confirmText ?? '确定',
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop(true);
            },
            style: _getButtonStyle(),
          ),
        ),
      ],
    );
  }

  CustomButtonStyle _getButtonStyle() {
    switch (type) {
      case DialogType.warning:
      case DialogType.error:
        return CustomButtonStyle.danger;
      case DialogType.success:
      case DialogType.confirm:
        return CustomButtonStyle.primary;
      case DialogType.info:
        return CustomButtonStyle.secondary;
    }
  }

  /// 显示警告弹窗
  static Future<bool?> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        type: DialogType.warning,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
  }

  /// 显示确认弹窗
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        type: DialogType.confirm,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
  }

  /// 显示成功弹窗
  static Future<bool?> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        type: DialogType.success,
        confirmText: confirmText,
        onConfirm: onConfirm,
        showCancelButton: false,
      ),
    );
  }

  /// 显示错误弹窗
  static Future<bool?> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        type: DialogType.error,
        confirmText: confirmText,
        onConfirm: onConfirm,
        showCancelButton: false,
      ),
    );
  }

  /// 显示信息弹窗
  static Future<bool?> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        type: DialogType.info,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
  }
}

/// 表单弹窗组件
class FormDialog extends StatefulWidget {
  final String title;
  final List<FormField> fields;
  final String confirmText;
  final String cancelText;
  final Function(Map<String, dynamic>) onSubmit;

  const FormDialog({
    super.key,
    required this.title,
    required this.fields,
    this.confirmText = '提交',
    this.cancelText = '取消',
    required this.onSubmit,
  });

  @override
  State<FormDialog> createState() => _FormDialogState();

  /// 显示表单弹窗
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required String title,
    required List<FormField> fields,
    String? confirmText,
    String? cancelText,
    required Function(Map<String, dynamic>) onSubmit,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FormDialog(
        title: title,
        fields: fields,
        confirmText: confirmText ?? '提交',
        cancelText: cancelText ?? '取消',
        onSubmit: onSubmit,
      ),
    );
  }
}

class _FormDialogState extends State<FormDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),

                // 表单字段
                ...widget.fields.map((field) => _buildFormField(field)),

                const SizedBox(height: 24),

                // 按钮组
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: widget.cancelText,
                        onPressed: () => Navigator.of(context).pop(),
                        style: CustomButtonStyle.outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: widget.confirmText,
                        onPressed: _handleSubmit,
                        style: CustomButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(FormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: field.type == FormFieldType.dropdown
          ? CustomDropdown<String>(
              label: field.label,
              hint: field.hint,
              prefixIcon: field.icon,
              items: field.options!
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _formData[field.key] = value;
                }
              },
              validator: field.isRequired
                  ? (value) => value == null ? '${field.label}不能为空' : null
                  : null,
            )
          : CustomTextField(
              label: field.label,
              hint: field.hint,
              prefixIcon: field.icon,
              obscureText: field.type == FormFieldType.password,
              keyboardType: _getKeyboardType(field.type),
              maxLines: field.type == FormFieldType.multiline ? 3 : 1,
              validator: field.isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return '${field.label}不能为空';
                      }
                      if (field.type == FormFieldType.email &&
                          !value.contains('@')) {
                        return '请输入有效的邮箱地址';
                      }
                      return null;
                    }
                  : null,
              onChanged: (value) {
                _formData[field.key] = value;
              },
            ),
    );
  }

  TextInputType _getKeyboardType(FormFieldType type) {
    switch (type) {
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.number:
        return TextInputType.number;
      case FormFieldType.phone:
        return TextInputType.phone;
      case FormFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_formData);
      Navigator.of(context).pop(_formData);
    }
  }
}

/// 表单字段类型
enum FormFieldType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
  dropdown,
}

/// 表单字段定义
class FormField {
  final String key;
  final String label;
  final String hint;
  final IconData? icon;
  final FormFieldType type;
  final bool isRequired;
  final List<String>? options; // 用于下拉框

  FormField({
    required this.key,
    required this.label,
    required this.hint,
    this.icon,
    this.type = FormFieldType.text,
    this.isRequired = true,
    this.options,
  });
}

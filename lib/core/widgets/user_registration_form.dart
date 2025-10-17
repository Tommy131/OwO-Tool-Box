// ============================================================================
// 完整表单示例组件 - UserRegistrationForm
// ============================================================================

import 'package:flutter/material.dart';

import 'bars/custom_snack_bar.dart';
import 'buttons/custom_button.dart';
import 'cards/form_card.dart';
import 'others/custom_switch.dart';
import 'others/custom_text_field.dart';
import 'selections/custom_check_box_group.dart';
import 'selections/custom_date_picker.dart';
import 'selections/custom_dropdown.dart';
import 'selections/custom_radio_group.dart';

/// 用户注册表单示例
///
/// 这是一个完整的表单提交示例，包含了所有表单组件
class UserRegistrationForm extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onSubmit;

  const UserRegistrationForm({
    super.key,
    this.onSubmit,
  });

  @override
  State<UserRegistrationForm> createState() => _UserRegistrationFormState();
}

class _UserRegistrationFormState extends State<UserRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();

  bool _obscurePassword = true;
  String? _selectedGender;
  DateTime? _birthDate;
  List<String> _selectedHobbies = [];
  String? _selectedCountry;
  bool _agreeToTerms = false;
  bool _receiveNewsletter = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackBar.show(
        context,
        message: '请填写所有必填字段',
        type: SnackBarType.error,
      );
      return;
    }

    if (!_agreeToTerms) {
      CustomSnackBar.show(
        context,
        message: '请同意用户协议',
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // 模拟提交延迟
    await Future.delayed(const Duration(seconds: 2));

    final formData = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'bio': _bioController.text,
      'gender': _selectedGender,
      'birthDate': _birthDate?.toIso8601String(),
      'hobbies': _selectedHobbies,
      'country': _selectedCountry,
      'agreeToTerms': _agreeToTerms,
      'receiveNewsletter': _receiveNewsletter,
    };

    setState(() {
      _isSubmitting = false;
    });

    if (widget.onSubmit != null) {
      widget.onSubmit!(formData);
    } else {
      CustomSnackBar.show(
        context,
        message: '注册成功！',
        type: SnackBarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 基本信息
          FormCard(
            title: '基本信息',
            children: [
              CustomTextField(
                label: '用户名',
                hint: '请输入用户名',
                controller: _usernameController,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  if (value.length < 3) {
                    return '用户名至少3个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: '邮箱',
                hint: '请输入邮箱地址',
                controller: _emailController,
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱';
                  }
                  if (!value.contains('@')) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: '密码',
                hint: '请输入密码',
                controller: _passwordController,
                prefixIcon: Icons.lock,
                suffixIcon:
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                onSuffixIconTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (value.length < 6) {
                    return '密码至少6个字符';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 个人信息
          FormCard(
            title: '个人信息',
            children: [
              CustomRadioGroup<String>(
                label: '性别',
                options: const ['男', '女', '其他'],
                value: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                label: '出生日期',
                selectedDate: _birthDate,
                onDateSelected: (date) {
                  setState(() {
                    _birthDate = date;
                  });
                },
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                label: '国家/地区',
                value: _selectedCountry,
                hint: '请选择国家',
                prefixIcon: Icons.public,
                items: const [
                  DropdownMenuItem(value: 'CN', child: Text('中国')),
                  DropdownMenuItem(value: 'US', child: Text('美国')),
                  DropdownMenuItem(value: 'UK', child: Text('英国')),
                  DropdownMenuItem(value: 'JP', child: Text('日本')),
                  DropdownMenuItem(value: 'KR', child: Text('韩国')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 兴趣爱好
          FormCard(
            title: '兴趣爱好',
            children: [
              CustomCheckboxGroup(
                label: '请选择您的兴趣（可多选）',
                options: const ['阅读', '运动', '音乐', '旅行', '摄影', '编程'],
                selectedValues: _selectedHobbies,
                onChanged: (option, isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedHobbies.add(option);
                    } else {
                      _selectedHobbies.remove(option);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: '个人简介',
                hint: '介绍一下自己吧...',
                controller: _bioController,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 偏好设置
          FormCard(
            title: '偏好设置',
            children: [
              CustomSwitch(
                label: '接收Newsletter',
                subtitle: '定期接收产品更新和优惠信息',
                value: _receiveNewsletter,
                icon: Icons.email_outlined,
                onChanged: (value) {
                  setState(() {
                    _receiveNewsletter = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 用户协议
          FormCard(
            children: [
              CheckboxListTile(
                title: const Text('我已阅读并同意用户协议和隐私政策'),
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 提交按钮
          CustomButton(
            text: '立即注册',
            onPressed: _handleSubmit,
            style: CustomButtonStyle.primary,
            icon: Icons.check_circle,
            isLoading: _isSubmitting,
            width: double.infinity,
            height: 56,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: '重置表单',
            onPressed: () {
              _formKey.currentState?.reset();
              setState(() {
                _usernameController.clear();
                _emailController.clear();
                _passwordController.clear();
                _bioController.clear();
                _selectedGender = null;
                _birthDate = null;
                _selectedHobbies = [];
                _selectedCountry = null;
                _agreeToTerms = false;
                _receiveNewsletter = false;
              });
              CustomSnackBar.show(
                context,
                message: '表单已重置',
                type: SnackBarType.info,
              );
            },
            style: CustomButtonStyle.outlined,
            icon: Icons.refresh,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

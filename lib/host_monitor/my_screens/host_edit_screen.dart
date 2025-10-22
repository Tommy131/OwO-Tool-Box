import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owo_system_tools/host_monitor/my_services/host_service.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_localization.dart';
import '../my_models/host_model.dart';
import '../../core/utils/logger.dart';
import '../my_providers/host_monitor_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_snack_bar.dart';
import '../widgets/host_monitor/custom_dialogs.dart';

/// 主机编辑页面 - 已适配系统主题
class HostEditScreen extends StatefulWidget {
  final HostModel? host;
  final VoidCallback? callback;

  const HostEditScreen({super.key, this.host, this.callback});

  @override
  State<HostEditScreen> createState() => _HostEditScreenState();
}

class _HostEditScreenState extends State<HostEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    'name': TextEditingController(),
    'address': TextEditingController(),
    'port': TextEditingController(),
    'token': TextEditingController(),
  };

  bool _isPasswordVisible = false;
  bool _isSaving = false;

  // 国际化翻译简化方法
  String _tr(String key) => AppLocalization.of(context).translate(key);

  @override
  void initState() {
    super.initState();

    if (widget.host != null) {
      final host = widget.host!;
      _controllers['name']!.text = host.name;
      _controllers['address']!.text = host.address;
      _controllers['port']!.text = host.port.toString();
      _controllers['token']!.text = host.token;
    } else {
      _controllers['address']!.text = '127.0.0.1';
      _controllers['port']!.text = '8888';
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ==================== 主机操作 ====================

  Future<void> _saveHost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<HostMonitorProvider>();
      final host = HostModel(
        id: widget.host?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _controllers['name']!.text.trim(),
        address: _controllers['address']!.text.trim(),
        port: int.parse(_controllers['port']!.text.trim()),
        token: _controllers['token']!.text,
        createdAt: DateTime.now(),
        lastConnected: widget.host?.lastConnected ?? DateTime.now(),
        status: widget.host?.status ?? HostStatus.unknown,
      );

      widget.host != null
          ? await provider.storageService!.updateHost(host)
          : await provider.storageService!.addHost(host);

      if (mounted) {
        if (widget.callback != null) widget.callback!();
        CustomSnackBar(
          context,
          message:
              widget.host != null ? _tr('host_updated') : _tr('host_added'),
          backgroundColor: Colors.green,
          icon: Icons.update_outlined,
        ).showModern();
        Navigator.pop(context, true);
      }
    } catch (e) {
      AppLogger.error('[HostEditScreen] 保存失败', e);
      if (mounted) {
        setState(() => _isSaving = false);
        CustomSnackBar(
          context,
          message: '${_tr('save_failed')}: $e',
          backgroundColor: Theme.of(context).colorScheme.error,
          icon: Icons.error_outline,
        ).showModern();
      }
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    CustomDialogs.showLoadingDialog(context, _tr('testing_connection'));

    try {
      final testHost = HostModel(
        id: 'test',
        name: _controllers['name']!.text.trim(),
        address: _controllers['address']!.text.trim(),
        port: int.parse(_controllers['port']!.text.trim()),
        token: _controllers['token']!.text,
        createdAt: DateTime.now(),
        lastConnected: DateTime.now(),
        status: HostStatus.unknown,
      );

      final status = await HostService.connect(testHost);

      if (mounted) {
        Navigator.pop(context);
        CustomDialogs.showResultDialog(
          context: context,
          title: status ? _tr('connection_success') : _tr('connection_failed'),
          icon: status ? Icons.check_circle : Icons.error,
          iconColor:
              status ? Colors.green : Theme.of(context).colorScheme.error,
          content: status
              ? _tr('connection_success_message')
              : _tr('connection_failed_message'),
        );
      }
    } catch (e) {
      AppLogger.error('[HostEditScreen] 测试连接失败', e);
      if (mounted) {
        Navigator.pop(context);
        CustomDialogs.showResultDialog(
          context: context,
          title: _tr('connection_failed'),
          icon: Icons.error,
          iconColor: Theme.of(context).colorScheme.error,
          content: '${_tr('connection_test_error')}:\n$e',
        );
      }
    }
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildHostForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInputField(
            controller: _controllers['name']!,
            label: _tr('host_name'),
            hint: _tr('host_name_hint'),
            icon: Icons.label,
            validator: (v) => v == null || v.trim().isEmpty
                ? _tr('please_enter_host_name')
                : v.trim().length < 2
                    ? _tr('host_name_min_length')
                    : null,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _controllers['address']!,
            label: _tr('host_address'),
            hint: _tr('host_address_hint'),
            icon: Icons.computer,
            keyboardType: TextInputType.url,
            validator: (v) => v == null || v.trim().isEmpty
                ? _tr('please_enter_host_address')
                : v.trim().contains(' ')
                    ? _tr('host_address_no_spaces')
                    : null,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _controllers['port']!,
            label: _tr('port'),
            hint: _tr('port_hint'),
            icon: Icons.settings_ethernet,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return _tr('please_enter_port');
              final port = int.tryParse(v.trim());
              return (port == null || port < 1 || port > 65535)
                  ? _tr('port_range_error')
                  : null;
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _controllers['token']!,
            label: _tr('password'),
            hint: _tr('please_enter_password'),
            icon: Icons.lock,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            validator: (v) => v == null || v.isEmpty
                ? _tr('please_enter_password')
                : v.length < 6
                    ? _tr('password_min_length')
                    : null,
            onFieldSubmitted: (_) => _saveHost(),
          ),
          const SizedBox(height: 32),
          _buildButton(
            onPressed: _isSaving ? null : _testConnection,
            label: _tr('test_connection'),
            icon: Icons.wifi_tethering,
            isPrimary: false,
          ),
          const SizedBox(height: 12),
          _buildButton(
            onPressed: _isSaving ? null : _saveHost,
            label: widget.host != null ? _tr('save_changes') : _tr('add_host'),
            isLoading: _isSaving,
          ),
          const SizedBox(height: 16),
          Text(
            _tr('required_field_note'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.surface.withOpacity(0),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.host != null ? _tr('edit_host') : _tr('add_host'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label *',
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          prefixIcon: Icon(icon, color: colorScheme.primary),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.error, width: 1),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(color: colorScheme.onSurface),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    bool isPrimary = true,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 48,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 4,
                shadowColor: colorScheme.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: colorScheme.primary.withOpacity(0.7),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: colorScheme.primary,
              ),
            ),
    );
  }
}

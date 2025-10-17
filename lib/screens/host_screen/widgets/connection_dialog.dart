// lib/widgets/connection_dialog.dart
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:provider/provider.dart';

import '../../../../models/host_config.dart';
import '../../../../providers/system_provider.dart';
import '../../../../services/storage_service.dart';
import '../../../../utils/format_utils.dart';
import 'dialogs.dart';
import '../host_theme.dart';

class ConnectionDialog extends StatefulWidget {
  final HostConfig? initialConfig;

  const ConnectionDialog({super.key, this.initialConfig});

  @override
  State<ConnectionDialog> createState() => _ConnectionDialogState();
}

class _ConnectionDialogState extends State<ConnectionDialog> {
  late TextEditingController _nameController;
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _tokenController;
  bool _obscureToken = true;
  bool _isConnecting = false;
  bool _saveHost = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialConfig?.name ?? '',
    );
    _hostController = TextEditingController(
      text: widget.initialConfig?.host ?? '127.0.0.1',
    );
    _portController = TextEditingController(
      text: widget.initialConfig?.port.toString() ?? '8888',
    );
    _tokenController = TextEditingController(
      text: widget.initialConfig?.token ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? double.infinity : 500,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        decoration: BoxDecoration(
          color: HostTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: HostTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: HostTheme.primaryColor.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    HostTheme.primaryGradient.createShader(bounds),
                child: Text(
                  '服务器连接',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),
              _buildTextField(
                controller: _nameController,
                label: '主机名称（选填）',
                icon: Icons.label,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              _buildTextField(
                controller: _hostController,
                label: '服务器地址',
                icon: Icons.dns,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              _buildTextField(
                controller: _portController,
                label: '端口',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              _buildTextField(
                controller: _tokenController,
                label: '访问令牌',
                icon: Icons.key,
                obscureText: _obscureToken,
                isSmallScreen: isSmallScreen,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureToken ? Icons.visibility : Icons.visibility_off,
                    color: HostTheme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureToken = !_obscureToken;
                    });
                  },
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Row(
                children: [
                  Checkbox(
                    value: _saveHost,
                    onChanged: (value) {
                      setState(() {
                        _saveHost = value ?? true;
                      });
                    },
                    activeColor: HostTheme.primaryColor,
                  ),
                  const Text(
                    '保存主机信息',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isConnecting
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: HostTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: _isConnecting ? null : _handleConnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: _isConnecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('连接'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleConnect() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 8888;
    final token = _tokenController.text.trim();
    final name = _nameController.text.trim();

    // 表单验证
    if (host.isEmpty || token.isEmpty) {
      _showSnackBar('请填写服务器地址和访问令牌', HostTheme.accentColor);
      return;
    }

    // IP地址格式验证（支持IPv4、域名、localhost）
    if (!FormatUtils.isValidHost(host)) {
      _showSnackBar('请输入有效的IP地址或域名', HostTheme.accentColor);
      return;
    }

    // 端口验证
    if (!FormatUtils.isValidPort(port)) {
      _showSnackBar('端口号必须在 1-65535 之间', HostTheme.accentColor);
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    // 先尝试连接
    if (mounted) {
      await context.read<SystemProvider>().connect(
            host,
            port,
            token,
            hostConfig: null, // 先不传入hostConfig
          );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        final provider = context.read<SystemProvider>();

        // 检查连接超时
        if (provider.errorMessage != null &&
            provider.errorMessage!.contains('超时')) {
          setState(() {
            _isConnecting = false;
          });
          _showTimeoutDialog();
          return;
        }

        // 检查是否是令牌验证失败
        if (provider.errorMessage == 'TOKEN_VERIFICATION_FAILED') {
          setState(() {
            _isConnecting = false;
          });
          _showTokenErrorDialog();
          return;
        }

        // 连接成功才处理保存逻辑
        if (provider.connectionState == ConnectionState.connected &&
            _saveHost) {
          final storage = await StorageService.create();
          final existingHosts = await storage.getHosts();

          // 检查是否存在相同的 host:port（排除当前编辑的主机）
          final duplicateHost = existingHosts.firstWhere(
            (h) =>
                h.host == host &&
                h.port == port &&
                (widget.initialConfig == null ||
                    h.id != widget.initialConfig!.id),
            orElse: () => HostConfig(
              id: '',
              name: '',
              host: '',
              port: 0,
              token: '',
              createdAt: DateTime.now(),
            ),
          );

          if (duplicateHost.id.isNotEmpty) {
            // 找到重复的主机，弹窗确认是否更新
            setState(() {
              _isConnecting = false;
            });

            final shouldUpdate = await Dialogs.showDuplicateHostDialog(
              context: context,
              existingHost: duplicateHost,
            );

            if (shouldUpdate == true) {
              // 更新现有主机
              final updatedHost = duplicateHost.copyWith(
                name: name.isEmpty ? '$host:$port' : name,
                token: token,
                lastConnected: DateTime.now(),
              );

              await storage.updateHost(updatedHost);
              provider.updateCurrentHost(updatedHost);

              if (mounted) {
                _showSnackBar('主机信息已更新', Colors.green);
                await Future.delayed(const Duration(milliseconds: 800));
                Navigator.pop(context);
              }
            } else {
              // 用户取消，断开连接
              provider.disconnect();
            }
            return;
          }

          // 没有重复，正常保存
          final hostConfig = HostConfig(
            id: widget.initialConfig?.id ?? DateTime.now().toString(),
            name: name.isEmpty ? '$host:$port' : name,
            host: host,
            port: port,
            token: token,
            createdAt: widget.initialConfig?.createdAt ?? DateTime.now(),
            lastConnected: DateTime.now(),
          );

          if (widget.initialConfig != null) {
            await storage.updateHost(hostConfig);
          } else {
            await storage.addHost(hostConfig);
          }

          provider.updateCurrentHost(hostConfig);

          _showSnackBar('主机信息已保存', Colors.green);
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            Navigator.pop(context);
          }
        } else if (provider.connectionState == ConnectionState.connected) {
          // 连接成功但不保存
          _showSnackBar('连接成功', Colors.green);
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // 连接失败
          _showSnackBar(
            provider.errorMessage ?? '连接失败',
            HostTheme.accentColor,
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _showTimeoutDialog() {
    Dialogs.showTimeoutDialog(
      context: context,
      host: widget.initialConfig ??
          HostConfig(
            id: '',
            name: '${_hostController.text}:${_portController.text}',
            host: _hostController.text,
            port: int.tryParse(_portController.text) ?? 8888,
            token: '',
            createdAt: DateTime.now(),
          ),
      onRetry: _handleConnect,
    );
  }

  void _showTokenErrorDialog() {
    Dialogs.showTokenErrorDialog(
      context: context,
      host: widget.initialConfig ??
          HostConfig(
            id: '',
            name: '${_hostController.text}:${_portController.text}',
            host: _hostController.text,
            port: int.tryParse(_portController.text) ?? 8888,
            token: '',
            createdAt: DateTime.now(),
          ),
      onEdit: () {
        _tokenController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _tokenController.text.length,
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isSmallScreen,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    String? errorText;

    // 实时验证IP地址
    if (label == '服务器地址' && controller.text.isNotEmpty) {
      final host = controller.text.trim();
      if (!FormatUtils.isValidHost(host)) {
        errorText = '请输入有效的IP地址或域名';
      }
    }

    // 验证端口
    if (label == '端口' && controller.text.isNotEmpty) {
      final port = int.tryParse(controller.text.trim());
      if (port == null || !FormatUtils.isValidPort(port)) {
        errorText = '端口号必须在 1-65535 之间';
      }
    }

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Colors.white,
        fontSize: isSmallScreen ? 14 : 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        errorStyle: const TextStyle(color: HostTheme.accentColor),
        prefixIcon: Icon(icon,
            color: HostTheme.primaryColor, size: isSmallScreen ? 20 : 24),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: Colors.white60,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: errorText != null
                ? HostTheme.accentColor.withOpacity(0.5)
                : HostTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: errorText != null
                ? HostTheme.accentColor
                : HostTheme.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: HostTheme.accentColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: HostTheme.accentColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      onChanged: (value) {
        // 触发验证更新
        if (label == '服务器地址' || label == '端口') {
          setState(() {});
        }
      },
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

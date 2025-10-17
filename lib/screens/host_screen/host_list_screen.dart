/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-10 21:48:49
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-13 00:37:24
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:provider/provider.dart';

import '../../models/host_config.dart';
import '../../services/storage_service.dart';
import '../../providers/system_provider.dart';

import 'host_theme.dart';
import 'widgets/connection_dialog.dart';
import 'widgets/animated_background.dart';

class HostListScreen extends StatefulWidget {
  const HostListScreen({super.key});

  @override
  State<HostListScreen> createState() => _HostListScreenState();
}

class _HostListScreenState extends State<HostListScreen> {
  List<HostConfig> _hosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHosts();
  }

  Future<void> _loadHosts() async {
    setState(() {
      _isLoading = true;
    });

    final storage = await StorageService.create();
    final hosts = await storage.getHosts();

    setState(() {
      _hosts = hosts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _hosts.isEmpty
                          ? _buildEmptyState()
                          : _buildHostList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHostDialog(),
        backgroundColor: HostTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HostTheme.primaryColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          ShaderMask(
            shaderCallback: (bounds) =>
                HostTheme.primaryGradient.createShader(bounds),
            child: const Text(
              '主机列表',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                HostTheme.primaryGradient.createShader(bounds),
            child: const Icon(
              Icons.storage,
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '暂无保存的主机',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右下角按钮添加主机',
            style: TextStyle(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildHostList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hosts.length,
      itemBuilder: (context, index) {
        final host = _hosts[index];
        return _buildHostCard(host);
      },
    );
  }

  Widget _buildHostCard(HostConfig host) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: HostTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HostTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: HostTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.dns, color: Colors.white),
        ),
        title: Row(
          children: [
            // 状态指示器
            if (host.status != HostStatus.unknown) ...[
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(host.status),
                  shape: BoxShape.circle,
                  boxShadow: host.status == HostStatus.online
                      ? [
                          BoxShadow(
                            color: _getStatusColor(host.status),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
            Expanded(
              child: Text(
                host.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (host.status == HostStatus.authFailed)
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
                size: 18,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${host.host}:${host.port}',
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            if (host.status != HostStatus.unknown) ...[
              const SizedBox(height: 4),
              Text(
                _getStatusText(host.status),
                style: TextStyle(
                  color: _getStatusColor(host.status).withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (host.lastConnected != null) ...[
              const SizedBox(height: 4),
              Text(
                '最后连接: ${_formatDateTime(host.lastConnected!)}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.link, color: HostTheme.primaryColor),
              onPressed: () => _connectToHost(host),
              tooltip: '连接',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: HostTheme.secondaryColor),
              onPressed: () => _editHost(host),
              tooltip: '编辑',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: HostTheme.accentColor),
              onPressed: () => _deleteHost(host),
              tooltip: '删除',
            ),
          ],
        ),
      ),
    );
  }

// 添加辅助方法
  Color _getStatusColor(HostStatus status) {
    switch (status) {
      case HostStatus.online:
        return Colors.green;
      case HostStatus.offline:
        return Colors.grey;
      case HostStatus.authFailed:
        return Colors.red;
      case HostStatus.unknown:
        return Colors.white24;
    }
  }

  String _getStatusText(HostStatus status) {
    switch (status) {
      case HostStatus.online:
        return '在线';
      case HostStatus.offline:
        return '离线';
      case HostStatus.authFailed:
        return 'Token验证失败';
      case HostStatus.unknown:
        return '未检测';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  void _showAddHostDialog() {
    showDialog(
      context: context,
      builder: (context) => const ConnectionDialog(),
    ).then((_) => _loadHosts());
  }

  void _editHost(HostConfig host) {
    showDialog(
      context: context,
      builder: (context) => ConnectionDialog(initialConfig: host),
    ).then((_) => _loadHosts());
  }

  Future<void> _deleteHost(HostConfig host) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HostTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('确认删除', style: TextStyle(color: Colors.white)),
        content: Text(
          '确定要删除主机 "${host.name}" 吗？',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: HostTheme.accentColor),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storage = await StorageService.create();
      await storage.deleteHost(host.id);
      _loadHosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('主机已删除'),
            backgroundColor: Colors.green, // 改为绿色
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _connectToHost(HostConfig host) async {
    final provider = context.read<SystemProvider>();

    // 显示连接中提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          color: HostTheme.cardColor,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在连接...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );

    await provider.connect(
      host.host,
      host.port,
      host.token,
      hostConfig: host,
    );

    if (mounted) {
      Navigator.pop(context); // 关闭加载对话框

      // 检查是否是令牌验证失败
      if (provider.errorMessage == 'TOKEN_VERIFICATION_FAILED') {
        _showTokenErrorDialog(host);
        return;
      }

      if (provider.connectionState == ConnectionState.connected) {
        Navigator.pop(context); // 返回主页面
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('连接成功'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? '连接失败'),
            backgroundColor: HostTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

// 显示令牌错误对话框
  void _showTokenErrorDialog(HostConfig host) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HostTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: HostTheme.accentColor.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: HostTheme.accentColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: HostTheme.accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: HostTheme.accentColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '令牌验证失败',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '主机 "${host.name}" 的访问令牌不正确',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: HostTheme.primaryColor.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '关闭',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: HostTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _editHost(host); // 打开编辑对话框
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '修改令牌',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
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
}

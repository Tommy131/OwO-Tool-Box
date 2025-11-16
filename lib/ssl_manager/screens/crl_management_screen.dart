/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-22
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// crl_manager_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../models/revoked_certificate.dart';
import '../providers/ssl_settings_provider.dart';
import '../services/openssl_service.dart';
import '../widgets/certificate_list_item.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/info_row.dart';

class CrlManagementScreen extends StatefulWidget {
  const CrlManagementScreen({super.key});

  @override
  State<CrlManagementScreen> createState() => _CrlManagementScreenState();
}

class _CrlManagementScreenState extends State<CrlManagementScreen> {
  final OpenSSLService _openSSLService = OpenSSLService();
  CAConfig? _caConfig;
  List<RevokedCertificate> _revokedCertificates = [];
  bool _isLoading = true;
  String _statusMessage = '正在初始化...';
  bool _isCASelected = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final isInstalled = await _openSSLService.isOpenSSLInstalled();

      if (!isInstalled) {
        setState(() {
          _statusMessage = '错误: 未检测到OpenSSL，请先安装OpenSSL';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _statusMessage = 'OpenSSL已就绪，请选择CA证书';
        _isLoading = false;
        _isCASelected = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '初始化失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectCAFiles() async {
    try {
      final certResult = await FilePicker.platform.pickFiles(
        dialogTitle: '选择CA证书文件',
        type: FileType.custom,
        allowedExtensions: ['pem', 'crt', 'cer'],
      );

      if (!mounted) return;
      if (certResult == null || certResult.files.isEmpty) {
        _showSnackBar('未选择CA证书文件');
        return;
      }

      final certPath = certResult.files.single.path!;

      final keyResult = await FilePicker.platform.pickFiles(
        dialogTitle: '选择CA私钥文件',
        type: FileType.custom,
        allowedExtensions: ['pem', 'key'],
      );

      if (!mounted) return;
      if (keyResult == null || keyResult.files.isEmpty) {
        _showSnackBar('未选择CA私钥文件');
        return;
      }

      final keyPath = keyResult.files.single.path!;

      if (!mounted) return;
      String? caPassword;
      final needPassword = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('CA私钥密码'),
          content: const Text('该CA私钥是否有密码保护？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('无密码'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('需要密码'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (needPassword == true) {
        final passwordController = TextEditingController();
        final password = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('输入CA私钥密码'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                hintText: '请输入CA私钥的密码',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context, passwordController.text),
                child: const Text('确定'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        if (password == null || password.isEmpty) {
          _showSnackBar('已取消');
          return;
        }
        caPassword = password;
      }

      if (!mounted) return;
      _showLoadingDialog('正在验证CA文件...');

      final isValid = await _validateCAFiles(certPath, keyPath, caPassword);

      if (!mounted) return;
      Navigator.pop(context);

      if (!isValid) {
        _showSnackBar('CA文件验证失败，请检查证书和密钥是否匹配');
        return;
      }

      if (!mounted) return;
      _showLoadingDialog('正在初始化CA环境...');
      _caConfig = await _initializeCAWithFiles(
        workDir: context.read<SSLSettingsProvider>().settings!.certificatePath,
        caCertPath: certPath,
        caKeyPath: keyPath,
        caPassword: caPassword,
      );

      await _loadRevokedCertificates();

      if (!mounted) return;
      Navigator.pop(context);

      setState(() {
        _isCASelected = true;
        _statusMessage = 'CA证书已加载';
      });

      _showSnackBar('CA证书配置成功');
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showSnackBar('选择CA文件失败: $e');
    }
  }

  Future<bool> _validateCAFiles(
    String certPath,
    String keyPath,
    String? password,
  ) async {
    try {
      final certValid = await _openSSLService.validateCertificate(certPath);
      if (!certValid) {
        return false;
      }

      final isCA = await _openSSLService.isCACertificate(certPath);
      if (!isCA) {
        if (mounted) _showSnackBar('所选证书不是CA证书');
        return false;
      }

      final keyValid = await _openSSLService.validatePrivateKey(
        keyPath,
        password: password,
      );
      if (!keyValid) {
        return false;
      }

      final match = await _openSSLService.verifyCertKeyMatch(
        certPath,
        keyPath,
        keyPassword: password,
      );

      return match;
    } catch (e) {
      return false;
    }
  }

  Future<CAConfig> _initializeCAWithFiles({
    required String workDir,
    required String caCertPath,
    required String caKeyPath,
    String? caPassword,
  }) async {
    final caDir = Directory('$workDir/crl_ca');
    if (!await caDir.exists()) {
      await caDir.create(recursive: true);
    }

    /* final newCertsDir = Directory('$workDir/crl_ca/newcerts');
    if (!await newCertsDir.exists()) {
      await newCertsDir.create(recursive: true);
    }

    final newCertPath = '${caDir.path}/ca-cert.pem';
    final newKeyPath = '${caDir.path}/ca-key.pem';
    await File(caCertPath).copy(newCertPath);
    await File(caKeyPath).copy(newKeyPath); */

    final certInfo = await _openSSLService.parseCertificateInfo(caCertPath);
    final subject = certInfo['subject'] as Map<String, String>? ?? {};
    final caName = subject['CN'] ?? 'Unknown CA';

    final config = CAConfig(
      caName: caName,
      caKeyPath: caCertPath,
      caCertPath: caKeyPath,
      certPath: '$workDir/SSL',
      indexPath: '${caDir.path}/index.txt',
      serialPath: '${caDir.path}/serial',
      crlNumberPath: '${caDir.path}/crlnumber',
      configPath: '${caDir.path}/../openssl.cnf',
      caPassword: caPassword,
    );

    await _createIndexFile(config.indexPath);
    await _createSerialFile(config.serialPath);
    await _createCRLNumberFile(config.crlNumberPath);

    return config;
  }

  Future<void> _createIndexFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      await file.writeAsString('');
    }
  }

  Future<void> _createSerialFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      await file.writeAsString('1000\n');
    }
  }

  Future<void> _createCRLNumberFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      await file.writeAsString('1000\n');
    }
  }

  Future<void> _switchCA() async {
    if (!mounted) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择CA来源'),
        content: ListTile(
          leading: const Icon(Icons.folder_open, color: Colors.blue),
          title: const Text('从文件选择CA'),
          subtitle: const Text('使用现有的CA证书和私钥'),
          onTap: () => Navigator.pop(context, 'select'),
        ),
      ),
    );

    if (!mounted) return;
    if (choice == 'select') {
      await _selectCAFiles();
    }
  }

  Future<void> _viewCACertificate() async {
    if (_caConfig == null || !mounted) return;

    _showLoadingDialog('正在读取CA证书信息...');

    try {
      final certInfo =
          await _openSSLService.getCertificateInfo(_caConfig!.caCertPath);
      final infoText = certInfo['info'] ?? '无法读取证书信息';

      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('CA证书信息'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                infoText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('读取CA证书信息失败: $e');
    }
  }

  Future<void> _loadRevokedCertificates() async {
    if (_caConfig == null) return;

    try {
      final certs = await _openSSLService.parseRevokedCertificates(_caConfig!);
      if (!mounted) return;
      setState(() {
        _revokedCertificates = certs;
      });
    } catch (e) {
      if (mounted) _showSnackBar('加载吊销证书列表失败: $e');
    }
  }

  Future<void> _revokeCertificate() async {
    if (_caConfig == null || !mounted) return;

    final serialController = TextEditingController();
    String selectedReason = 'keyCompromise';

    final List<Map<String, String>> reasons = [
      {'value': 'keyCompromise', 'label': '密钥泄露'},
      {'value': 'CACompromise', 'label': 'CA泄露'},
      {'value': 'affiliationChanged', 'label': '违反政策'},
      {'value': 'superseded', 'label': '替换证书'},
      {'value': 'cessationOfOperation', 'label': '停止使用'},
      {'value': 'unspecified', 'label': '其他'},
    ];

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('吊销证书'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: serialController,
                decoration: const InputDecoration(
                  labelText: '证书序列号',
                  hintText: '输入要吊销的证书序列号',
                  helperText: '提示：可从证书文件中使用openssl查看序列号',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: const InputDecoration(
                  labelText: '吊销原因',
                ),
                items: reasons.map((r) {
                  return DropdownMenuItem(
                    value: r['value'],
                    child: Text(r['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedReason = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (serialController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入证书序列号')),
                  );
                  return;
                }
                Navigator.pop(context, {
                  'serial': serialController.text,
                  'reason': selectedReason,
                });
              },
              child: const Text('吊销'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (result == null) return;

    _showLoadingDialog('正在吊销证书...');

    try {
      await _openSSLService.revokeCertificate(
        _caConfig!,
        result['serial']!,
        result['reason']!,
      );

      await _loadRevokedCertificates();

      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('证书已成功吊销');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('吊销失败: $e');
    }
  }

  Future<void> _generateCRL() async {
    if (_caConfig == null || !mounted) return;

    _showLoadingDialog('正在生成CRL...');

    try {
      await _openSSLService.generateCRL(_caConfig!);
      final crlText = await _openSSLService.displayCRL(_caConfig!);

      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('CRL内容'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: SelectableText(
                crlText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('生成CRL失败: $e');
    }
  }

  void _showLoadingDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(_statusMessage),
            ],
          ),
        ),
      );
    }

    if (!_isCASelected || _caConfig == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 100, color: Colors.blue),
              const SizedBox(height: 30),
              const Text(
                '欢迎使用证书吊销管理系统',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _selectCAFiles,
                    icon: const Icon(Icons.folder_open, size: 28),
                    label: const Text(
                      '从文件选择CA',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  '提示：\n• 选择CA：使用现有的CA证书和私钥文件\n• 创建CA：自动生成新的CA证书和私钥',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          CustomCard(
            margin: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CA信息',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _switchCA,
                          icon: const Icon(Icons.swap_horiz, size: 16),
                          label: const Text('切换CA'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: _viewCACertificate,
                          tooltip: '查看CA证书信息',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InfoRow(label: 'CA名称', value: _caConfig!.caName),
                InfoRow(label: 'CA证书', value: _caConfig!.caCertPath),
                InfoRow(label: 'CA私钥', value: _caConfig!.caKeyPath),
                InfoRow(label: '配置文件', value: _caConfig!.configPath),
                InfoRow(
                  label: '已吊销证书',
                  value: '${_revokedCertificates.length} 个',
                ),
                if (_caConfig!.caPassword != null)
                  const InfoRow(label: '密钥保护', value: '已加密'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                CustomButton(
                  text: '吊销证书',
                  icon: Icons.block,
                  onPressed: _revokeCertificate,
                  color: Colors.red,
                ),
                CustomButton(
                  text: '生成CRL',
                  icon: Icons.file_present,
                  onPressed: _generateCRL,
                  color: Colors.blue,
                ),
                CustomButton(
                  text: '刷新列表',
                  icon: Icons.refresh,
                  onPressed: _loadRevokedCertificates,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  '已吊销证书列表',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_revokedCertificates.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _revokedCertificates.isEmpty
                ? const Center(
                    child: Text(
                      '暂无吊销证书\n点击"吊销证书"按钮添加要吊销的证书',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _revokedCertificates.length,
                    itemBuilder: (context, index) {
                      return CertificateListItem(
                        certificate: _revokedCertificates[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

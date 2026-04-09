import 'dart:io';
import 'package:flutter/material.dart';

import '../network_input_rules.dart';

class PingProvider with ChangeNotifier {
  final TextEditingController pingHostController = TextEditingController(
    text: '8.8.8.8',
  );
  final TextEditingController pingOutputController = TextEditingController();
  final TextEditingController pingCountController = TextEditingController(
    text: '4',
  );
  bool isPingRunning = false;
  Process? _pingProcess;

  @override
  void dispose() {
    _pingProcess?.kill();
    pingHostController.dispose();
    pingOutputController.dispose();
    pingCountController.dispose();
    super.dispose();
  }

  Future<void> runPing() async {
    if (isPingRunning) return;
    final host = pingHostController.text.trim();
    final hostError = NetworkInputRules.validateHostTarget(
      host,
      fieldLabel: '目标主机',
    );
    if (hostError != null) {
      pingOutputController.text = '参数校验失败：$hostError';
      notifyListeners();
      return;
    }

    final countError = NetworkInputRules.validatePositiveInt(
      pingCountController.text,
      'Ping 次数',
      min: 1,
      max: 9999,
    );
    if (countError != null) {
      pingOutputController.text = '参数校验失败：$countError';
      notifyListeners();
      return;
    }

    isPingRunning = true;
    pingOutputController.clear();
    notifyListeners();
    try {
      final countArg = Platform.isWindows ? '-n' : '-c';
      _pingProcess = await Process.start('ping', [
        countArg,
        pingCountController.text.trim(),
        host,
      ]);
      _pingProcess!.stdout.transform(const SystemEncoding().decoder).listen((
        data,
      ) {
        pingOutputController.text += data;
        notifyListeners();
      });
      await _pingProcess!.exitCode;
    } catch (e) {
      pingOutputController.text = 'Error: $e';
    } finally {
      isPingRunning = false;
      _pingProcess = null;
      notifyListeners();
    }
  }

  void stopPing() => _pingProcess?.kill();

  void clearPing() {
    pingOutputController.clear();
    stopPing();
    notifyListeners();
  }
}

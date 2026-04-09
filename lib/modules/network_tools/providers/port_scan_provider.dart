import 'dart:io';
import 'package:flutter/material.dart';

import '../network_input_rules.dart';

class PortScanProvider with ChangeNotifier {
  final TextEditingController portHostController = TextEditingController(
    text: '127.0.0.1',
  );
  final TextEditingController portRangeController = TextEditingController(
    text: '80,443,3389,8080',
  );
  final TextEditingController portOutputController = TextEditingController();
  bool isPortScanning = false;

  @override
  void dispose() {
    portHostController.dispose();
    portRangeController.dispose();
    portOutputController.dispose();
    super.dispose();
  }

  Future<void> runPortScan() async {
    if (isPortScanning) return;
    final host = portHostController.text.trim();
    final hostError = NetworkInputRules.validateHostTarget(
      host,
      fieldLabel: '目标主机',
    );
    if (hostError != null) {
      portOutputController.text = '参数校验失败：$hostError';
      notifyListeners();
      return;
    }

    final portListError = NetworkInputRules.validatePortList(
      portRangeController.text,
    );
    if (portListError != null) {
      portOutputController.text = '参数校验失败：$portListError';
      notifyListeners();
      return;
    }

    final ports = NetworkInputRules.parsePortList(portRangeController.text);
    isPortScanning = true;
    portOutputController.clear();

    _log('Starting port scan for host: $host');
    _log('Targeting ${ports.length} ports...\n', addTimestamp: false);

    int openCount = 0;
    int closedCount = 0;

    for (var port in ports) {
      if (!isPortScanning) break;
      try {
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 1),
        );
        _log('  [🟢 OPEN]    Port $port', addTimestamp: false);
        openCount++;
        socket.destroy();
      } catch (_) {
        _log('  [🔴 CLOSED] Port $port', addTimestamp: false);
        closedCount++;
      }
      notifyListeners();
    }

    isPortScanning = false;
    _log('\n--- Scan Summary ---', addTimestamp: false);
    _log('Total Ports: ${openCount + closedCount}', addTimestamp: false);
    _log('Open: $openCount, Closed: $closedCount', addTimestamp: false);
    _log('Scan finished.');
    notifyListeners();
  }

  void stopPortScan() {
    if (isPortScanning) {
      isPortScanning = false;
      _log('Scan aborted by user.');
    }
  }

  void clearPort() {
    portOutputController.clear();
    stopPortScan();
    notifyListeners();
  }

  void _log(String message, {bool addTimestamp = true}) {
    final timestamp = addTimestamp
        ? "[${DateTime.now().toString().substring(11, 19)}] "
        : "";
    portOutputController.text +=
        "$timestamp$message${message.endsWith('\n') ? '' : '\n'}";
    notifyListeners();
  }
}

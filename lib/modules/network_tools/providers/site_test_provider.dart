import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../network_input_rules.dart';

class SiteTestProvider with ChangeNotifier {
  final TextEditingController siteUrlController = TextEditingController(
    text: 'https://google.com',
  );
  final TextEditingController siteOutputController = TextEditingController();
  bool isSiteTesting = false;

  @override
  void dispose() {
    siteUrlController.dispose();
    siteOutputController.dispose();
    super.dispose();
  }

  Future<void> runSiteTest() async {
    if (isSiteTesting) return;
    final urlStr = siteUrlController.text.trim();
    final urlError = NetworkInputRules.validateSiteUrl(urlStr);
    if (urlError != null) {
      siteOutputController.text = '参数校验失败：$urlError';
      notifyListeners();
      return;
    }

    isSiteTesting = true;
    siteOutputController.clear();

    _log('Initializing security scan for: $urlStr');

    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse(urlStr);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      stopwatch.stop();

      final emoji = response.statusCode >= 200 && response.statusCode < 300
          ? '✅'
          : '⚠️';

      var output = '\n--- Scan Results ---\n';
      output += 'Status: $emoji ${response.statusCode}\n';
      output += 'Response Time: ${stopwatch.elapsedMilliseconds}ms\n\n';

      output += '--- HTTP Headers ---\n';
      response.headers.forEach((key, value) {
        output += '$key: $value\n';
      });

      _log(output, addTimestamp: false);
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      isSiteTesting = false;
      _log('Scan completed.');
      notifyListeners();
    }
  }

  void clearSite() {
    siteOutputController.clear();
    isSiteTesting = false;
    notifyListeners();
  }

  void _log(String message, {bool addTimestamp = true}) {
    final timestamp = addTimestamp
        ? "[${DateTime.now().toString().substring(11, 19)}] "
        : "";
    siteOutputController.text +=
        "$timestamp$message${message.endsWith('\n') ? '' : '\n'}";
    notifyListeners();
  }
}

/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-30
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2026-01-30
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

class DevToolsProvider with ChangeNotifier {
  // Base64 Control
  final base64InputController = TextEditingController();
  final base64OutputController = TextEditingController();

  // URL Control
  final urlInputController = TextEditingController();
  final urlOutputController = TextEditingController();

  // JSON Control
  final jsonInputController = TextEditingController();
  final jsonOutputController = TextEditingController();

  // UUID Control
  final List<String> uuidList = [];
  final _uuid = const Uuid();

  // Hash Control
  final hashInputController = TextEditingController();
  final hashOutputController = TextEditingController();
  String selectedHashAlgo = 'MD5';

  // Password Control
  final passwordOutputController = TextEditingController();
  double passwordLength = 16;
  bool passIncludeUpper = true;
  bool passIncludeLower = true;
  bool passIncludeNumbers = true;
  bool passIncludeSymbols = true;

  @override
  void dispose() {
    base64InputController.dispose();
    base64OutputController.dispose();
    urlInputController.dispose();
    urlOutputController.dispose();
    jsonInputController.dispose();
    jsonOutputController.dispose();
    hashInputController.dispose();
    hashOutputController.dispose();
    passwordOutputController.dispose();
    super.dispose();
  }

  // --- Base64 ---
  void base64Encode() {
    try {
      final text = base64InputController.text;
      final encoded = base64.encode(utf8.encode(text));
      base64OutputController.text = encoded;
    } catch (e) {
      base64OutputController.text = 'Error: $e';
    }
    notifyListeners();
  }

  void base64Decode() {
    try {
      final text = base64InputController.text;
      final decoded = utf8.decode(base64.decode(text));
      base64OutputController.text = decoded;
    } catch (e) {
      base64OutputController.text = 'Error: $e';
    }
    notifyListeners();
  }

  // --- URL ---
  void urlEncode() {
    try {
      urlOutputController.text = Uri.encodeComponent(urlInputController.text);
    } catch (e) {
      urlOutputController.text = 'Error: $e';
    }
    notifyListeners();
  }

  void urlDecode() {
    try {
      urlOutputController.text = Uri.decodeComponent(urlInputController.text);
    } catch (e) {
      urlOutputController.text = 'Error: $e';
    }
    notifyListeners();
  }

  // --- JSON ---
  void formatJson() {
    try {
      final input = jsonInputController.text;
      final dynamic decoded = json.decode(input);
      const encoder = JsonEncoder.withIndent('  ');
      jsonOutputController.text = encoder.convert(decoded);
    } catch (e) {
      jsonOutputController.text = 'Error: $e';
    }
    notifyListeners();
  }

  // --- UUID ---
  void generateUuidV4() {
    uuidList.insert(0, _uuid.v4());
    if (uuidList.length > 50) uuidList.removeLast();
    notifyListeners();
  }

  void generateUuidV1() {
    uuidList.insert(0, _uuid.v1());
    if (uuidList.length > 50) uuidList.removeLast();
    notifyListeners();
  }

  // --- Hash ---
  void setHashAlgo(String algo) {
    selectedHashAlgo = algo;
    notifyListeners();
  }

  void calculateHash() {
    final input = hashInputController.text;
    final bytes = utf8.encode(input);
    switch (selectedHashAlgo) {
      case 'MD5':
        hashOutputController.text = md5.convert(bytes).toString();
        break;
      case 'SHA1':
        hashOutputController.text = sha1.convert(bytes).toString();
        break;
      case 'SHA256':
        hashOutputController.text = sha256.convert(bytes).toString();
        break;
    }
    notifyListeners();
  }

  // --- Password ---
  void setPasswordLength(double length) {
    passwordLength = length;
    notifyListeners();
  }

  void setPassIncludeUpper(bool v) {
    passIncludeUpper = v;
    notifyListeners();
  }

  void setPassIncludeLower(bool v) {
    passIncludeLower = v;
    notifyListeners();
  }

  void setPassIncludeNumbers(bool v) {
    passIncludeNumbers = v;
    notifyListeners();
  }

  void setPassIncludeSymbols(bool v) {
    passIncludeSymbols = v;
    notifyListeners();
  }

  void generatePassword() {
    const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lower = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String allowedChars = '';
    if (passIncludeUpper) allowedChars += upper;
    if (passIncludeLower) allowedChars += lower;
    if (passIncludeNumbers) allowedChars += numbers;
    if (passIncludeSymbols) allowedChars += symbols;

    if (allowedChars.isEmpty) {
      passwordOutputController.text = '';
      return;
    }

    final random = Random.secure();
    final password = List.generate(passwordLength.toInt(), (index) {
      return allowedChars[random.nextInt(allowedChars.length)];
    }).join();

    passwordOutputController.text = password;
    notifyListeners();
  }

  // --- Clear Methods ---
  void clearBase64() {
    base64InputController.clear();
    base64OutputController.clear();
    notifyListeners();
  }

  void clearUrl() {
    urlInputController.clear();
    urlOutputController.clear();
    notifyListeners();
  }

  void clearJson() {
    jsonInputController.clear();
    jsonOutputController.clear();
    notifyListeners();
  }

  void clearUuid() {
    uuidList.clear();
    notifyListeners();
  }

  void clearHash() {
    hashInputController.clear();
    hashOutputController.clear();
    notifyListeners();
  }

  void clearPassword() {
    passwordOutputController.clear();
    notifyListeners();
  }
}

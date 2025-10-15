/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-10 21:48:27
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-10 21:48:27
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// lib/services/tcp_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TCPService {
  Socket? _socket;
  final String host;
  final int port;
  final StreamController<String> _responseController =
      StreamController<String>.broadcast();

  Stream<String> get responseStream => _responseController.stream;

  TCPService({
    required this.host,
    required this.port,
  });

  Future<bool> connect() async {
    try {
      _socket = await Socket.connect(host, port);
      _socket!.listen(
        (data) {
          final response = utf8.decode(data);
          _responseController.add(response);
        },
        onError: (error) {
          _responseController.addError(error);
        },
        onDone: () {
          disconnect();
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> authenticate(String token) async {
    if (_socket == null) return;
    _socket!.write('$token\n');
    await _socket!.flush();
  }

  Future<void> sendCommand(String command) async {
    if (_socket == null) return;
    _socket!.write('$command\n');
    await _socket!.flush();
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _responseController.close();
  }
}

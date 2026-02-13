import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkToolsProvider with ChangeNotifier {
  // --- Global Controllers & State ---
  final TextEditingController pingHostController = TextEditingController(
    text: '8.8.8.8',
  );
  final TextEditingController pingOutputController = TextEditingController();
  final TextEditingController pingCountController = TextEditingController(
    text: '4',
  );
  bool isPingRunning = false;
  Process? _pingProcess;

  // --- Performance Test State ---
  final TextEditingController perfHostController = TextEditingController(
    text: '0.0.0.0',
  );
  final TextEditingController perfPortController = TextEditingController(
    text: '8088',
  );
  final TextEditingController perfOutputController = TextEditingController();
  final TextEditingController perfConnectionsController = TextEditingController(
    text: '10',
  );
  final TextEditingController perfIntervalController = TextEditingController(
    text: '50',
  );
  final TextEditingController perfDataSizeController = TextEditingController(
    text: '1024',
  );

  String protocol = 'TCP'; // or 'UDP'
  String testMode = 'Client'; // Client or Server

  bool isPerfRunning = false;

  // Real-time metrics
  double socketSendPerSec = 0;
  double socketReceivePerSec = 0;
  double sendBytesPerSec = 0;
  double receiveBytesPerSec = 0;

  // Persistent counters for total session stats
  double totalSocketSend = 0;
  double totalSocketReceive = 0;
  double totalSendBytes = 0;
  double totalReceiveBytes = 0;

  // History for charts (max 30 points)
  List<double> socketSendHistory = [];
  List<double> socketReceiveHistory = [];
  List<double> sendBytesHistory = [];
  List<double> receiveBytesHistory = [];

  Isolate? _perfIsolate;
  ReceivePort? _perfReceivePort;

  // --- Site Test & Port Scan ---
  final TextEditingController siteUrlController = TextEditingController(
    text: 'https://google.com',
  );
  final TextEditingController siteOutputController = TextEditingController();
  bool isSiteTesting = false;

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
    stopPerfTest();
    pingHostController.dispose();
    pingOutputController.dispose();
    pingCountController.dispose();
    perfHostController.dispose();
    perfPortController.dispose();
    perfOutputController.dispose();
    perfConnectionsController.dispose();
    perfIntervalController.dispose();
    perfDataSizeController.dispose();
    siteUrlController.dispose();
    siteOutputController.dispose();
    portHostController.dispose();
    portRangeController.dispose();
    portOutputController.dispose();
    _pingProcess?.kill();
    super.dispose();
  }

  // --- Ping Logic ---
  Future<void> runPing() async {
    if (isPingRunning) return;
    isPingRunning = true;
    pingOutputController.clear();
    notifyListeners();
    final host = pingHostController.text.trim();
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

  // --- Performance Test Logic ---
  Future<void> runPerfTest() async {
    if (isPerfRunning) return;
    isPerfRunning = true;
    perfOutputController.clear();
    _resetMetrics();
    notifyListeners();

    final hostText = perfHostController.text.trim();
    final port = int.tryParse(perfPortController.text.trim()) ?? 8088;
    final connCount = int.tryParse(perfConnectionsController.text.trim()) ?? 1;
    final interval = int.tryParse(perfIntervalController.text.trim()) ?? 50;
    final size = int.tryParse(perfDataSizeController.text.trim()) ?? 1024;

    _log('Starting $testMode mode ($protocol) in background isolate...');

    try {
      _perfReceivePort = ReceivePort();
      _perfIsolate = await Isolate.spawn(
        _perfIsolateWorker,
        _perfReceivePort!.sendPort,
      );

      final config = {
        'host': hostText,
        'port': port,
        'protocol': protocol,
        'mode': testMode,
        'connections': connCount,
        'interval': interval,
        'size': size,
      };

      int messageCount = 0;
      _perfReceivePort!.listen((message) {
        if (message is SendPort) {
          message.send(config);
        } else if (message is String) {
          _log(message, addTimestamp: false);
          notifyListeners();
        } else if (message is Map) {
          if (message.containsKey('fatal')) {
            _log('Fatal Error: ${message['fatal']}', addTimestamp: true);
            stopPerfTest();
            return;
          }
          socketSendPerSec = (message['sendPkt'] as num).toDouble();
          socketReceivePerSec = (message['receivePkt'] as num).toDouble();
          sendBytesPerSec = (message['sendBytes'] as num).toDouble();
          receiveBytesPerSec = (message['receiveBytes'] as num).toDouble();

          totalSocketSend += socketSendPerSec;
          totalSocketReceive += socketReceivePerSec;
          totalSendBytes += sendBytesPerSec;
          totalReceiveBytes += receiveBytesPerSec;

          _updateHistory();
          notifyListeners();
        }

        // Safety limit for log area
        messageCount++;
        if (messageCount > 100) {
          final lines = perfOutputController.text.split('\n');
          if (lines.length > 500) {
            perfOutputController.text =
                "... (logs truncated)\n${lines.sublist(lines.length - 200).join('\n')}";
          }
          messageCount = 0;
        }
      });
    } catch (e) {
      _log('Isolate Error: $e');
      stopPerfTest();
    }
  }

  void stopPerfTest() {
    if (!isPerfRunning) return;
    isPerfRunning = false;
    _perfIsolate?.kill(priority: Isolate.immediate);
    _perfIsolate = null;
    _perfReceivePort?.close();
    _perfReceivePort = null;
    final modeMsg = testMode == 'Server'
        ? 'Monitoring service stopped.'
        : 'Test stopped.';
    _log(modeMsg);
    notifyListeners();
  }

  void _log(String message, {bool addTimestamp = true}) {
    final timestamp = addTimestamp
        ? "[${DateTime.now().toString().substring(11, 19)}] "
        : "";
    perfOutputController.text +=
        "$timestamp$message${message.endsWith('\n') ? '' : '\n'}";
    notifyListeners();
  }

  void _resetMetrics() {
    socketSendPerSec = 0;
    socketReceivePerSec = 0;
    sendBytesPerSec = 0;
    receiveBytesPerSec = 0;
    totalSocketSend = 0;
    totalSocketReceive = 0;
    totalSendBytes = 0;
    totalReceiveBytes = 0;
    socketSendHistory.clear();
    socketReceiveHistory.clear();
    sendBytesHistory.clear();
    receiveBytesHistory.clear();
  }

  void _updateHistory() {
    socketSendHistory.add(socketSendPerSec);
    socketReceiveHistory.add(socketReceivePerSec);
    sendBytesHistory.add(sendBytesPerSec / (1024 * 1024)); // MB/s
    receiveBytesHistory.add(receiveBytesPerSec / (1024 * 1024)); // MB/s

    if (socketSendHistory.length > 30) {
      socketSendHistory.removeAt(0);
      socketReceiveHistory.removeAt(0);
      sendBytesHistory.removeAt(0);
      receiveBytesHistory.removeAt(0);
    }
  }

  // --- Site Test ---
  Future<void> runSiteTest() async {
    if (isSiteTesting) return;
    isSiteTesting = true;
    siteOutputController.clear();
    final urlStr = siteUrlController.text.trim();

    _logTo(siteOutputController, 'Initializing security scan for: $urlStr');

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

      _logTo(siteOutputController, output, addTimestamp: false);
    } catch (e) {
      _logTo(siteOutputController, '❌ Error: $e');
    } finally {
      isSiteTesting = false;
      _logTo(siteOutputController, 'Scan completed.');
      notifyListeners();
    }
  }

  // --- Port Scan ---
  Future<void> runPortScan() async {
    if (isPortScanning) return;
    isPortScanning = true;
    portOutputController.clear();
    final host = portHostController.text.trim();
    final ports = portRangeController.text
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();

    _logTo(portOutputController, 'Starting port scan for host: $host');
    _logTo(
      portOutputController,
      'Targeting ${ports.length} ports...\n',
      addTimestamp: false,
    );

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
        _logTo(
          portOutputController,
          '  [🟢 OPEN]    Port $port',
          addTimestamp: false,
        );
        openCount++;
        socket.destroy();
      } catch (_) {
        _logTo(
          portOutputController,
          '  [🔴 CLOSED] Port $port',
          addTimestamp: false,
        );
        closedCount++;
      }
      notifyListeners();
    }

    isPortScanning = false;
    _logTo(portOutputController, '\n--- Scan Summary ---', addTimestamp: false);
    _logTo(
      portOutputController,
      'Total Ports: ${openCount + closedCount}',
      addTimestamp: false,
    );
    _logTo(
      portOutputController,
      'Open: $openCount, Closed: $closedCount',
      addTimestamp: false,
    );
    _logTo(portOutputController, 'Scan finished.');
    notifyListeners();
  }

  void stopPortScan() {
    if (isPortScanning) {
      isPortScanning = false;
      _logTo(portOutputController, 'Scan aborted by user.');
    }
  }

  void _logTo(
    TextEditingController controller,
    String message, {
    bool addTimestamp = true,
  }) {
    final timestamp = addTimestamp
        ? "[${DateTime.now().toString().substring(11, 19)}] "
        : "";
    controller.text +=
        "$timestamp$message${message.endsWith('\n') ? '' : '\n'}";
    notifyListeners();
  }

  // --- Clear Methods ---
  void clearPing() {
    pingOutputController.clear();
    stopPing();
    notifyListeners();
  }

  void clearPerf() {
    perfOutputController.clear();
    stopPerfTest();
    notifyListeners();
  }

  void clearSite() {
    siteOutputController.clear();
    isSiteTesting = false;
    notifyListeners();
  }

  void clearPort() {
    portOutputController.clear();
    stopPortScan();
    notifyListeners();
  }
}

// --- Background Isolate Worker ---
void _perfIsolateWorker(SendPort mainSendPort) async {
  final rp = ReceivePort();
  mainSendPort.send(rp.sendPort);

  final dynamic config = await rp.first;
  final String host = config['host'];
  final int port = config['port'];
  final String protocol = config['protocol'];
  final String mode = config['mode'];
  final int connections = config['connections'];
  final int interval = config['interval'];
  final int size = config['size'];
  final payload = Uint8List(size);

  double sendPkt = 0;
  double receivePkt = 0;
  double sendBytes = 0;
  double receiveBytes = 0;

  final List<dynamic> activeSockets = [];
  ServerSocket? serverSocket;

  // Periodic metrics report
  Timer.periodic(const Duration(seconds: 1), (t) {
    mainSendPort.send({
      'sendPkt': sendPkt,
      'receivePkt': receivePkt,
      'sendBytes': sendBytes,
      'receiveBytes': receiveBytes,
    });
    // Reset local counters for next second
    sendPkt = 0;
    receivePkt = 0;
    sendBytes = 0;
    receiveBytes = 0;
  });

  try {
    if (mode == 'Server') {
      dynamic bindAddr = InternetAddress.anyIPv4;
      if (host.isNotEmpty && host != '0.0.0.0' && host != 'any') {
        try {
          bindAddr = InternetAddress(host);
        } catch (_) {
          final lookup = await InternetAddress.lookup(host);
          if (lookup.isNotEmpty) bindAddr = lookup.first;
        }
      }

      mainSendPort.send(
        'Server started. Listening on ${bindAddr is InternetAddress ? bindAddr.address : bindAddr}:$port\n',
      );

      if (protocol == 'TCP') {
        serverSocket = await ServerSocket.bind(bindAddr, port);
        serverSocket.listen((socket) {
          activeSockets.add(socket);
          final rAddr = '${socket.remoteAddress.address}:${socket.remotePort}';
          mainSendPort.send('Client connected: $rAddr\n');
          socket.listen(
            (data) {
              receivePkt++;
              receiveBytes += data.length;
            },
            onDone: () {
              socket.destroy();
              activeSockets.remove(socket);
              mainSendPort.send('Client disconnected: $rAddr\n');
            },
            onError: (e) => mainSendPort.send('Socket Error: $e\n'),
          );
        });
      } else {
        final socket = await RawDatagramSocket.bind(bindAddr, port);
        activeSockets.add(socket);
        socket.listen((event) {
          if (event == RawSocketEvent.read) {
            while (true) {
              final dg = socket.receive();
              if (dg == null) break;
              receivePkt++;
              receiveBytes += dg.data.length;
            }
          }
        });
      }
    } else {
      // Client Mode
      mainSendPort.send('Resolving host $host...\n');
      final lookup = await InternetAddress.lookup(host);
      if (lookup.isEmpty) throw Exception('Host resolve failed');
      final targetAddr = lookup.first;

      mainSendPort.send(
        'Client started. Targeting ${targetAddr.address}:$port with $connections connections\n',
      );

      if (protocol == 'TCP') {
        for (int i = 0; i < connections; i++) {
          final socket = await Socket.connect(
            targetAddr,
            port,
            timeout: const Duration(seconds: 5),
          );
          activeSockets.add(socket);
          socket.listen((data) {
            receivePkt++;
            receiveBytes += data.length;
          }, onError: (e) => mainSendPort.send('Socket Error: $e\n'));
        }
      } else {
        for (int i = 0; i < connections; i++) {
          final socket = await RawDatagramSocket.bind(
            InternetAddress.anyIPv4,
            0,
          );
          activeSockets.add(socket);
          socket.listen((event) {
            if (event == RawSocketEvent.read) {
              while (true) {
                final dg = socket.receive();
                if (dg == null) break;
                receivePkt++;
                receiveBytes += dg.data.length;
              }
            }
          });
        }
      }

      mainSendPort.send('Data transmission started ($interval ms interval).\n');

      // Sending Timer
      Timer.periodic(Duration(milliseconds: interval), (t) {
        for (var s in activeSockets) {
          try {
            if (s is Socket) {
              s.add(payload);
              sendPkt++;
              sendBytes += payload.length;
            } else if (s is RawDatagramSocket) {
              final result = s.send(payload, targetAddr, port);
              if (result > 0) {
                sendPkt++;
                sendBytes += result;
              }
            }
          } catch (_) {}
        }
      });
    }
  } catch (e) {
    mainSendPort.send({'fatal': e.toString()});
  }
}

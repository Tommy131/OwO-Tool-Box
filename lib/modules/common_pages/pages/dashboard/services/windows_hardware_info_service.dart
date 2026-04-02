import 'dart:convert';
import 'dart:io';

class WindowsHardwareInfoService {
  Future<Map<String, String>> load() async {
    final data = <String, String>{};
    await _loadWithWmic(data);

    if (data['motherboard']?.isNotEmpty == true &&
        data['processorModel']?.isNotEmpty == true) {
      return data;
    }

    await _loadWithPowerShell(data);
    return data;
  }

  Future<void> _loadWithWmic(Map<String, String> target) async {
    try {
      final baseboardResult = await Process.run('wmic', [
        'baseboard',
        'get',
        'product,Manufacturer',
        '/format:list',
      ]);
      if (baseboardResult.exitCode == 0) {
        final lines = baseboardResult.stdout.toString().split(RegExp(r'\r?\n'));
        String manufacturer = '';
        String product = '';
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('Manufacturer=')) {
            manufacturer = trimmed.substring('Manufacturer='.length).trim();
          } else if (trimmed.startsWith('Product=')) {
            product = trimmed.substring('Product='.length).trim();
          }
        }
        final motherboard = '$manufacturer $product'.trim();
        if (motherboard.isNotEmpty) {
          target['motherboard'] = motherboard;
        }
      }
    } catch (_) {}

    try {
      final cpuResult = await Process.run('wmic', ['cpu', 'get', 'name']);
      if (cpuResult.exitCode == 0) {
        final lines = cpuResult.stdout.toString().split(RegExp(r'\r?\n'));
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && trimmed != 'Name') {
            target['processorModel'] = trimmed;
            break;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _loadWithPowerShell(Map<String, String> target) async {
    try {
      const script = r'''
function Get-First([string] $className) {
  try {
    return Get-CimInstance -ClassName $className -ErrorAction Stop | Select-Object -First 1
  } catch {
    try {
      return Get-WmiObject -Class $className -ErrorAction Stop | Select-Object -First 1
    } catch {
      return $null
    }
  }
}

$bb = Get-First 'Win32_BaseBoard'
$cpu = Get-First 'Win32_Processor'

$motherboard = ''
if ($bb -ne $null) {
  $parts = @()
  if ($bb.Manufacturer) { $parts += ($bb.Manufacturer.ToString().Trim()) }
  if ($bb.Product) { $parts += ($bb.Product.ToString().Trim()) }
  $motherboard = ($parts | Where-Object { $_ -and $_.Trim() -ne '' } | ForEach-Object { $_.Trim() }) -join ' '
}

$processorModel = ''
if ($cpu -ne $null -and $cpu.Name) {
  $processorModel = $cpu.Name.ToString().Trim()
}

$obj = [pscustomobject]@{
  motherboard = $motherboard
  processorModel = $processorModel
}

$json = $obj | ConvertTo-Json -Compress
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json))
''';

      final psCommand =
          '[Console]::OutputEncoding=[Text.Encoding]::UTF8; \$OutputEncoding=[Console]::OutputEncoding; \$ProgressPreference="SilentlyContinue"; ${script.trim()}';

      final psResult = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-NonInteractive',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          psCommand,
        ],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      if (psResult.exitCode != 0) {
        return;
      }

      final base64Text = psResult.stdout.toString().trim();
      if (base64Text.isEmpty) {
        return;
      }

      final jsonText = utf8.decode(base64Decode(base64Text));
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) {
        return;
      }

      final motherboard = decoded['motherboard']?.toString().trim() ?? '';
      final processorModel = decoded['processorModel']?.toString().trim() ?? '';
      if (target['motherboard']?.isNotEmpty != true && motherboard.isNotEmpty) {
        target['motherboard'] = motherboard;
      }
      if (target['processorModel']?.isNotEmpty != true &&
          processorModel.isNotEmpty) {
        target['processorModel'] = processorModel;
      }
    } catch (_) {}
  }
}

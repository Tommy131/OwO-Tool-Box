import 'dart:io';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:uuid/uuid.dart';
import '../models/certificate.dart';
import '../models/certificate_purpose.dart';

class OpenSSLService {
  final Shell _shell = Shell();
  final _uuid = const Uuid();

  Future<bool> isOpenSSLInstalled() async {
    try {
      await _shell.run('openssl version');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 解析证书文件获取信息
  Future<Map<String, dynamic>> parseCertificateInfo(String certPath) async {
    try {
      // 使用更详细的格式获取证书信息
      final subjectResult =
          await _shell.run('openssl x509 -in "$certPath" -noout -subject');
      final issuerResult =
          await _shell.run('openssl x509 -in "$certPath" -noout -issuer');
      final datesResult = await _shell
          .run('openssl x509 -in "$certPath" -noout -startdate -enddate');
      final serialResult =
          await _shell.run('openssl x509 -in "$certPath" -noout -serial');

      final Map<String, dynamic> info = {};

      // 解析subject
      final subjectLine = subjectResult.first.stdout.toString().trim();
      if (subjectLine.startsWith('subject=')) {
        info['subject'] = _parseSubject(subjectLine.substring(8));
      }

      // 解析issuer
      final issuerLine = issuerResult.first.stdout.toString().trim();
      if (issuerLine.startsWith('issuer=')) {
        info['issuer'] = _parseSubject(issuerLine.substring(7));
      }

      // 解析日期
      final datesOutput = datesResult.first.stdout.toString();
      final dateLines = datesOutput.split('\n');

      for (var line in dateLines) {
        line = line.trim();
        if (line.startsWith('notBefore=')) {
          final dateStr = line.substring(10).trim();
          info['notBefore'] = _parseOpenSSLDate(dateStr);
        } else if (line.startsWith('notAfter=')) {
          final dateStr = line.substring(9).trim();
          info['notAfter'] = _parseOpenSSLDate(dateStr);
        }
      }

      // 解析serial
      final serialLine = serialResult.first.stdout.toString().trim();
      if (serialLine.startsWith('serial=')) {
        info['serial'] = serialLine.substring(7).trim();
      }

      return info;
    } catch (e) {
      throw Exception('Failed to parse certificate: $e');
    }
  }

  /// 解析OpenSSL日期格式
  DateTime _parseOpenSSLDate(String dateStr) {
    try {
      // OpenSSL日期格式: MMM DD HH:MM:SS YYYY GMT
      // 例如: Jan 15 12:00:00 2024 GMT

      dateStr = dateStr.trim();

      // 移除GMT后缀
      if (dateStr.endsWith(' GMT')) {
        dateStr = dateStr.substring(0, dateStr.length - 4);
      }

      // 月份映射
      final months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };

      // 分割日期字符串
      final parts = dateStr.split(' ').where((s) => s.isNotEmpty).toList();

      if (parts.length >= 4) {
        final monthStr = parts[0];
        final day = int.parse(parts[1]);
        final timeParts = parts[2].split(':');
        final year = int.parse(parts[3]);

        final month = months[monthStr] ?? 1;
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final second = int.parse(timeParts[2]);

        return DateTime.utc(year, month, day, hour, minute, second);
      }

      // 如果解析失败，尝试其他格式
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('Date parsing error: $e, input: $dateStr');
      // 返回当前时间作为后备
      return DateTime.now();
    }
  }

  /// 解析主题字段（已有的方法，保持不变）
  Map<String, String> _parseSubject(String subject) {
    final Map<String, String> result = {};

    // 处理两种格式：
    // 1. /C=US/ST=CA/L=SF/O=Test/CN=Test
    // 2. C=US, ST=CA, L=SF, O=Test, CN=Test

    if (subject.startsWith('/')) {
      // 格式1：斜杠分隔
      final parts = subject.split('/').where((s) => s.isNotEmpty);
      for (var part in parts) {
        if (part.contains('=')) {
          final keyValue = part.split('=');
          final key = keyValue[0].trim();
          final value =
              keyValue.length > 1 ? keyValue.sublist(1).join('=').trim() : '';
          result[key] = value;
        }
      }
    } else {
      // 格式2：逗号分隔
      final parts = subject.split(',');
      for (var part in parts) {
        part = part.trim();
        if (part.contains('=')) {
          final keyValue = part.split('=');
          final key = keyValue[0].trim();
          final value =
              keyValue.length > 1 ? keyValue.sublist(1).join('=').trim() : '';
          result[key] = value;
        }
      }
    }

    return result;
  }

  /// 验证证书文件是否有效
  Future<bool> validateCertificate(String certPath) async {
    try {
      await _shell.run('openssl x509 -in "$certPath" -noout');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否为CA证书
  Future<bool> isCACertificate(String certPath) async {
    try {
      final result =
          await _shell.run('openssl x509 -in "$certPath" -noout -text');
      final output = result.first.stdout.toString();

      // 检查是否包含 CA:TRUE
      return output.contains('CA:TRUE') || output.contains('CA:true');
    } catch (e) {
      return false;
    }
  }

  /// 验证证书链
  Future<bool> verifyCertificateChain({
    required String certPath,
    required String caCertPath,
  }) async {
    try {
      await _shell.run('openssl verify -CAfile "$caCertPath" "$certPath"');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 从证书链文件中分离证书
  Future<List<String>> splitCertificateChain(String chainPath) async {
    try {
      final file = File(chainPath);
      final content = await file.readAsString();

      final certificates = <String>[];
      final certPattern = RegExp(
        r'-----BEGIN CERTIFICATE-----(.*?)-----END CERTIFICATE-----',
        multiLine: true,
        dotAll: true,
      );

      final matches = certPattern.allMatches(content);
      for (var match in matches) {
        certificates.add(match.group(0)!);
      }

      return certificates;
    } catch (e) {
      throw Exception('Failed to split certificate chain: $e');
    }
  }

  /// 导入SSL证书（支持证书链）
  Future<Map<String, dynamic>> importSSLCertificateWithChain({
    required String certPath,
    required String outputDir,
    required String baseName,
    String? keyPath,
    String? keyPassword,
    String? chainPath,
  }) async {
    try {
      final Map<String, dynamic> result = {};

      // 直接使用提供的 outputDir，不再创建子目录
      // 确保输出目录存在
      await Directory(outputDir).create(recursive: true);

      // 复制主证书
      final certFile = File(certPath);
      final newCertPath = '$outputDir/$baseName-cert.pem';
      await certFile.copy(newCertPath);
      result['certPath'] = newCertPath;

      // 复制私钥（如果提供）
      if (keyPath != null) {
        final keyFile = File(keyPath);
        final newKeyPath = '$outputDir/$baseName-key.pem';
        await keyFile.copy(newKeyPath);
        result['keyPath'] = newKeyPath;
      }

      // 处理证书链
      if (chainPath != null) {
        final chainFile = File(chainPath);
        final newChainPath = '$outputDir/$baseName-chain.pem';
        await chainFile.copy(newChainPath);
        result['chainPath'] = newChainPath;

        // 分析证书链
        final certs = await splitCertificateChain(chainPath);
        result['chainLength'] = certs.length;
      }

      // 创建完整链文件（证书 + 链）
      if (chainPath != null) {
        final fullChainPath = '$outputDir/$baseName-fullchain.pem';
        final certContent = await File(newCertPath).readAsString();
        final chainContent = await File(chainPath).readAsString();
        await File(fullChainPath).writeAsString('$certContent\n$chainContent');
        result['fullChainPath'] = fullChainPath;
      }

      return result;
    } catch (e) {
      throw Exception('Failed to import SSL certificate: $e');
    }
  }

  /// 获取证书的颁发者信息
  Future<Map<String, String>> getCertificateIssuer(String certPath) async {
    try {
      final result =
          await _shell.run('openssl x509 -in "$certPath" -noout -issuer');
      final issuerLine = result.first.stdout.toString().trim();

      if (issuerLine.startsWith('issuer=')) {
        return _parseSubject(issuerLine.substring(7));
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  /// 验证私钥文件
  Future<bool> validatePrivateKey(String keyPath, {String? password}) async {
    try {
      String command = 'openssl rsa -in "$keyPath" -noout -check';
      if (password != null && password.isNotEmpty) {
        command += ' -passin pass:$password';
      }
      await _shell.run(command);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 验证证书和私钥是否匹配
  Future<bool> verifyCertKeyMatch(String certPath, String keyPath,
      {String? keyPassword}) async {
    try {
      // 获取证书的公钥模数
      final certModulus =
          await _shell.run('openssl x509 -in "$certPath" -noout -modulus');

      // 获取私钥的公钥模数
      String keyCommand = 'openssl rsa -in "$keyPath" -noout -modulus';
      if (keyPassword != null && keyPassword.isNotEmpty) {
        keyCommand += ' -passin pass:$keyPassword';
      }
      final keyModulus = await _shell.run(keyCommand);

      return certModulus.first.stdout == keyModulus.first.stdout;
    } catch (e) {
      return false;
    }
  }

  /// 从PFX文件导入证书
  Future<Map<String, String>> importFromPFX({
    required String pfxPath,
    required String pfxPassword,
    required String outputDir,
    required String baseName,
  }) async {
    try {
      final certPath = '$outputDir/$baseName-cert.pem';
      final keyPath = '$outputDir/$baseName-key.pem';
      final caPath = '$outputDir/$baseName-ca.pem';

      // 提取证书
      await _shell.run(
          'openssl pkcs12 -in "$pfxPath" -clcerts -nokeys -out "$certPath" -passin pass:$pfxPassword -passout pass:');

      // 提取私钥
      await _shell.run(
          'openssl pkcs12 -in "$pfxPath" -nocerts -out "$keyPath" -passin pass:$pfxPassword -passout pass:');

      // 尝试提取CA证书链
      try {
        await _shell.run(
            'openssl pkcs12 -in "$pfxPath" -cacerts -nokeys -out "$caPath" -passin pass:$pfxPassword -passout pass:');
      } catch (e) {
        // CA证书可能不存在，忽略错误
      }

      return {
        'certPath': certPath,
        'keyPath': keyPath,
        'caPath': caPath,
      };
    } catch (e) {
      throw Exception('Failed to import from PFX: $e');
    }
  }

  Future<Certificate> generateCACertificate({
    required String outputPath,
    required String caName,
    required int validityDays,
    required String country,
    required String state,
    required String city,
    required String organization,
    required String organizationalUnit,
    required String commonName,
    String? email,
    bool encrypt = false,
    String? password,
    String? configPath,
    CertificatePurpose? purpose, // 证书用途
    String? customKeyUsage, // 自定义 keyUsage
    String? customExtKeyUsage, // 自定义 extendedKeyUsage
  }) async {
    // 如果启用了类型分类，使用 CA 子目录
    final actualOutputPath =
        outputPath.endsWith('/CA') ? outputPath : '$outputPath/CA';

    // 确保目录存在
    await Directory(actualOutputPath).create(recursive: true);

    final keyPath = '$outputPath/$caName-key.pem';
    final certPath = '$outputPath/$caName-cert.pem';

    // Generate private key
    String keyCommand = 'openssl genrsa -out "$keyPath" 4096';
    if (encrypt && password != null) {
      keyCommand =
          'openssl genrsa -aes256 -passout pass:$password -out "$keyPath" 4096';
    }

    await _shell.run(keyCommand);

    // Generate certificate
    final subject =
        '/C=$country/ST=$state/L=$city/O=$organization/OU=$organizationalUnit/CN=$commonName${email != null ? '/emailAddress=$email' : ''}';

    // 创建临时扩展配置文件
    String? extFile;
    if (purpose != null ||
        customKeyUsage != null ||
        customExtKeyUsage != null) {
      extFile = '$outputPath/$caName-ext.cnf';
      final extContent = _buildExtensionConfig(
        purpose: purpose,
        customKeyUsage: customKeyUsage,
        customExtKeyUsage: customExtKeyUsage,
        isCA: true,
      );
      await File(extFile).writeAsString(extContent);
    }

    String certCommand = configPath != null
        ? 'openssl req -new -x509 -key "$keyPath" -out "$certPath" -days $validityDays -config "$configPath" -subj "$subject"'
        : 'openssl req -new -x509 -key "$keyPath" -out "$certPath" -days $validityDays -subj "$subject"';

    if (encrypt && password != null) {
      certCommand += ' -passin pass:$password';
    }

    // 添加扩展文件
    if (extFile != null) {
      certCommand += ' -extensions v3_ca -extfile "$extFile"';
    }

    await _shell.run(certCommand);

    final now = DateTime.now();

    // 记录用途信息
    final purposes = <String>[];
    if (purpose != null) {
      purposes.add(purpose.id);
    }

    return Certificate(
      id: _uuid.v4(),
      name: caName,
      type: 'CA',
      filePath: certPath,
      issueDate: now,
      expiryDate: now.add(Duration(days: validityDays)),
      isEncrypted: encrypt,
      password: password,
      purposes: purposes, // 添加用途
      details: {
        'keyPath': keyPath,
        'country': country,
        'state': state,
        'city': city,
        'organization': organization,
        'organizationalUnit': organizationalUnit,
        'commonName': commonName,
        if (email != null) 'email': email,
        if (purpose != null) 'purposeName': purpose.name,
        if (customKeyUsage != null) 'customKeyUsage': customKeyUsage,
        if (customExtKeyUsage != null) 'customExtKeyUsage': customExtKeyUsage,
      },
    );
  }

  Future<Certificate> generateSSLCertificate({
    required String outputPath,
    required String certName,
    required String caCertPath,
    required String caKeyPath,
    required int validityDays,
    required String country,
    required String state,
    required String city,
    required String organization,
    required String organizationalUnit,
    required String commonName,
    String? email,
    List<String>? subjectAltNames,
    bool encrypt = false,
    String? password,
    String? caPassword,
    String? configPath,
    CertificatePurpose? purpose,
    String? customKeyUsage,
    String? customExtKeyUsage,
  }) async {
    // 如果启用了类型分类，使用 SSL 子目录
    final actualOutputPath =
        outputPath.endsWith('/SSL') ? outputPath : '$outputPath/SSL';

    // 确保目录存在
    await Directory(actualOutputPath).create(recursive: true);

    final keyPath = '$outputPath/$certName-key.pem';
    final csrPath = '$outputPath/$certName.csr';
    final certPath = '$outputPath/$certName-cert.pem';

    // Generate private key
    String keyCommand = 'openssl genrsa -out "$keyPath" 2048';
    if (encrypt && password != null) {
      keyCommand =
          'openssl genrsa -aes256 -passout pass:$password -out "$keyPath" 2048';
    }

    await _shell.run(keyCommand);

    // Generate CSR
    final subject =
        '/C=$country/ST=$state/L=$city/O=$organization/OU=$organizationalUnit/CN=$commonName${email != null ? '/emailAddress=$email' : ''}';

    String csrCommand = configPath != null
        ? 'openssl req -new -key "$keyPath" -out "$csrPath" -config "$configPath" -subj "$subject"'
        : 'openssl req -new -key "$keyPath" -out "$csrPath" -subj "$subject"';

    if (encrypt && password != null) {
      csrCommand += ' -passin pass:$password';
    }

    await _shell.run(csrCommand);

    // 创建扩展配置
    String? extFile;
    if (purpose != null ||
        customKeyUsage != null ||
        customExtKeyUsage != null ||
        subjectAltNames != null) {
      extFile = '$outputPath/$certName-ext.cnf';
      final extContent = _buildExtensionConfig(
        purpose: purpose,
        customKeyUsage: customKeyUsage,
        customExtKeyUsage: customExtKeyUsage,
        isCA: false,
        subjectAltNames: subjectAltNames,
      );
      await File(extFile).writeAsString(extContent);
    }

    // Sign certificate with CA
    String signCommand =
        'openssl x509 -req -in "$csrPath" -CA "$caCertPath" -CAkey "$caKeyPath" -CAcreateserial -out "$certPath" -days $validityDays';

    if (caPassword != null) {
      signCommand += ' -passin pass:$caPassword';
    }

    if (extFile != null) {
      signCommand += ' -extensions v3_req -extfile "$extFile"';
    }

    // Add SAN if provided
    if (subjectAltNames != null && subjectAltNames.isNotEmpty) {
      final sanFile = '$outputPath/$certName-san.cnf';
      final sanContent =
          'subjectAltName=${subjectAltNames.map((e) => 'DNS:$e').join(',')}';
      await File(sanFile).writeAsString(sanContent);
      signCommand += ' -extfile "$sanFile"';
    }

    await _shell.run(signCommand);

    // 删除临时文件
    if (extFile != null) {
      try {
        await File(extFile).delete();
      } catch (_) {}
    }

    final now = DateTime.now();

    final purposes = <String>[];
    if (purpose != null) {
      purposes.add(purpose.id);
    }

    return Certificate(
      id: _uuid.v4(),
      name: certName,
      type: 'SSL',
      filePath: certPath,
      issueDate: now,
      expiryDate: now.add(Duration(days: validityDays)),
      isEncrypted: encrypt,
      password: password,
      purposes: purposes,
      details: {
        'keyPath': keyPath,
        'csrPath': csrPath,
        'country': country,
        'state': state,
        'city': city,
        'organization': organization,
        'organizationalUnit': organizationalUnit,
        'commonName': commonName,
        if (email != null) 'email': email,
        if (subjectAltNames != null)
          'subjectAltNames': subjectAltNames.join(','),
        if (purpose != null) 'purposeName': purpose.name,
        if (customKeyUsage != null) 'customKeyUsage': customKeyUsage,
        if (customExtKeyUsage != null) 'customExtKeyUsage': customExtKeyUsage,
      },
    );
  }

  Future<void> exportToPFX({
    required String certPath,
    required String keyPath,
    required String pfxPath,
    required String pfxPassword,
    String? keyPassword,
    String? caCertPath,
  }) async {
    String command =
        'openssl pkcs12 -export -out "$pfxPath" -inkey "$keyPath" -in "$certPath" -passout pass:$pfxPassword';

    if (keyPassword != null) {
      command += ' -passin pass:$keyPassword';
    }

    if (caCertPath != null) {
      command += ' -certfile "$caCertPath"';
    }

    await _shell.run(command);
  }

  Future<Map<String, String>> getCertificateInfo(String certPath) async {
    final result =
        await _shell.run('openssl x509 -in "$certPath" -noout -text');
    // Parse the output and extract relevant information
    return {'info': result.first.stdout.toString()};
  }

  /// 构建 OpenSSL 扩展配置内容
  String _buildExtensionConfig({
    CertificatePurpose? purpose,
    String? customKeyUsage,
    String? customExtKeyUsage,
    bool isCA = false,
    List<String>? subjectAltNames,
  }) {
    final buffer = StringBuffer();

    if (isCA) {
      buffer.writeln('[ v3_ca ]');
      buffer.writeln('subjectKeyIdentifier = hash');
      buffer.writeln('authorityKeyIdentifier = keyid:always,issuer');
      buffer.writeln('basicConstraints = critical, CA:true');

      // 使用自定义或预定义的 keyUsage
      if (customKeyUsage != null && customKeyUsage.isNotEmpty) {
        buffer.writeln('keyUsage = $customKeyUsage');
      } else if (purpose != null && purpose.keyUsage.isNotEmpty) {
        buffer.writeln('keyUsage = ${purpose.keyUsage.join(", ")}');
      } else {
        buffer.writeln(
            'keyUsage = critical, digitalSignature, cRLSign, keyCertSign');
      }

      // 扩展密钥用途
      if (customExtKeyUsage != null && customExtKeyUsage.isNotEmpty) {
        buffer.writeln('extendedKeyUsage = $customExtKeyUsage');
      } else if (purpose != null && purpose.extendedKeyUsage.isNotEmpty) {
        buffer.writeln(
            'extendedKeyUsage = ${purpose.extendedKeyUsage.join(", ")}');
      }
    } else {
      buffer.writeln('[ v3_req ]');
      buffer.writeln('subjectKeyIdentifier = hash');
      buffer.writeln('basicConstraints = CA:FALSE');

      // keyUsage
      if (customKeyUsage != null && customKeyUsage.isNotEmpty) {
        buffer.writeln('keyUsage = $customKeyUsage');
      } else if (purpose != null && purpose.keyUsage.isNotEmpty) {
        buffer.writeln('keyUsage = ${purpose.keyUsage.join(", ")}');
      } else {
        buffer
            .writeln('keyUsage = critical, digitalSignature, keyEncipherment');
      }

      // extendedKeyUsage
      if (customExtKeyUsage != null && customExtKeyUsage.isNotEmpty) {
        buffer.writeln('extendedKeyUsage = $customExtKeyUsage');
      } else if (purpose != null && purpose.extendedKeyUsage.isNotEmpty) {
        buffer.writeln(
            'extendedKeyUsage = ${purpose.extendedKeyUsage.join(", ")}');
      } else {
        buffer.writeln('extendedKeyUsage = serverAuth, clientAuth');
      }

      // Subject Alternative Names
      if (subjectAltNames != null && subjectAltNames.isNotEmpty) {
        buffer.writeln(
            'subjectAltName = ${subjectAltNames.map((e) => 'DNS:$e').join(',')}');
      }
    }

    return buffer.toString();
  }
}

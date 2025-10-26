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

  /* Future<Certificate> importSSLCertificate({
    required String name,
    required String certPath,
    required String keyPath,
    String? keyPassword,
    String? chainPath,
    required String destPath,
  }) async {
    // 使用現有的 importSSLCertificateWithChain 方法
    final importResult = await importSSLCertificateWithChain(
      certPath: certPath,
      outputDir: destPath,
      baseName: name,
      keyPath: keyPath,
      keyPassword: keyPassword,
      chainPath: chainPath,
    );

    final finalCertPath = importResult['certPath'] as String;

    // 解析證書信息
    final certInfo = await parseCertificateInfo(finalCertPath);

    // ========== 需要添加 ==========
    // 提取证书详细信息
    final extractedDetails = await extractCertificateDetails(finalCertPath);
    // ========== 添加結束 ==========

    return Certificate(
      id: _uuid.v4(),
      name: name,
      type: 'SSL',
      filePath: finalCertPath,
      issueDate: certInfo['notBefore'] as DateTime,
      expiryDate: certInfo['notAfter'] as DateTime,
      isEncrypted: keyPassword != null,
      password: keyPassword,
      details: {
        if (importResult['keyPath'] != null) 'keyPath': importResult['keyPath'],
        if (importResult['chainPath'] != null)
          'chainPath': importResult['chainPath'],
        if (importResult['fullChainPath'] != null)
          'fullChainPath': importResult['fullChainPath'],
        if (importResult['chainLength'] != null)
          'chainLength': importResult['chainLength'].toString(),
        'imported': 'true',
        ...extractedDetails, // ========== 添加這行 ==========
      },
    );
  }

  Future<Certificate> importPFXCertificate({
    required String pfxPath,
    required String pfxPassword,
    required String destPath,
    required String name,
  }) async {
    // 使用現有的 importFromPFX 方法
    final pfxResult = await importFromPFX(
      pfxPath: pfxPath,
      pfxPassword: pfxPassword,
      outputDir: destPath,
      baseName: name,
    );

    final certPath = pfxResult['certPath']!;

    // 解析證書信息
    final certInfo = await parseCertificateInfo(certPath);

    // 檢查是否為 CA 證書
    final isCA = await isCACertificate(certPath);

    // ========== 需要添加 ==========
    // 提取证书详细信息
    final extractedDetails = await extractCertificateDetails(certPath);
    // ========== 添加結束 ==========

    return Certificate(
      id: _uuid.v4(),
      name: name,
      type: isCA ? 'CA' : 'SSL',
      filePath: certPath,
      issueDate: certInfo['notBefore'] as DateTime,
      expiryDate: certInfo['notAfter'] as DateTime,
      isEncrypted: true,
      password: pfxPassword,
      details: {
        if (pfxResult['keyPath'] != null) 'keyPath': pfxResult['keyPath']!,
        if (pfxResult['caPath'] != null) 'caPath': pfxResult['caPath']!,
        'imported': 'true',
        'importedFrom': pfxPath,
        ...extractedDetails, // ========== 添加這行 ==========
      },
    );
  } */

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
    CertificatePurpose? purpose,
    String? customKeyUsage,
    String? customExtKeyUsage,
  }) async {
    // 如果启用了类型分类，使用 CA 子目录
    final actualOutputPath =
        outputPath.endsWith('/CA') ? outputPath : '$outputPath/CA';

    // 确保目录存在
    await Directory(actualOutputPath).create(recursive: true);

    final keyPath = '$actualOutputPath/$caName-key.pem';
    final certPath = '$actualOutputPath/$caName-cert.pem';

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

    // 創建臨時配置文件（將擴展配置整合到主配置中）
    String? tempConfigFile;
    if (purpose != null ||
        customKeyUsage != null ||
        customExtKeyUsage != null ||
        configPath != null) {
      tempConfigFile = '$actualOutputPath/$caName-temp.cnf';
      final configContent = await _buildCAConfigWithExtensions(
        baseConfigPath: configPath,
        purpose: purpose,
        customKeyUsage: customKeyUsage,
        customExtKeyUsage: customExtKeyUsage,
      );
      await File(tempConfigFile).writeAsString(configContent);
    }

    String certCommand;
    if (tempConfigFile != null) {
      // 使用整合後的配置文件
      certCommand =
          'openssl req -new -x509 -key "$keyPath" -out "$certPath" -days $validityDays -config "$tempConfigFile" -subj "$subject" -extensions v3_ca';
    } else {
      // 使用默認配置
      certCommand =
          'openssl req -new -x509 -key "$keyPath" -out "$certPath" -days $validityDays -subj "$subject"';
    }

    if (encrypt && password != null) {
      certCommand += ' -passin pass:$password';
    }

    await _shell.run(certCommand);

    // 清理臨時文件
    if (tempConfigFile != null) {
      try {
        await File(tempConfigFile).delete();
      } catch (_) {}
    }

    final now = DateTime.now();

    // 记录用途信息
    final purposes = <String>[];
    if (purpose != null) {
      purposes.add(purpose.id);
    }

    // 提取证书详细信息
    final extractedDetails = await extractCertificateDetails(certPath);

    return Certificate(
      id: _uuid.v4(),
      name: caName,
      type: 'CA',
      filePath: certPath,
      issueDate: now,
      expiryDate: now.add(Duration(days: validityDays)),
      isEncrypted: encrypt,
      password: password,
      purposes: purposes,
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
        ...extractedDetails,
      },
    );
  }

  /// 構建包含擴展配置的完整 OpenSSL 配置文件
  Future<String> _buildCAConfigWithExtensions({
    String? baseConfigPath,
    CertificatePurpose? purpose,
    String? customKeyUsage,
    String? customExtKeyUsage,
  }) async {
    final buffer = StringBuffer();

    // 如果提供了基礎配置文件，讀取其內容
    if (baseConfigPath != null && File(baseConfigPath).existsSync()) {
      final baseConfig = await File(baseConfigPath).readAsString();
      buffer.writeln(baseConfig);
      buffer.writeln();
    } else {
      // 使用最小配置
      buffer.writeln('[ req ]');
      buffer.writeln('default_bits = 4096');
      buffer.writeln('prompt = no');
      buffer.writeln('default_md = sha256');
      buffer.writeln('distinguished_name = dn');
      buffer.writeln('x509_extensions = v3_ca');
      buffer.writeln();
      buffer.writeln('[ dn ]');
      buffer.writeln('# Distinguished name will be provided via -subj');
      buffer.writeln();
    }

    // 添加 v3_ca 擴展
    buffer.writeln('[ v3_ca ]');
    buffer.writeln('subjectKeyIdentifier = hash');
    buffer.writeln('authorityKeyIdentifier = keyid:always,issuer');
    buffer.writeln('basicConstraints = critical, CA:true');

    // keyUsage
    if (customKeyUsage != null && customKeyUsage.isNotEmpty) {
      buffer.writeln('keyUsage = $customKeyUsage');
    } else if (purpose != null && purpose.keyUsage.isNotEmpty) {
      buffer.writeln('keyUsage = ${purpose.keyUsage.join(", ")}');
    } else {
      buffer.writeln(
          'keyUsage = critical, digitalSignature, cRLSign, keyCertSign');
    }

    // extendedKeyUsage
    if (customExtKeyUsage != null && customExtKeyUsage.isNotEmpty) {
      buffer.writeln('extendedKeyUsage = $customExtKeyUsage');
    } else if (purpose != null && purpose.extendedKeyUsage.isNotEmpty) {
      buffer
          .writeln('extendedKeyUsage = ${purpose.extendedKeyUsage.join(", ")}');
    }

    return buffer.toString();
  }

  Future<Certificate> generateSSLCertificate({
    required String outputPath,
    required String certName,
    required String caCertPath,
    required String caKeyPath,
    String? caPassword,
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
    String? configPath,
    CertificatePurpose? purpose,
    String? customKeyUsage,
    String? customExtKeyUsage,
  }) async {
    // 使用 SSL 子目錄
    final actualOutputPath =
        outputPath.endsWith('/SSL') ? outputPath : '$outputPath/SSL';

    await Directory(actualOutputPath).create(recursive: true);

    final keyPath = '$actualOutputPath/$certName-key.pem';
    final csrPath = '$actualOutputPath/$certName.csr';
    final certPath = '$actualOutputPath/$certName-cert.pem';

    // 生成私鑰
    String keyCommand = 'openssl genrsa -out "$keyPath" 2048';
    if (encrypt && password != null) {
      keyCommand =
          'openssl genrsa -aes256 -passout pass:$password -out "$keyPath" 2048';
    }

    await _shell.run(keyCommand);

    // 生成 CSR
    final subject =
        '/C=$country/ST=$state/L=$city/O=$organization/OU=$organizationalUnit/CN=$commonName${email != null ? '/emailAddress=$email' : ''}';

    String csrCommand =
        'openssl req -new -key "$keyPath" -out "$csrPath" -subj "$subject"';
    if (encrypt && password != null) {
      csrCommand += ' -passin pass:$password';
    }

    await _shell.run(csrCommand);

    // ========== 修改：創建單一的合併配置文件 ==========
    final combinedExtFile = '$actualOutputPath/$certName-combined-ext.cnf';
    await _createCombinedExtensionConfig(
      outputPath: combinedExtFile,
      purpose: purpose,
      customKeyUsage: customKeyUsage,
      customExtKeyUsage: customExtKeyUsage,
      subjectAltNames: subjectAltNames,
    );

    // 簽發證書
    String certCommand =
        'openssl x509 -req -in "$csrPath" -CA "$caCertPath" -CAkey "$caKeyPath" -CAcreateserial -out "$certPath" -days $validityDays';

    if (caPassword != null && caPassword.isNotEmpty) {
      certCommand += ' -passin pass:$caPassword';
    }

    // 使用合併的配置文件
    certCommand += ' -extensions v3_req -extfile "$combinedExtFile"';

    await _shell.run(certCommand);

    // 清理臨時文件
    try {
      await File(csrPath).delete();
      await File(combinedExtFile).delete();
    } catch (e) {
      debugPrint('清理臨時文件時出錯: $e');
    }

    // 創建證書鏈
    final chainPath = '$actualOutputPath/$certName-chain.pem';
    await File(caCertPath).copy(chainPath);

    final fullChainPath = '$actualOutputPath/$certName-fullchain.pem';
    final certContent = await File(certPath).readAsString();
    final chainContent = await File(chainPath).readAsString();
    await File(fullChainPath).writeAsString('$certContent\n$chainContent');

    final now = DateTime.now();

    // 提取證書詳細信息
    final extractedDetails = await extractCertificateDetails(certPath);

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
        'chainPath': chainPath,
        'fullChainPath': fullChainPath,
        'country': country,
        'state': state,
        'city': city,
        'organization': organization,
        'organizationalUnit': organizationalUnit,
        'commonName': commonName,
        if (email != null) 'email': email,
        if (subjectAltNames != null) 'san': subjectAltNames.join(','),
        if (purpose != null) 'purposeName': purpose.name,
        if (customKeyUsage != null) 'customKeyUsage': customKeyUsage,
        if (customExtKeyUsage != null) 'customExtKeyUsage': customExtKeyUsage,
        ...extractedDetails,
      },
    );
  }

  /// 創建合併的擴展配置文件（包含用途和 SAN）
  Future<void> _createCombinedExtensionConfig({
    required String outputPath,
    CertificatePurpose? purpose,
    String? customKeyUsage,
    String? customExtKeyUsage,
    List<String>? subjectAltNames,
  }) async {
    final buffer = StringBuffer();

    // 添加 v3_req 擴展
    buffer.writeln('[ v3_req ]');
    buffer.writeln('basicConstraints = CA:FALSE');

    // keyUsage
    if (customKeyUsage != null && customKeyUsage.isNotEmpty) {
      buffer.writeln('keyUsage = $customKeyUsage');
    } else if (purpose != null && purpose.keyUsage.isNotEmpty) {
      buffer.writeln('keyUsage = ${purpose.keyUsage.join(", ")}');
    } else {
      buffer.writeln('keyUsage = critical, digitalSignature, keyEncipherment');
    }

    // extendedKeyUsage
    if (customExtKeyUsage != null && customExtKeyUsage.isNotEmpty) {
      buffer.writeln('extendedKeyUsage = $customExtKeyUsage');
    } else if (purpose != null && purpose.extendedKeyUsage.isNotEmpty) {
      buffer
          .writeln('extendedKeyUsage = ${purpose.extendedKeyUsage.join(", ")}');
    } else {
      buffer.writeln('extendedKeyUsage = serverAuth, clientAuth');
    }

    // subjectAltName
    if (subjectAltNames != null && subjectAltNames.isNotEmpty) {
      buffer.writeln('subjectAltName = @alt_names');
      buffer.writeln();
      buffer.writeln('[ alt_names ]');
      for (var i = 0; i < subjectAltNames.length; i++) {
        buffer.writeln('DNS.${i + 1} = ${subjectAltNames[i]}');
      }
    }

    await File(outputPath).writeAsString(buffer.toString());
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

  /// 提取证书详细信息
  Future<Map<String, String>> extractCertificateDetails(String certPath) async {
    final details = <String, String>{};

    try {
      // 提取Subject信息
      final subjectResult = await _shell
          .run('openssl x509 -in "$certPath" -noout -subject -nameopt RFC2253');
      if (subjectResult.isNotEmpty) {
        // ProcessResult 轉換為 String
        final subject = subjectResult.first.stdout.toString().trim();
        if (subject.isNotEmpty) {
          details.addAll(_parseDistinguishedName(subject, isIssuer: false));
        }
      }

      // 提取Issuer信息
      final issuerResult = await _shell
          .run('openssl x509 -in "$certPath" -noout -issuer -nameopt RFC2253');
      if (issuerResult.isNotEmpty) {
        final issuer = issuerResult.first.stdout.toString().trim();
        if (issuer.isNotEmpty) {
          details.addAll(_parseDistinguishedName(issuer, isIssuer: true));
        }
      }

      // 提取序列号
      final serialResult =
          await _shell.run('openssl x509 -in "$certPath" -noout -serial');
      if (serialResult.isNotEmpty) {
        final serialLine = serialResult.first.stdout.toString().trim();
        // 格式: serial=XXXXX
        if (serialLine.contains('=')) {
          details['serial'] = serialLine.split('=').last.trim();
        }
      }

      // 提取日期信息
      final datesResult =
          await _shell.run('openssl x509 -in "$certPath" -noout -dates');
      if (datesResult.isNotEmpty) {
        final datesOutput = datesResult.first.stdout.toString();
        final lines = datesOutput.split('\n');

        for (var line in lines) {
          line = line.trim();
          if (line.contains('notBefore=')) {
            details['notBefore'] = line.split('=').last.trim();
          } else if (line.contains('notAfter=')) {
            details['notAfter'] = line.split('=').last.trim();
          }
        }
      }
    } catch (e) {
      debugPrint('Error extracting certificate details: $e');
    }

    return details;
  }

  /// 解析DN（Distinguished Name）字段
  Map<String, String> _parseDistinguishedName(String dn,
      {required bool isIssuer}) {
    final result = <String, String>{};

    // 移除 "subject=" 或 "issuer=" 前缀
    String cleaned = dn;
    if (dn.toLowerCase().startsWith('subject=')) {
      cleaned = dn.substring(8);
    } else if (dn.toLowerCase().startsWith('issuer=')) {
      cleaned = dn.substring(7);
    }

    cleaned = cleaned.trim();

    // 解析DN字段（格式: CN=xxx,O=yyy,C=zzz 或 /CN=xxx/O=yyy/C=zzz）
    final parts = cleaned.split(RegExp(r'[,/]'));

    for (var part in parts) {
      part = part.trim();
      if (part.isEmpty) continue;

      if (part.contains('=')) {
        final kv = part.split('=');
        if (kv.length >= 2) {
          final key = kv[0].trim();
          final value = kv.sublist(1).join('=').trim(); // 處理值中可能包含 '=' 的情況

          switch (key.toUpperCase()) {
            case 'CN':
              result[isIssuer ? 'issuerCN' : 'commonName'] = value;
              break;
            case 'O':
              result[isIssuer ? 'issuerO' : 'organization'] = value;
              break;
            case 'OU':
              result[isIssuer ? 'issuerOU' : 'organizationalUnit'] = value;
              break;
            case 'C':
              result[isIssuer ? 'issuerC' : 'country'] = value;
              break;
            case 'ST':
              result[isIssuer ? 'issuerST' : 'state'] = value;
              break;
            case 'L':
              result[isIssuer ? 'issuerL' : 'city'] = value;
              break;
            case 'EMAILADDRESS':
            case 'EMAIL':
              result[isIssuer ? 'issuerEmail' : 'email'] = value;
              break;
          }
        }
      }
    }

    return result;
  }
}

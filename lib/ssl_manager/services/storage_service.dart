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
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/certificate.dart';

class StorageService {
  static const String _certificatesKey = 'certificates';

  Future<List<Certificate>> loadCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? certificatesJson = prefs.getString(_certificatesKey);

    if (certificatesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(certificatesJson);
    return decoded.map((json) => Certificate.fromJson(json)).toList();
  }

  Future<void> saveCertificates(List<Certificate> certificates) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      certificates.map((cert) => cert.toJson()).toList(),
    );
    await prefs.setString(_certificatesKey, encoded);
  }

  Future<void> addCertificate(Certificate certificate) async {
    final certificates = await loadCertificates();
    certificates.add(certificate);
    await saveCertificates(certificates);
  }

  Future<void> removeCertificate(String id) async {
    final certificates = await loadCertificates();
    certificates.removeWhere((cert) => cert.id == id);
    await saveCertificates(certificates);
  }

  Future<void> updateCertificate(Certificate certificate) async {
    final certificates = await loadCertificates();
    final index = certificates.indexWhere((cert) => cert.id == certificate.id);
    if (index != -1) {
      certificates[index] = certificate;
      await saveCertificates(certificates);
    }
  }
}

import 'package:flutter/material.dart';
import '../models/certificate.dart';
import '../services/storage_service.dart';
// import '../services/openssl_service.dart';

class CertificateProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  // final OpenSSLService _opensslService = OpenSSLService();

  List<Certificate> _certificates = [];
  bool _isLoading = false;
  String? _error;

  List<Certificate> get certificates => _certificates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Certificate> get caCertificates =>
      _certificates.where((cert) => cert.type == 'CA').toList();

  List<Certificate> get sslCertificates =>
      _certificates.where((cert) => cert.type == 'SSL').toList();

  CertificateProvider() {
    loadCertificates();
  }

  Future<void> loadCertificates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _certificates = await _storageService.loadCertificates();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCertificate(Certificate certificate) async {
    try {
      await _storageService.addCertificate(certificate);
      _certificates.add(certificate);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeCertificate(String id) async {
    try {
      await _storageService.removeCertificate(id);
      _certificates.removeWhere((cert) => cert.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCertificate(Certificate certificate) async {
    try {
      await _storageService.updateCertificate(certificate);
      final index =
          _certificates.indexWhere((cert) => cert.id == certificate.id);
      if (index != -1) {
        _certificates[index] = certificate;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Certificate? getCertificateById(String id) {
    try {
      return _certificates.firstWhere((cert) => cert.id == id);
    } catch (e) {
      return null;
    }
  }
}

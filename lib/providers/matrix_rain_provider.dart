// ============================================================================
// Matrix Rain 特效管理Provider
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

class MatrixRainProvider with ChangeNotifier {
  bool _isEnabled = true;
  bool _enableGlow = true;
  bool _enableScanning = true;
  bool _enableGlitch = true;
  SharedPreferences? _prefs;

  bool get isEnabled => _isEnabled;
  bool get enableGlow => _enableGlow;
  bool get enableScanning => _enableScanning;
  bool get enableGlitch => _enableGlitch;

  MatrixRainProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isEnabled = _prefs?.getBool('matrixRainEnabled') ?? true;
      _enableGlow = _prefs?.getBool('matrixRainGlow') ?? true;
      _enableScanning = _prefs?.getBool('matrixRainScanning') ?? true;
      _enableGlitch = _prefs?.getBool('matrixRainGlitch') ?? true;
      notifyListeners();
      AppLogger.info('Matrix Rain 设置加载成功');
    } catch (e, stackTrace) {
      AppLogger.error('加载 Matrix Rain 设置失败', e, stackTrace);
    }
  }

  Future<void> setMatrixRain(bool enabled) async {
    if (_isEnabled == enabled) return;

    try {
      _isEnabled = enabled;
      await _prefs?.setBool('matrixRainEnabled', _isEnabled);
      notifyListeners();
      AppLogger.info('Matrix Rain: $enabled');
    } catch (e, stackTrace) {
      AppLogger.error('设置 Matrix Rain 失败', e, stackTrace);
    }
  }

  Future<void> setGlow(bool enabled) async {
    if (_enableGlow == enabled) return;

    try {
      _enableGlow = enabled;
      await _prefs?.setBool('matrixRainGlow', _enableGlow);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('设置发光效果失败', e, stackTrace);
    }
  }

  Future<void> setScanning(bool enabled) async {
    if (_enableScanning == enabled) return;

    try {
      _enableScanning = enabled;
      await _prefs?.setBool('matrixRainScanning', _enableScanning);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('设置扫描线失败', e, stackTrace);
    }
  }

  Future<void> setGlitch(bool enabled) async {
    if (_enableGlitch == enabled) return;

    try {
      _enableGlitch = enabled;
      await _prefs?.setBool('matrixRainGlitch', _enableGlitch);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('设置故障效果失败', e, stackTrace);
    }
  }
}

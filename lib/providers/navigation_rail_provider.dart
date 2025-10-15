// ============================================================================
// 导航栏展开/收缩状态管理
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationRailProvider with ChangeNotifier {
  bool _isExtended = true;
  bool _isMobileMenuOpen = false;
  SharedPreferences? _prefs;

  bool get isExtended => _isExtended;
  bool get isMobileMenuOpen => _isMobileMenuOpen;

  NavigationRailProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isExtended = _prefs?.getBool('navigationRailExtended') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('加载导航栏状态失败: $e');
    }
  }

  /// 切换导航栏展开/收缩状态
  Future<void> toggleExtended() async {
    _isExtended = !_isExtended;
    await _prefs?.setBool('navigationRailExtended', _isExtended);
    notifyListeners();
  }

  /// 设置导航栏展开状态
  Future<void> setExtended(bool extended) async {
    if (_isExtended == extended) return;
    _isExtended = extended;
    await _prefs?.setBool('navigationRailExtended', _isExtended);
    notifyListeners();
  }

  /// 切换移动端菜单
  void toggleMobileMenu() {
    _isMobileMenuOpen = !_isMobileMenuOpen;
    notifyListeners();
  }

  /// 关闭移动端菜单
  void closeMobileMenu() {
    if (_isMobileMenuOpen) {
      _isMobileMenuOpen = false;
      notifyListeners();
    }
  }

  /// 打开移动端菜单
  void openMobileMenu() {
    if (!_isMobileMenuOpen) {
      _isMobileMenuOpen = true;
      notifyListeners();
    }
  }
}

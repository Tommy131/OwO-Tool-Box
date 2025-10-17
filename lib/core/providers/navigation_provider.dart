// ============================================================================
// 导航状态管理Provider
// ============================================================================

import 'package:flutter/material.dart';

import '../utils/logger.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  // ✅ 添加 currentIndex getter（保持向后兼容）
  int get selectedIndex => _selectedIndex;
  int get currentIndex => _selectedIndex; // ✅ 新增

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
    AppLogger.debug('导航切换到索引: $index');
  }
}

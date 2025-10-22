// ============================================================================
// 导航状态管理Provider
// ============================================================================

import 'package:flutter/material.dart';

import '../utils/logger.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
    AppLogger.debug('导航切换到索引: $index');
  }
}

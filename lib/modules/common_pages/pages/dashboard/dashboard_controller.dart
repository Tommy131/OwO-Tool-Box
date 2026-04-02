import 'dart:async';

import 'package:flutter/material.dart';

import 'models/dashboard_view_state.dart';
import 'services/dashboard_info_service.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({DashboardInfoService? infoService})
    : _infoService = infoService ?? DashboardInfoService();

  final DashboardInfoService _infoService;

  DashboardViewState _state = DashboardViewState.initial();
  DashboardViewState get state => _state;

  Timer? _memoryTimer;

  Future<void> initialize() async {
    await refresh();
    _startMemoryTimer();
  }

  Future<void> refresh() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final next = await _infoService.loadAll();
      _state = next;
    } catch (e) {
      debugPrint('Error loading device info: $e');
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
  }

  void _startMemoryTimer() {
    _memoryTimer?.cancel();
    _memoryTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_state.isLoading) {
        return;
      }
      final snapshot = _infoService.loadMemorySnapshot();
      if (snapshot.isEmpty) {
        return;
      }
      final nextSystemData = Map<String, dynamic>.from(_state.systemData)
        ..addAll(snapshot);
      _state = _state.copyWith(systemData: nextSystemData);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _memoryTimer?.cancel();
    super.dispose();
  }
}

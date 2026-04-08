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
  bool _disposed = false;

  Future<void> initialize() async {
    await refresh();
    if (_disposed) {
      return;
    }
    _startMemoryTimer();
  }

  Future<void> refresh() async {
    if (_disposed) {
      return;
    }
    _state = _state.copyWith(isLoading: true);
    _notifySafely();

    try {
      final next = await _infoService.loadAll();
      if (_disposed) {
        return;
      }
      _state = next;
    } catch (e) {
      if (_disposed) {
        return;
      }
      debugPrint('Error loading device info: $e');
      _state = _state.copyWith(isLoading: false);
    }
    _notifySafely();
  }

  void _startMemoryTimer() {
    _memoryTimer?.cancel();
    _memoryTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_disposed) {
        return;
      }
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
      _notifySafely();
    });
  }

  void _notifySafely() {
    if (_disposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _memoryTimer?.cancel();
    super.dispose();
  }
}

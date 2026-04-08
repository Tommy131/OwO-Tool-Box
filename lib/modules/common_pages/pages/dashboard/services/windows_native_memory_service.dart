import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WindowsNativeMemoryService {
  Map<String, int> loadMemory() {
    final status = calloc<MEMORYSTATUSEX>();
    try {
      status.ref.dwLength = sizeOf<MEMORYSTATUSEX>();
      final ok = GlobalMemoryStatusEx(status);
      if (ok == 0) {
        return const {};
      }

      final total = status.ref.ullTotalPhys;
      final free = status.ref.ullAvailPhys;
      if (total <= 0 || free < 0) {
        return const {};
      }

      return {'totalBytes': total, 'freeBytes': free > total ? total : free};
    } catch (_) {
      return const {};
    } finally {
      calloc.free(status);
    }
  }
}

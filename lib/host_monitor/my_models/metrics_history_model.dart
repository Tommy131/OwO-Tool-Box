/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-12 20:54:35
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-13 15:43:36
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
class MetricsHistoryModel {
  final List<MetricPoint> cpuHistory;
  final List<MetricPoint> memoryHistory;
  final List<MetricPoint> diskHistory;
  final List<MetricPoint> uploadHistory;
  final List<MetricPoint> downloadHistory;
  final List<MetricPoint> load1History; // 1分钟负载
  final List<MetricPoint> load5History; // 5分钟负载
  final List<MetricPoint> load15History; // 15分钟负载
  final int maxDataPoints;

  MetricsHistoryModel({
    List<MetricPoint>? cpuHistory,
    List<MetricPoint>? memoryHistory,
    List<MetricPoint>? diskHistory,
    List<MetricPoint>? uploadHistory,
    List<MetricPoint>? downloadHistory,
    List<MetricPoint>? load1History,
    List<MetricPoint>? load5History,
    List<MetricPoint>? load15History,
    this.maxDataPoints = 60,
  })  : cpuHistory = cpuHistory ?? [],
        memoryHistory = memoryHistory ?? [],
        diskHistory = diskHistory ?? [],
        uploadHistory = uploadHistory ?? [],
        downloadHistory = downloadHistory ?? [],
        load1History = load1History ?? [],
        load5History = load5History ?? [],
        load15History = load15History ?? [];

  void addDataPoint(
    double cpu,
    double memory,
    double disk,
    double upload, // KB/s
    double download, // KB/s
    double load1,
    double load5,
    double load15,
  ) {
    final now = DateTime.now();

    cpuHistory.add(MetricPoint(timestamp: now, value: cpu));
    memoryHistory.add(MetricPoint(timestamp: now, value: memory));
    diskHistory.add(MetricPoint(timestamp: now, value: disk));
    uploadHistory.add(MetricPoint(timestamp: now, value: upload));
    downloadHistory.add(MetricPoint(timestamp: now, value: download));
    load1History.add(MetricPoint(timestamp: now, value: load1));
    load5History.add(MetricPoint(timestamp: now, value: load5));
    load15History.add(MetricPoint(timestamp: now, value: load15));

    if (cpuHistory.length > maxDataPoints) cpuHistory.removeAt(0);
    if (memoryHistory.length > maxDataPoints) memoryHistory.removeAt(0);
    if (diskHistory.length > maxDataPoints) diskHistory.removeAt(0);
    if (uploadHistory.length > maxDataPoints) uploadHistory.removeAt(0);
    if (downloadHistory.length > maxDataPoints) downloadHistory.removeAt(0);
    if (load1History.length > maxDataPoints) load1History.removeAt(0);
    if (load5History.length > maxDataPoints) load5History.removeAt(0);
    if (load15History.length > maxDataPoints) load15History.removeAt(0);
  }

  void clear() {
    cpuHistory.clear();
    memoryHistory.clear();
    diskHistory.clear();
    uploadHistory.clear();
    downloadHistory.clear();
    load1History.clear();
    load5History.clear();
    load15History.clear();
  }
}

class MetricPoint {
  final DateTime timestamp;
  final double value;

  MetricPoint({
    required this.timestamp,
    required this.value,
  });
}

/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-25 21:40:00
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2026-01-25 21:40:00
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

/// 定时关机任务状态
enum ShutdownTaskStatus {
  idle, // 空闲
  scheduled, // 已计划
  executing, // 执行中
  cancelled, // 已取消
  completed, // 已完成
  failed, // 失败
}

/// 定时关机任务模型
class ShutdownTask {
  final String id;
  final DateTime? scheduledTime;
  final int? delaySeconds;
  final ShutdownTaskStatus status;
  final String? errorMessage;
  final DateTime createdAt;

  ShutdownTask({
    required this.id,
    this.scheduledTime,
    this.delaySeconds,
    required this.status,
    this.errorMessage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 创建一个新的任务
  factory ShutdownTask.create({DateTime? scheduledTime, int? delaySeconds}) {
    return ShutdownTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scheduledTime: scheduledTime,
      delaySeconds: delaySeconds,
      status: ShutdownTaskStatus.idle,
    );
  }

  /// 复制并更新任务
  ShutdownTask copyWith({
    String? id,
    DateTime? scheduledTime,
    int? delaySeconds,
    ShutdownTaskStatus? status,
    String? errorMessage,
    DateTime? createdAt,
  }) {
    return ShutdownTask(
      id: id ?? this.id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'delaySeconds': delaySeconds,
      'status': status.name,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 从 JSON 创建
  factory ShutdownTask.fromJson(Map<String, dynamic> json) {
    return ShutdownTask(
      id: json['id'] as String,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'] as String)
          : null,
      delaySeconds: json['delaySeconds'] as int?,
      status: ShutdownTaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ShutdownTaskStatus.idle,
      ),
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 获取剩余时间（秒）
  int? getRemainingSeconds() {
    if (delaySeconds != null) {
      final elapsed = DateTime.now().difference(createdAt).inSeconds;
      final remaining = delaySeconds! - elapsed;
      return remaining > 0 ? remaining : 0;
    }
    if (scheduledTime != null) {
      final remaining = scheduledTime!.difference(DateTime.now()).inSeconds;
      return remaining > 0 ? remaining : 0;
    }
    return null;
  }

  /// 是否已过期
  bool get isExpired {
    final remaining = getRemainingSeconds();
    return remaining != null && remaining <= 0;
  }

  @override
  String toString() {
    return 'ShutdownTask(id: $id, status: $status, delaySeconds: $delaySeconds, scheduledTime: $scheduledTime)';
  }
}

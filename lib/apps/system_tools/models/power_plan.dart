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
 * @GitHub     : https://github.com/Tommy131
 */

import '../../../core/i18n/localization_keys.dart';

/// 电源模式枚举
enum PowerMode {
  highPerformance, // 高性能
  balanced, // 平衡
  powerSaver, // 节能
}

extension PowerModeExtension on PowerMode {
  /// 获取电源模式的国际化键（名称）- 用于UI翻译
  String get nameKey {
    switch (this) {
      case PowerMode.highPerformance:
        return L18nKeys.highPerformance;
      case PowerMode.balanced:
        return L18nKeys.balanced;
      case PowerMode.powerSaver:
        return L18nKeys.powerSaver;
    }
  }

  /// 获取电源模式的国际化键（描述）- 用于UI翻译
  String get descriptionKey {
    switch (this) {
      case PowerMode.highPerformance:
        return L18nKeys.highPerformanceDesc;
      case PowerMode.balanced:
        return L18nKeys.balancedDesc;
      case PowerMode.powerSaver:
        return L18nKeys.powerSaverDesc;
    }
  }

  /// 获取电源模式的显示名称（英文）- 用于日志和服务层
  String get displayName {
    switch (this) {
      case PowerMode.highPerformance:
        return 'High Performance';
      case PowerMode.balanced:
        return 'Balanced';
      case PowerMode.powerSaver:
        return 'Power Saver';
    }
  }

  /// 获取电源模式的描述（英文）- 用于日志和服务层
  String get description {
    switch (this) {
      case PowerMode.highPerformance:
        return 'Maximum performance, higher energy consumption';
      case PowerMode.balanced:
        return 'Balanced performance and energy efficiency';
      case PowerMode.powerSaver:
        return 'Reduced performance, lower energy consumption';
    }
  }

  /// 获取电源模式的 GUID
  String get guid {
    switch (this) {
      case PowerMode.highPerformance:
        return '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c';
      case PowerMode.balanced:
        return '381b4222-f694-41f0-9685-ff5bb260df2e';
      case PowerMode.powerSaver:
        return 'a1841308-3541-4fab-bc81-f71556f20b4a';
    }
  }
}

/// 电源计划模型
class PowerPlanModel {
  final String guid;
  final String name;
  final String description;
  final bool isActive;
  final PowerMode? mode;

  PowerPlanModel({
    required this.guid,
    required this.name,
    required this.description,
    required this.isActive,
    this.mode,
  });

  /// 复制并更新
  PowerPlanModel copyWith({
    String? guid,
    String? name,
    String? description,
    bool? isActive,
    PowerMode? mode,
  }) {
    return PowerPlanModel(
      guid: guid ?? this.guid,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      mode: mode ?? this.mode,
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'name': name,
      'description': description,
      'isActive': isActive,
      'mode': mode?.name,
    };
  }

  /// 从 JSON 创建
  factory PowerPlanModel.fromJson(Map<String, dynamic> json) {
    return PowerPlanModel(
      guid: json['guid'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool,
      mode: json['mode'] != null
          ? PowerMode.values.firstWhere(
              (e) => e.name == json['mode'],
              orElse: () => PowerMode.balanced,
            )
          : null,
    );
  }

  @override
  String toString() {
    return 'PowerPlanModel(guid: $guid, name: $name, isActive: $isActive, mode: $mode)';
  }
}

/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-22
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// ============================================================================
// 捐赠数据模型
// ============================================================================

class DonationUser {
  final String name;
  final double amount;
  final String? avatar;
  final String? message;
  final DateTime? date;

  const DonationUser({
    required this.name,
    required this.amount,
    this.avatar,
    this.message,
    this.date,
  });

  factory DonationUser.fromJson(Map<String, dynamic> json) {
    return DonationUser(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      avatar: json['avatar'] as String?,
      message: json['message'] as String?,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'avatar': avatar,
      'message': message,
      'date': date?.toIso8601String(),
    };
  }
}

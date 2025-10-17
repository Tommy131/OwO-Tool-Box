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
      date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,
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

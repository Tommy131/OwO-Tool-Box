class Certificate {
  final String id;
  final String name;
  final String type; // 'CA' or 'SSL'
  final String filePath;
  final DateTime issueDate;
  final DateTime expiryDate;
  final bool isEncrypted;
  final String? password;
  final Map<String, String> details;
  final List<String> purposes; // 证书用途列表

  Certificate({
    required this.id,
    required this.name,
    required this.type,
    required this.filePath,
    required this.issueDate,
    required this.expiryDate,
    this.isEncrypted = false,
    this.password,
    this.details = const {},
    this.purposes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'filePath': filePath,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'isEncrypted': isEncrypted,
      'password': password,
      'details': details,
      'purposes': purposes,
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      filePath: json['filePath'],
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      isEncrypted: json['isEncrypted'] ?? false,
      password: json['password'],
      details: Map<String, String>.from(json['details'] ?? {}),
      purposes: List<String>.from(json['purposes'] ?? []),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;
}

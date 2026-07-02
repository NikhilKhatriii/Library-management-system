class FineModel {
  final String id;
  final String userId;
  final String userName;
  final String bookTitle;
  final double amount;
  final String status; // 'paid', 'unpaid'
  final DateTime createdAt;

  FineModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookTitle,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  FineModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? bookTitle,
    double? amount,
    String? status,
    DateTime? createdAt,
  }) {
    return FineModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bookTitle: bookTitle ?? this.bookTitle,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'bookTitle': bookTitle,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FineModel.fromJson(Map<dynamic, dynamic> json) {
    return FineModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      bookTitle: json['bookTitle'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'unpaid',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

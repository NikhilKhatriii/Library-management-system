class TransactionModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String userId;
  final String userName;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final String status; // 'active', 'returned', 'reserved'

  TransactionModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
    required this.userName,
    required this.issueDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
  });

  TransactionModel copyWith({
    String? id,
    String? bookId,
    String? bookTitle,
    String? userId,
    String? userName,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? returnDate,
    String? status,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'userId': userId,
      'userName': userName,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'status': status,
    };
  }

  factory TransactionModel.fromJson(Map<dynamic, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      bookId: json['bookId'] as String? ?? '',
      bookTitle: json['bookTitle'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      returnDate: json['returnDate'] != null ? DateTime.parse(json['returnDate'] as String) : null,
      status: json['status'] as String? ?? 'active',
    );
  }
}

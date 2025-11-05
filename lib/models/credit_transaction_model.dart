class CreditTransactionModel {
  final int? id;
  final int userId;
  final String type; // 'credit' (recarga) ou 'debit' (uso)
  final double amount;
  final String description;
  final String? paymentMethod;
  final String status; // pending, completed, failed
  final String createdAt;

  CreditTransactionModel({
    this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    this.paymentMethod,
    this.status = 'completed',
    required this.createdAt,
  });

  factory CreditTransactionModel.fromMap(Map<String, dynamic> map) {
    return CreditTransactionModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      paymentMethod: map['payment_method'] as String?,
      status: map['status'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'amount': amount,
      'description': description,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt,
    };
  }
}

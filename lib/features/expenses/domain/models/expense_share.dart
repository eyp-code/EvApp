class ExpenseShare {
  const ExpenseShare({required this.personId, required this.amount});

  factory ExpenseShare.fromJson(Map<String, dynamic> json) {
    return ExpenseShare(
      personId: json['personId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  final String personId;
  final double amount;

  Map<String, dynamic> toJson() {
    return {'personId': personId, 'amount': amount};
  }
}

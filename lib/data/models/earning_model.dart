class Earning {
  final String id;
  final String propertyId;
  final String month;
  final int year;
  final double amount;
  final DateTime? createdAt;

  Earning({
    required this.id,
    required this.propertyId,
    required this.month,
    required this.year,
    required this.amount,
    this.createdAt,
  });

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      month: json['month'] as String,
      year: json['year'] as int,
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
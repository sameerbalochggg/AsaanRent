class RentalRecord {
  final String id;
  final String propertyId;
  final String tenantName;
  final DateTime startDate;
  final DateTime? endDate;
  final double monthlyAmount;

  RentalRecord({
    required this.id,
    required this.propertyId,
    required this.tenantName,
    required this.startDate,
    this.endDate,
    required this.monthlyAmount,
  });

  factory RentalRecord.fromJson(Map<String, dynamic> json) {
    return RentalRecord(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      tenantName: json['tenant_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      monthlyAmount: (json['monthly_amount'] as num).toDouble(),
    );
  }
}
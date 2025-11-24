import 'package:flutter/material.dart';

class Report {
  final int id; // Bigint in DB
  final String propertyId; // UUID in DB
  final String? reporterId; // UUID in DB (nullable if user is deleted)
  final String reason;
  final String status; // 'pending', 'reviewed', etc.
  final DateTime? createdAt;

  Report({
    required this.id,
    required this.propertyId,
    this.reporterId,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    try {
      return Report(
        id: json['id'] as int,
        propertyId: json['property_id'] as String,
        reporterId: json['reporter_id'] as String?,
        reason: json['reason'] as String,
        status: json['status'] as String? ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
    } catch (e) {
      debugPrint("Error parsing Report.fromJson: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      // We usually don't send ID or CreatedAt when creating a new report
      'property_id': propertyId,
      'reporter_id': reporterId,
      'reason': reason,
      'status': status,
    };
  }
}
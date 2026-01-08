import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asaan_rent/data/models/notification_model.dart';

final _supabase = Supabase.instance.client;

class NotificationRepository {
  
  /// Fetch notifications for the current user
  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      rethrow;
    }
  }

  /// Mark a specific notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
      rethrow;
    }
  }

  /// Create a notification (Helper for Admin actions later)
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'info',
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
      });
    } catch (e) {
      debugPrint("Error sending notification: $e");
      // We usually don't rethrow here so it doesn't block the main action (like verification)
    }
  }

  // ✅ --- NEW: Helper for Admin Verification ---
  // Call this when Admin verifies a property
  Future<void> sendVerificationNotification(String ownerId, String propertyTitle) async {
    await sendNotification(
      userId: ownerId,
      title: "Property Verified! 🎉",
      body: "Your property '$propertyTitle' has been verified and is now visible to everyone with a trusted badge.",
      type: "success",
    );
  }
}
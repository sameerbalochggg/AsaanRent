import 'package:flutter/material.dart';
import 'package:rent_application/data/models/notification_model.dart';
import 'package:rent_application/data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Get count of unread messages
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _repo.fetchNotifications();
    } catch (e) {
      debugPrint("Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(int id) async {
    // Optimistic update (update UI immediately)
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      // Create updated object logic would go here, 
      // but simpler to just refresh or assume success for now to update badge
      await _repo.markAsRead(id);
      loadNotifications(); // Refresh to get clean state
    }
  }
}
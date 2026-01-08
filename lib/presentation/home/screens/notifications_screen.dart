import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:asaan_rent/presentation/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Notifications", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : provider.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text("No notifications yet", style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: provider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = provider.notifications[index];
                    return Card(
                      color: notification.isRead ? theme.cardColor : theme.primaryColor.withOpacity(0.05),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notification.isRead ? Colors.grey[300] : theme.primaryColor,
                          child: Icon(
                            notification.type == 'alert' ? Icons.warning : Icons.notifications,
                            color: notification.isRead ? Colors.grey : Colors.white,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: GoogleFonts.poppins(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(notification.body),
                        onTap: () {
                          if (!notification.isRead) {
                            provider.markRead(notification.id);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
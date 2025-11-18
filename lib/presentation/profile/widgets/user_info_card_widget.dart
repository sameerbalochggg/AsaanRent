import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/user_profile_model.dart';

class UserInfoCardWidget extends StatelessWidget {
  final UserProfile? profile;
  final String? email;
  final String? createdAt;

  const UserInfoCardWidget({
    super.key,
    required this.profile,
    required this.email,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              Icons.phone_outlined,
              profile?.phone ?? "Not provided",
            ),
            _buildInfoRow(
              context,
              Icons.email_outlined,
              email ?? "Not provided",
            ),
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              profile?.location ?? "Not provided",
            ),
            _buildInfoRow(
              context,
              Icons.calendar_today_outlined,
              "Joined: ${createdAt ?? 'N/A'}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor.withOpacity(0.8), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.textTheme.bodyLarge?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/user_profile_model.dart';
import 'profile_avatar_widget.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfile? profile;
  final File? imageFile;
  final VoidCallback onAvatarTap;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    required this.imageFile,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ProfileAvatarWidget(
          profile: profile,
          imageFile: imageFile,
          onTap: onAvatarTap,
        ),
        const SizedBox(height: 12),
        Text(
          profile?.username ?? "No Name",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          profile?.profession ?? "No Profession",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
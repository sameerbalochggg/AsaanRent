import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/data/models/user_profile_model.dart';
import 'package:asaan_rent/presentation/profile/widgets/profile_avatar_widget.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfile? profile;
  final File? imageFile;
  final Function(File?) onImageSelected; // ✅ Changed from VoidCallback

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    required this.imageFile,
    required this.onImageSelected, // ✅ Changed parameter name
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ✅ Using username from UserProfile model
    final displayName = profile?.username ?? 'User';

    return Column(
      children: [
        // ✅ Updated ProfileAvatarWidget with new callback
        ProfileAvatarWidget(
          profile: profile,
          imageFile: imageFile,
          onImageSelected: onImageSelected, // ✅ Pass the callback
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            profile!.bio!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
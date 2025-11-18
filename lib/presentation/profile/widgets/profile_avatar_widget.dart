import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rent_application/data/models/user_profile_model.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final UserProfile? profile;
  final File? imageFile;
  final VoidCallback onTap;

  const ProfileAvatarWidget({
    super.key,
    required this.profile,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _buildAvatarImage(context),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor,
                border: Border.all(color: theme.cardColor, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(BuildContext context) {
    final theme = Theme.of(context);

    if (imageFile != null) {
      debugPrint('🖼️ Using local file image');
      return Image.file(
        imageFile!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    final avatarUrl = profile?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty && _isValidUrl(avatarUrl)) {
      debugPrint('🌐 Using network image: $avatarUrl');
      return Image.network(
        avatarUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading avatar: $error');
          return _buildPlaceholderAvatar(context);
        },
      );
    }

    debugPrint('📷 No valid avatar URL, using placeholder');
    return _buildPlaceholderAvatar(context);
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Widget _buildPlaceholderAvatar(BuildContext context) {
    return Image.asset(
      'assets/placeholder_avatar.png',
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 100,
          height: 100,
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: 50,
            color: Colors.grey[600],
          ),
        );
      },
    );
  }
}
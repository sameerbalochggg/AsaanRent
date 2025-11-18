import 'package:flutter/material.dart';

const kSecondaryColor = Colors.white;

class EditProfileAvatarWidget extends StatelessWidget {
  final ImageProvider<Object> avatarImage;
  final VoidCallback onTap;

  const EditProfileAvatarWidget({
    super.key,
    required this.avatarImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: avatarImage,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor,
                ),
                child: const Icon(
                  Icons.edit,
                  color: kSecondaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:asaan_rent/data/models/user_profile_model.dart';
import 'package:path_provider/path_provider.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final UserProfile? profile;
  final File? imageFile;
  final Function(File?) onImageSelected;

  const ProfileAvatarWidget({
    super.key,
    required this.profile,
    required this.imageFile,
    required this.onImageSelected,
  });

  // ✅ Pick and crop image using crop_your_image
  Future<void> _pickAndCropImage(BuildContext context) async {
    final theme = Theme.of(context);
    
    try {
      // Step 1: Pick image from gallery
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) return;

      // Step 2: Read image bytes
      final imageBytes = await File(pickedFile.path).readAsBytes();
      
      if (!context.mounted) return;

      // Step 3: Show cropping dialog
      _showCropDialog(context, imageBytes, theme);
      
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCropDialog(BuildContext context, Uint8List imageBytes, ThemeData theme) {
    final cropController = CropController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Bar
            Container(
              color: theme.primaryColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Crop Profile Picture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
            ),
            
            // Crop Widget
            SizedBox(
              height: 400,
              child: Crop(
                image: imageBytes,
                controller: cropController,
                onCropped: (croppedData) async {
                  // ✅ Store mounted state BEFORE closing dialog
                  final mounted = dialogContext.mounted;
                  
                  // Close dialog first
                  if (mounted) {
                    Navigator.pop(dialogContext);
                  }
                  
                  // ✅ Handle CropResult properly
                  if (croppedData is CropSuccess) {
                    await _saveCroppedImage(croppedData.croppedImage);
                  } else if (croppedData is CropFailure) {
                    // ✅ Use the ORIGINAL context, not dialogContext
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to crop image'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                aspectRatio: 1, // Square crop (1:1)
                withCircleUi: true, // Circular crop UI for profile picture
                baseColor: Colors.black,
                maskColor: Colors.black.withOpacity(0.7),
                cornerDotBuilder: (size, edgeAlignment) => const DotControl(
                  color: Colors.white,
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              color: theme.primaryColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => cropController.crop(),
                    icon: const Icon(Icons.check),
                    label: const Text('Crop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Removed context parameter since we don't need it
  Future<void> _saveCroppedImage(Uint8List croppedData) async {
    try {
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/cropped_avatar_$timestamp.jpg');
      await file.writeAsBytes(croppedData);
      
      debugPrint('✅ Cropped image saved: ${file.path}');
      onImageSelected(file);
      
    } catch (e) {
      debugPrint('❌ Error saving cropped image: $e');
      // ✅ No ScaffoldMessenger here - let the caller handle UI feedback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _pickAndCropImage(context),
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
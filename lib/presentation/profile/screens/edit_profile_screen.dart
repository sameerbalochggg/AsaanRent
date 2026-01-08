import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asaan_rent/data/models/user_profile_model.dart';
import 'package:asaan_rent/data/repositories/profile_repository.dart';
import 'package:asaan_rent/data/repositories/storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Widget imports
import 'package:asaan_rent/presentation/profile/widgets/edit_profile_avatar_widget.dart';
import 'package:asaan_rent/presentation/profile/widgets/edit_profile_form_widget.dart';
import 'package:asaan_rent/presentation/profile/widgets/save_button_widget.dart';

// ✅ --- ERROR HANDLER IMPORT ---
import 'package:asaan_rent/core/utils/error_handler.dart';

const kSecondaryColor = Colors.white;

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final File? imageFile;

  const EditProfileScreen({
    super.key,
    required this.profileData,
    this.imageFile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileRepository _profileRepo = ProfileRepository();
  final StorageRepository _storageRepo = StorageRepository();

  late UserProfile _profile;
  late TextEditingController _usernameController;
  late TextEditingController _professionController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _languageController;

  String _email = "";
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final user = Supabase.instance.client.auth.currentUser;
    _email = user?.email ?? "No Email";

    _profile = UserProfile.fromJson({
      'id': widget.profileData['id'] ?? 0,
      'user_id': widget.profileData['user_id'] ?? user?.id,
      'username': widget.profileData['username'],
      'profession': widget.profileData['profession'],
      'phone': widget.profileData['phone'],
      'location': widget.profileData['location'],
      'bio': widget.profileData['bio'],
      'language': widget.profileData['language'],
      'avatar_url': widget.profileData['avatar_url'],
      'created_at': widget.profileData['created_at'],
      'updated_at': widget.profileData['updated_at'],
    });

    _imageFile = widget.imageFile;

    _usernameController = TextEditingController(text: _profile.username);
    _professionController = TextEditingController(text: _profile.profession);
    _phoneController = TextEditingController(text: _profile.phone);
    _locationController = TextEditingController(text: _profile.location);
    _bioController = TextEditingController(text: _profile.bio);
    _languageController = TextEditingController(text: _profile.language);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _professionController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  // ✅ UPDATED: Pick image with error handling
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _profile = _profile.copyWith(avatarUrl: null);
        });
      }
    } catch (error) {
      // ✅ Handle image picker errors
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, error);
      }
    }
  }

  ImageProvider<Object> _buildAvatarImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (_profile.avatarUrl != null && _profile.avatarUrl!.isNotEmpty) {
      return NetworkImage(_profile.avatarUrl!);
    } else {
      return const AssetImage('assets/placeholder_avatar.png');
    }
  }

  // ✅ UPDATED: Save with ErrorHandler
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? finalAvatarUrl = _profile.avatarUrl;

      // Upload image if selected
      if (_imageFile != null) {
        finalAvatarUrl = await _storageRepo.uploadFile(
          _imageFile!,
          'avatars',
        );
      }

      // Update profile data
      final updatedProfile = _profile.copyWith(
        username: _usernameController.text,
        profession: _professionController.text.isEmpty
            ? null
            : _professionController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        location:
            _locationController.text.isEmpty ? null : _locationController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        language:
            _languageController.text.isEmpty ? null : _languageController.text,
        avatarUrl: finalAvatarUrl,
        updatedAt: DateTime.now(),
      );

      await _profileRepo.updateProfile(updatedProfile.toJson());

      if (mounted) {
        // ✅ Use ErrorHandler's success SnackBar
        ErrorHandler.showSuccessSnackBar(context, 'Profile saved successfully!');
        Navigator.pop(context, true);
      }
    } catch (error) {
      // ✅ USE ERROR HANDLER for consistent error display
      ErrorHandler.logError(error); // Log for debugging
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            EditProfileAvatarWidget(
              avatarImage: _buildAvatarImage(),
              onTap: _pickImage,
            ),
            const SizedBox(height: 24),
            EditProfileFormWidget(
              usernameController: _usernameController,
              professionController: _professionController,
              phoneController: _phoneController,
              locationController: _locationController,
              bioController: _bioController,
              languageController: _languageController,
              email: _email,
            ),
            const SizedBox(height: 24),
            SaveButtonWidget(
              isLoading: _isLoading,
              onSave: _onSave,
            ),
          ],
        ),
      ),
    );
  }
}
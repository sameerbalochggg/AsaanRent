import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_application/data/models/user_profile_model.dart';
import 'package:rent_application/data/repositories/profile_repository.dart';
import 'package:rent_application/data/repositories/storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const kPrimaryColor = Color(0xFF004D40);
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
  
  // ✅ --- ADDED EMAIL CONTROLLER ---
  late TextEditingController _emailController; 

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email;

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
      'email': widget.profileData['email'] ?? userEmail, // ✅ Get email
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
    _emailController = TextEditingController(text: _profile.email); // ✅ Init email
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _professionController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _languageController.dispose();
    _emailController.dispose(); // ✅ Dispose email
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _profile = _profile.copyWith(avatarUrl: null); 
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      String? finalAvatarUrl = _profile.avatarUrl;

      if (_imageFile != null) {
        finalAvatarUrl = await _storageRepo.uploadFile(
          _imageFile!,
          'avatars',
        );
      }

      final updatedProfile = _profile.copyWith(
        username: _usernameController.text,
        profession: _professionController.text.isEmpty ? null : _professionController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        language: _languageController.text.isEmpty ? null : _languageController.text,
        email: _emailController.text, // ✅ --- Save email ---
        avatarUrl: finalAvatarUrl,
        updatedAt: DateTime.now(),
      );

      // The toJson() map now includes 'email'
      await _profileRepo.updateProfile(updatedProfile.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: kSecondaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Avatar ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _buildAvatarImage(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kPrimaryColor,
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
            ),
            const SizedBox(height: 24),
            
            // --- Form Fields ---
            _buildTextField(
              controller: _usernameController,
              label: "Username",
              icon: Icons.person_outline,
              validator: (val) => val!.isEmpty ? 'Username cannot be empty' : null,
            ),
            // ✅ --- Added Email Field (Read-Only) ---
            _buildTextField(
              controller: _emailController,
              label: "Email",
              icon: Icons.email_outlined,
              readOnly: true, // User should not edit their email here
            ),
            _buildTextField(
              controller: _professionController,
              label: "Profession (e.g., Real Estate Manager)",
              icon: Icons.work_outline,
            ),
            _buildTextField(
              controller: _phoneController,
              label: "Phone",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              controller: _locationController,
              label: "Location (e.g., Turbat, Balochistan)",
              icon: Icons.location_on_outlined,
            ),
            _buildTextField(
              controller: _bioController,
              label: "Bio",
              icon: Icons.notes_outlined,
              maxLines: 3,
            ),
            _buildTextField(
              controller: _languageController,
              label: "Languages (e.g., English, Balochi)",
              icon: Icons.language_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // --- Save Button ---
            ElevatedButton(
              onPressed: _isLoading ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kSecondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Save Changes",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false, // ✅ Added readOnly
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly, // ✅ Added readOnly
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.grey[50], // ✅ Grey out if readOnly
        ),
      ),
    );
  }
}
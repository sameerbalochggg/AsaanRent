import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart'; 

// ✅ --- REPOSITORY & MODEL IMPORTS ---
import 'package:rent_application/data/models/user_profile_model.dart';
import 'package:rent_application/data/repositories/auth_repository.dart';
import 'package:rent_application/data/repositories/profile_repository.dart';
import 'package:rent_application/presentation/auth/screens/login.dart';


const kPrimaryColor = Color(0xFF004D40);
const kSecondaryColor = Colors.white;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _profileRepo = ProfileRepository();
  final AuthRepository _authRepo = AuthRepository();

  UserProfile? _profile;
  // ❌ --- REMOVED _email, it's now inside _profile ---
  String? _createdAt;
  
  File? _imageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authRepo.getCurrentUser();
      if (user == null) {
        throw Exception("User not logged in");
      }

      final profileData = await _profileRepo.getProfile();

      if (mounted) {
        setState(() {
          _profile = profileData; 
          
          if (profileData != null) {
            final dateToFormat = profileData.createdAt ?? profileData.updatedAt;
            if (dateToFormat != null) {
              _createdAt = DateFormat('MMM yyyy').format(dateToFormat);
            } else {
              _createdAt = null;
            }
          } else {
             _createdAt = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _navigateToEdit();
    }
  }

  void _navigateToEdit() {
    final profileJson = _profile?.toJson() ?? {};
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          profileData: profileJson, 
          imageFile: _imageFile, 
        ),
      ),
    ).then((result) {
      if (result == true) {
        _fetchProfile(); 
      } else {
        setState(() {
          _imageFile = null;
        });
      }
    });
  }

  Future<void> _logout() async {
    try {
      await _authRepo.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: kSecondaryColor,
        centerTitle: true,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _isLoading ? null : _navigateToEdit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _fetchProfile,
                color: kPrimaryColor,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ---------- Header Section ----------
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _buildAvatarImage(),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kPrimaryColor,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: kSecondaryColor,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _profile?.username ?? "No Name",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _profile?.profession ?? "No Profession",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ), 
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---------- User Info Section ----------
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      color: kSecondaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.phone_outlined, _profile?.phone ?? "Not provided"),
                            // ✅ --- FIX: Get email from the profile model ---
                            _buildInfoRow(Icons.email_outlined, _profile?.email ?? "Not provided"),
                            _buildInfoRow(Icons.location_on_outlined, _profile?.location ?? "Not provided"),
                            _buildInfoRow(Icons.calendar_today_outlined,
                                "Joined: ${_createdAt ?? 'N/A'}"),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---------- Quick Actions ----------
                    Text(
                      "Quick Actions",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickActionCard(
                          icon: FontAwesomeIcons.houseUser,
                          label: "My Listings",
                          onTap: () { /* TODO: Navigate */ },
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionCard(
                          icon: FontAwesomeIcons.heart,
                          label: "Favorites",
                          onTap: () { /* TODO: Navigate */ },
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionCard(
                          icon: FontAwesomeIcons.creditCard,
                          label: "Payments",
                          onTap: () { /* TODO: Navigate */ },
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionCard(
                          icon: FontAwesomeIcons.gear,
                          label: "Settings",
                          onTap: () { /* TODO: Navigate */ },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---------- About Section ----------
                    Text(
                      "About",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      color: kSecondaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bio",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: kPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _profile?.bio ?? "No bio available.",
                              style: GoogleFonts.poppins(
                                color: Colors.black87.withOpacity(0.9),
                                height: 1.5,
                              ), 
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Languages",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: kPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _profile?.language ?? "Not specified",
                              style: GoogleFonts.poppins(
                                color: Colors.black87.withOpacity(0.9),
                              ), 
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80), // Space for logout button
                  ],
                ),
              ),
            ),
      // ---------- Logout Button ----------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text("Log Out"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: kSecondaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  ImageProvider<Object> _buildAvatarImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (_profile?.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty) {
      return NetworkImage(_profile!.avatarUrl!);
    } else {
      return const AssetImage('assets/placeholder_avatar.png'); 
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor.withOpacity(0.8), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1.5,
        color: kSecondaryColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(icon, color: kPrimaryColor, size: 20),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black87.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
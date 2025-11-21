import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_application/presentation/profile/screens/edit_profile_screen.dart';

// Repository & Model imports
import 'package:rent_application/data/models/user_profile_model.dart';
import 'package:rent_application/data/repositories/auth_repository.dart';
import 'package:rent_application/data/repositories/profile_repository.dart';
import 'package:rent_application/presentation/auth/screens/login.dart';

// Widget imports
import 'package:rent_application/presentation/profile/widgets/profile_header_widget.dart';
import 'package:rent_application/presentation/profile/widgets/user_info_card_widget.dart';
import 'package:rent_application/presentation/profile/widgets/quick_actions_section_widget.dart';
import 'package:rent_application/presentation/profile/widgets/about_section_widget.dart';
import 'package:rent_application/presentation/profile/widgets/logout_button_widget.dart';

// CustomBottomNavBar import
import 'package:rent_application/presentation/widgets/custom_bottom_nav_bar.dart';

// Screen imports for navigation
import 'package:rent_application/presentation/home/screens/home_screen.dart';
import 'package:rent_application/presentation/home/screens/search_screen.dart';
import 'package:rent_application/presentation/home/screens/favourite_tab_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _profileRepo = ProfileRepository();
  final AuthRepository _authRepo = AuthRepository();

  UserProfile? _profile;
  String? _createdAt;
  String? _email;
  File? _imageFile;
  bool _isLoading = true;

  // Selected index for bottom navigation (Profile is index 3)
  int _selectedIndex = 3;

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

      _email = user.email;
      final profileData = await _profileRepo.getProfile();

      debugPrint('📦 Profile Data Fetched: ${profileData?.toJson()}');
      debugPrint('📸 Avatar URL: ${profileData?.avatarUrl}');

      if (mounted) {
        setState(() {
          _profile = profileData;
          _imageFile = null;

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
      debugPrint('❌ Error fetching profile: $e');
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

  // ✅ NEW: Handle image selection with cropping
  void _handleImageSelected(File? file) {
    if (file != null && mounted) {
      setState(() {
        _imageFile = file;
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

  // Navigation handler for bottom nav bar
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
        
      case 1: // Search
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
        break;
        
      case 2: // Favorites
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesTabScreen()),
        );
        break;
        
      case 3: // Profile - already here
        break;
    }
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _fetchProfile,
                color: theme.primaryColor,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ✅ Updated with new callback
                    ProfileHeaderWidget(
                      profile: _profile,
                      imageFile: _imageFile,
                      onImageSelected: _handleImageSelected,
                    ),
                    const SizedBox(height: 24),
                    UserInfoCardWidget(
                      profile: _profile,
                      email: _email,
                      createdAt: _createdAt,
                    ),
                    const SizedBox(height: 24),
                    QuickActionsSectionWidget(),
                    const SizedBox(height: 24),
                    AboutSectionWidget(profile: _profile),
                    const SizedBox(height: 24),
                    _buildLogoutSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Profile",
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 0.5,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: _isLoading ? null : _navigateToEdit,
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: LogoutButtonWidget(onLogout: _logout),
    );
  }
}
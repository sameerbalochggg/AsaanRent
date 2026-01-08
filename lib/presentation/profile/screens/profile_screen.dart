import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asaan_rent/presentation/profile/screens/edit_profile_screen.dart';

// Repository & Model imports
import 'package:asaan_rent/data/models/user_profile_model.dart';
import 'package:asaan_rent/data/repositories/auth_repository.dart';
import 'package:asaan_rent/data/repositories/profile_repository.dart';
import 'package:asaan_rent/presentation/auth/screens/login.dart';

// Widget imports
import 'package:asaan_rent/presentation/profile/widgets/profile_header_widget.dart';
import 'package:asaan_rent/presentation/profile/widgets/user_info_card_widget.dart';
import 'package:asaan_rent/presentation/profile/widgets/quick_actions_section_widget.dart';
import 'package:asaan_rent/presentation/profile/widgets/about_section_widget.dart';
import 'package:asaan_rent/presentation/profile/widgets/logout_button_widget.dart';

// CustomBottomNavBar import
import 'package:asaan_rent/presentation/widgets/custom_bottom_nav_bar.dart';

// Screen imports for navigation
import 'package:asaan_rent/presentation/home/screens/home_screen.dart';
import 'package:asaan_rent/presentation/home/screens/search_screen.dart';
import 'package:asaan_rent/presentation/home/screens/favourite_tab_screen.dart';

// ✅ --- ERROR HANDLING IMPORTS ---
import 'package:asaan_rent/core/utils/error_handler.dart';
import 'package:asaan_rent/presentation/widgets/error_view.dart';

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
  bool _hasError = false; // ✅ Track error state
  String _errorMessage = ''; // ✅ Store friendly error message

  // Selected index for bottom navigation (Profile is index 3)
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // ✅ UPDATED: Fetch profile with ErrorHandler
  Future<void> _fetchProfile() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
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
          _isLoading = false;
        });
      }
    } catch (error) {
      // ✅ USE ERROR HANDLER to get user-friendly message
      final friendlyMessage = ErrorHandler.getMessage(error);
      ErrorHandler.logError(error); // Log for debugging
      
      debugPrint('❌ Error fetching profile: $error');
      
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = friendlyMessage;
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

  // ✅ UPDATED: Logout with ErrorHandler
  Future<void> _logout() async {
    try {
      await _authRepo.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (error) {
      // ✅ USE ERROR HANDLER for consistent error display
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // ✅ UPDATED: Body with error handling
  Widget _buildBody(ThemeData theme) {
    // Loading State
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
      );
    }

    // ✅ Error State - Using ErrorView widget
    if (_hasError) {
      return ErrorView(
        message: _errorMessage,
        onRetry: _fetchProfile,
      );
    }

    // Success State - Show profile content
    return SafeArea(
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
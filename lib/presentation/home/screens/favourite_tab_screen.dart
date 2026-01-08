import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/data/models/property_model.dart';
import 'package:asaan_rent/data/repositories/property_repository.dart';
import 'package:asaan_rent/data/repositories/profile_repository.dart';

// ✅ --- Import your widgets and other screens ---
import 'package:asaan_rent/presentation/home/widgets/favorite_property_card.dart';
import 'package:asaan_rent/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:asaan_rent/presentation/profile/screens/profile_screen.dart';
import 'package:asaan_rent/presentation/home/screens/search_screen.dart';
import 'package:asaan_rent/presentation/home/screens/home_screen.dart';

// ✅ --- ERROR HANDLING IMPORTS ---
import 'package:asaan_rent/core/utils/error_handler.dart';
import 'package:asaan_rent/presentation/widgets/error_view.dart';


class FavoritesTabScreen extends StatefulWidget {
  const FavoritesTabScreen({super.key});

  @override
  State<FavoritesTabScreen> createState() => _FavoritesTabScreenState();
}

class _FavoritesTabScreenState extends State<FavoritesTabScreen> {
  final PropertyRepository _propertyRepo = PropertyRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  List<Property> _favoritesProperties = [];
  bool _isLoading = true;
  bool _hasError = false; // ✅ Track error state
  String _errorMessage = ''; // ✅ Store friendly error message

  // ✅ --- Favorites is the 3rd item (index 2) ---
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadFavoritesProperties();
  }

  // ✅ --- FIXED Navigation Logic ---
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // ✅ Already on this tab, do nothing
    
    setState(() {
      _selectedIndex = index;
    });

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
        // Already here, do nothing
        break;
      case 3: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  // ✅ UPDATED: Load favorites with ErrorHandler
  Future<void> _loadFavoritesProperties() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final profile = await _profileRepo.getProfile();
      final List<String> favoritesIds = (profile?.favorites ?? []);

      if (favoritesIds.isEmpty) {
        setState(() {
          _favoritesProperties = [];
          _isLoading = false;
        });
        return;
      }

      final propertiesResponse = await _propertyRepo.getPropertiesByIds(favoritesIds);

      if (mounted) {
        setState(() {
          _favoritesProperties = propertiesResponse;
          _isLoading = false;
        });
      }
    } catch (error) {
      // ✅ USE ERROR HANDLER to get user-friendly message
      final friendlyMessage = ErrorHandler.getMessage(error);
      ErrorHandler.logError(error); // Log for debugging
      
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = friendlyMessage;
          _isLoading = false;
        });
      }
    }
  }

  // ✅ UPDATED: Remove from favorites with ErrorHandler
  Future<void> _removeFromFavorites(Property property) async {
    try {
      await _profileRepo.toggleFavorite(property.id);

      setState(() {
        _favoritesProperties.remove(property);
      });

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context, 
          'Removed from favorites',
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
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _buildBody(theme),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // ✅ UPDATED: Body with ErrorView integration
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
        onRetry: _loadFavoritesProperties,
      );
    }

    // Empty State
    if (_favoritesProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: theme.dividerColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No Favorites Yet',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Properties you mark as favorites\nwill appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      );
    }

    // Success State - Show favorites list
    return RefreshIndicator(
      onRefresh: _loadFavoritesProperties,
      color: theme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoritesProperties.length,
        itemBuilder: (context, index) {
          final property = _favoritesProperties[index];
          return FavoritesPropertyCard(
            property: property,
            onRemove: () => _removeFromFavorites(property),
          );
        },
      ),
    );
  }
}
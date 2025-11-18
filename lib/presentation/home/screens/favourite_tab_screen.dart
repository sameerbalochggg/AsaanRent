import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:rent_application/data/repositories/profile_repository.dart';
import 'package:rent_application/core/theme.dart';

// ✅ --- Import your widgets and other screens ---
import 'package:rent_application/presentation/home/widgets/favorite_property_card.dart';
import 'package:rent_application/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:rent_application/presentation/profile/screens/profile_screen.dart';
import 'package:rent_application/presentation/home/screens/search_screen.dart';
import 'package:rent_application/presentation/home/screens/home_screen.dart'; // ✅ Add this import


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
  String? _errorMessage;

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

  Future<void> _loadFavoritesProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _removeFromFavorites(Property property) async {
    try {
      await _profileRepo.toggleFavorite(property.id);

      setState(() {
        _favoritesProperties.remove(property);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text(
              'Error loading favorites',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFavoritesProperties,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

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
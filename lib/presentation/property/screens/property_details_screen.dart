import 'package:flutter/material.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/profile_repository.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';

// --- Import your widgets ---
import 'package:rent_application/presentation/property/widgets/property_details_carousel.dart';
import 'package:rent_application/presentation/property/widgets/property_header_card.dart';
import 'package:rent_application/presentation/property/widgets/property_features_grid.dart';
import 'package:rent_application/presentation/property/widgets/property_info_card.dart';
import 'package:rent_application/presentation/property/widgets/property_map_view.dart';
import 'package:rent_application/presentation/property/widgets/contact_section.dart';
import 'package:rent_application/presentation/property/widgets/property_floating_bar.dart';
import 'package:rent_application/presentation/property/screens/full_screen_image_viewer.dart';


class PropertyDetailsPage extends StatefulWidget {
  final String propertyId; // ✅ This is a String (UUID)

  const PropertyDetailsPage({super.key, required this.propertyId});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final PropertyRepository _propertyRepo = PropertyRepository();
  final ProfileRepository _profileRepo = ProfileRepository();
  final CarouselSliderController _carouselController = CarouselSliderController();

  Property? _property;
  String _ownerName = "Property Owner";
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentIndex = 0;
  bool _isFavorite = false;
  bool _isFavoriteLoading = false; 

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
    _checkIfFavorite(); 
  }

  Future<void> _fetchPropertyDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // ✅ --- This is now String -> Property ---
      final property = await _propertyRepo.fetchPropertyById(widget.propertyId);

      String fetchedOwnerName = "Property Owner";
      if (property.ownerId != null) {
        fetchedOwnerName = await _profileRepo.fetchOwnerName(property.ownerId!);
      }

      if (mounted) {
        setState(() {
          _property = property;
          _ownerName = fetchedOwnerName;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching property: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkIfFavorite() async {
    try {
      final profile = await _profileRepo.getProfile();
      if (profile != null && profile.favorites != null) {
        
        // ✅ --- FIX: This is now String vs String, which is correct ---
        if (mounted) {
          setState(() {
            _isFavorite = profile.favorites!.contains(widget.propertyId);
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      // ✅ --- FIX: Pass the String ID (UUID) ---
      await _profileRepo.toggleFavorite(widget.propertyId);
      
      if (mounted) {
        final newFavoriteState = !_isFavorite;
        setState(() {
          _isFavorite = newFavoriteState;
          _isFavoriteLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Added to favorites ❤️' : 'Removed from favorites',
              style: GoogleFonts.poppins(),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: _isFavorite ? Colors.green : Colors.grey[700],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (mounted) {
        setState(() {
          _isFavoriteLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update favorites. Please try again.',
              style: GoogleFonts.poppins(),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: _isFavoriteLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF004D40),
                        ),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : const Color(0xFF004D40),
                      ),
                title: Text(
                  _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                onTap: _isFavoriteLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                        _toggleFavorite();
                      },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: Color(0xFF004D40)),
                title: Text(
                  'Save Property',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Property saved successfully'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Color(0xFF004D40)),
                title: Text(
                  'Share Property',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share feature coming soon'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullScreenImage(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: _getImages(),
          initialIndex: initialIndex,
          propertyName: _property!.displayName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? _buildLoading()
          : _hasError || _property == null
              ? _buildError()
              : CustomScrollView(
                  slivers: [
                    _buildModernAppBar(),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PropertyHeaderCard(property: _property!),
                            PropertyFeaturesGrid(property: _property!),
                            PropertyInfoCard(property: _property!),
                            if (_property!.latitude != null &&
                                _property!.longitude != null)
                              PropertyMapView(
                                latitude: _property!.latitude!,
                                longitude: _property!.longitude!,
                              ),
                            ContactSection(
                              ownerName: _ownerName,
                              phoneNumber: _property!.phone ?? '',
                              email: _property!.email ?? '',
                            ),
                            const SizedBox(height: 100), // Padding for float bar
                          ],
                        ),
                      ]),
                    ),
                  ],
                ),
      floatingActionButton: !_isLoading && !_hasError && _property != null
          ? const PropertyFloatingBar()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 350.0,
      backgroundColor: const Color(0xFF004D40),
      foregroundColor: Colors.white,
      pinned: true,
      stretch: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showOptionsMenu,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          // ✅ --- FIX: This is now String -> String ---
          tag: _property!.id,
          child: PropertyDetailsCarousel( 
            images: _getImages(),
            currentIndex: _currentIndex,
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() { _currentIndex = index; });
            },
            onImageTap: (index) => _openFullScreenImage(index),
            placeholderImage: _buildPlaceholderImage(),
          ),
        ),
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
      ),
    );
  }


  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF004D40)),
          SizedBox(height: 16),
          Text("Loading property details..."),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Failed to load property details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchPropertyDetails,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getImages() {
    return _property?.images ?? [];
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 80, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
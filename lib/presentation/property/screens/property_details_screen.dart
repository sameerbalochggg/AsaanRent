import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';

// ✅ --- Models & Repositories ---
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/profile_repository.dart';
import 'package:rent_application/data/repositories/property_repository.dart';

// ✅ --- Widgets ---
import 'package:rent_application/presentation/property/widgets/property_details_carousel.dart';
import 'package:rent_application/presentation/property/widgets/property_header_card.dart';
import 'package:rent_application/presentation/property/widgets/property_features_grid.dart';
import 'package:rent_application/presentation/property/widgets/property_info_card.dart';
import 'package:rent_application/presentation/property/widgets/property_map_view.dart';
import 'package:rent_application/presentation/property/widgets/contact_section.dart';

// ✅ --- Screens ---
import 'package:rent_application/presentation/property/screens/full_screen_image_viewer.dart';

// ✅ --- Error Handling ---
import 'package:rent_application/core/utils/error_handler.dart';
import 'package:rent_application/presentation/widgets/error_view.dart';

class PropertyDetailsPage extends StatefulWidget {
  final String propertyId; // UUID

  const PropertyDetailsPage({super.key, required this.propertyId});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final PropertyRepository _propertyRepo = PropertyRepository();
  final ProfileRepository _profileRepo = ProfileRepository();
  
  // Note: CarouselSliderController might vary by package version. 
  // If your version uses CarouselController, change this type.
  final CarouselSliderController _carouselController = CarouselSliderController();

  Property? _property;
  String _ownerName = "Property Owner";
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentIndex = 0;
  bool _isFavorite = false;
  bool _isFavoriteLoading = false; 

  // Key needed for ensuring widget disposal to prevent crashes
  final GlobalKey _carouselKey = GlobalKey(); 

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
    _checkIfFavorite(); 
  }

  Future<void> _fetchPropertyDetails() async {
    // Determine if this is an initial load or a refresh
    final isRefreshing = _property != null;

    // ✅ Only show full screen loading if we don't have data yet.
    if (!isRefreshing) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    try {
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
          _hasError = false; // Clear any previous errors on success
        });
      }
    } catch (e) {
      debugPrint('Error fetching property: $e');
      if (mounted) {
        // ✅ If we have data (refreshing), don't blow up the screen. Show a snackbar instead.
        if (isRefreshing) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to refresh: ${ErrorHandler.getMessage(e)}"),
              backgroundColor: Colors.red,
            ),
          );
          // We don't set _hasError = true here, so the old content stays visible.
        } else {
          // Initial load failed, show the full error view.
          setState(() {
            _hasError = true;
            _errorMessage = ErrorHandler.getMessage(e); 
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _checkIfFavorite() async {
    try {
      final profile = await _profileRepo.getProfile();
      if (profile != null && profile.favorites != null) {
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
        // Use ErrorHandler for snackbar
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  // ✅ Report Dialog Logic
  Future<void> _showReportDialog() async {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Report Property", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Why are you reporting this property?",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: "e.g., Fake listing, Wrong price...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              
              Navigator.pop(context); // Close dialog
              
              try {
                await _propertyRepo.reportProperty(widget.propertyId, reasonController.text);
                
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Report submitted. Thank you."), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // Use ErrorHandler for snackbar
                  ErrorHandler.showErrorSnackBar(context, e);
                }
              }
            },
            child: const Text("Report", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
                      duration: Duration(seconds: 2),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share feature coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: Text(
                  'Report Property',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _showReportDialog(); // Show report dialog
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
    final theme = Theme.of(context);

    // ✅ Use ErrorView ONLY if there's an error AND we don't have data to show
    if (_hasError && _property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Details")),
        body: ErrorView(
          message: _errorMessage ?? "Failed to load property details",
          onRetry: _fetchPropertyDetails,
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading && _property == null
          ? _buildLoading() // Initial loading
          : RefreshIndicator( // ✅ Refresh indicator wraps the scroll view
              onRefresh: _fetchPropertyDetails,
              color: theme.primaryColor, // Use theme primary color (green)
              child: CustomScrollView(
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
                          const SizedBox(height: 24), 
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 350.0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF004D40),
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
        background: KeyedSubtree(
          key: _carouselKey,
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
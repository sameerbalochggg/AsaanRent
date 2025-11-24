import 'package:flutter/material.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/profile_repository.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';

// widgets
import 'package:rent_application/presentation/property/widgets/property_details_carousel.dart';
import 'package:rent_application/presentation/property/widgets/property_header_card.dart';
import 'package:rent_application/presentation/property/widgets/property_features_grid.dart';
import 'package:rent_application/presentation/property/widgets/property_info_card.dart';
import 'package:rent_application/presentation/property/widgets/property_map_view.dart';
import 'package:rent_application/presentation/property/widgets/contact_section.dart';
import 'package:rent_application/presentation/property/screens/full_screen_image_viewer.dart';


class PropertyDetailsPage extends StatefulWidget {
  final String propertyId;

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

  // Cache the images list to prevent rebuilding
  List<String> _cachedImages = [];
  
  // Cache the carousel widget to prevent unnecessary rebuilds
  Widget? _cachedCarousel;

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
    _checkIfFavorite();
  }

  Future<void> _fetchPropertyDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final property = await _propertyRepo.fetchPropertyById(widget.propertyId);

      String fetchedOwnerName = "Property Owner";
      if (property.ownerId != null) {
        fetchedOwnerName = await _profileRepo.fetchOwnerName(property.ownerId!);
      }

      if (!mounted) return;

      setState(() {
        _property = property;
        _ownerName = fetchedOwnerName;
        _cachedImages = property.images ?? [];
        _isLoading = false;
        // Build carousel once when data is loaded
        _cachedCarousel = _buildCarousel();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    try {
      final profile = await _profileRepo.getProfile();
      if (!mounted) return;

      if (profile != null && profile.favorites != null) {
        setState(() {
          _isFavorite = profile.favorites!.contains(widget.propertyId);
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (!mounted) return;
    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      await _profileRepo.toggleFavorite(widget.propertyId);

      if (!mounted) return;

      setState(() {
        _isFavorite = !_isFavorite;
        _isFavoriteLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites ❤️' : 'Removed from favorites',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _isFavorite ? Colors.green : Colors.grey[700],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isFavoriteLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update favorites. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showReportDialog() async {
    if (!mounted) return;

    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          "Report Property",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Why are you reporting this property?",
                style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "e.g., Fake listing, Wrong price...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;

              Navigator.pop(dialogContext);

              try {
                await _propertyRepo.reportProperty(
                  widget.propertyId,
                  reasonController.text.trim(),
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Report submitted successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to report: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Report", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: _isFavoriteLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : const Color(0xFF004D40),
                      ),
                title: Text(
                  _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                  style: GoogleFonts.poppins(),
                ),
                onTap: _isFavoriteLoading
                    ? null
                    : () {
                        Navigator.pop(sheetContext);
                        _toggleFavorite();
                      },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF004D40)),
                title: Text("Share Property", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Share option coming soon")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.red),
                title: Text("Report Property", style: GoogleFonts.poppins(color: Colors.red)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showReportDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          images: _cachedImages,
          initialIndex: index,
          propertyName: _property!.displayName,
        ),
      ),
    );
  }

  // Build carousel widget once and cache it
  Widget _buildCarousel() {
    return RepaintBoundary(
      child: PropertyDetailsCarousel(
        images: _cachedImages,
        currentIndex: _currentIndex,
        controller: _carouselController,
        onPageChanged: (i) {
          if (!mounted) return;
          setState(() => _currentIndex = i);
        },
        onImageTap: (i) => _openFullScreenImage(i),
        placeholderImage: _buildPlaceholderImage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoading()
          : _hasError
              ? _buildError()
              : _property == null
                  ? _buildError()
                  : CustomScrollView(
                      slivers: [
                        _buildModernAppBar(),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            PropertyHeaderCard(property: _property!),
                            PropertyFeaturesGrid(property: _property!),
                            PropertyInfoCard(property: _property!),
                            if (_property!.latitude != null && _property!.longitude != null)
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
                          ]),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      stretch: true,
      leading: _buildCircleButton(
        icon: Icons.arrow_back,
        action: () => Navigator.pop(context),
      ),
      actions: [
        _buildCircleButton(
          icon: Icons.more_vert,
          action: _showOptionsMenu,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: _cachedCarousel ?? _buildPlaceholderImage(),
        ),
        stretchModes: const [
          StretchMode.zoomBackground,
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required Function action}) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () => action(),
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
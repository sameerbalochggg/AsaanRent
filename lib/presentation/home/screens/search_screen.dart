import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:rent_application/presentation/property/screens/property_details_screen.dart';
import 'package:rent_application/presentation/home/widgets/search_result_card.dart';
import 'package:rent_application/presentation/home/screens/home_screen.dart';
import 'package:rent_application/presentation/home/screens/favourite_tab_screen.dart';
import 'package:rent_application/presentation/profile/screens/profile_screen.dart';
import 'package:rent_application/presentation/widgets/custom_bottom_nav_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final PropertyRepository _propertyRepository = PropertyRepository();

  List<Property> _properties = [];
  List<Property> _filteredProperties = [];

  String _searchText = '';
  String? _selectedType;
  String? _selectedLocation;
  final TextEditingController _startPriceController = TextEditingController();
  final TextEditingController _endPriceController = TextEditingController();

  bool _isLoading = true;

  final List<String> _propertyTypes = ['All', 'House', 'Flat', 'Shop', 'Office'];
  final List<String> _locations = ['All', 'Turbat', 'Gwadar', 'Quetta'];

  final int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _selectedType = 'All';
    _selectedLocation = 'All';
    _fetchProperties();
  }

  @override
  void dispose() {
    _startPriceController.dispose();
    _endPriceController.dispose();
    super.dispose();
  }
  
  // ✅ FIXED: Complete navigation logic with Home, Search, Favorites, and Profile
  void _onItemTapped(int index) {
    // If already on the current page, do nothing
    if (index == _selectedIndex) {
      return;
    }

    // Navigate based on the tapped index
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
        
      case 1: // Search (current page)
        // Already on Search page - do nothing
        break;
        
      case 2: // Favorites
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesTabScreen()),
        );
        break;
        
      case 3: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Future<void> _fetchProperties() async {
    try {
      final response = await _propertyRepository.getAllPropertiesForSearch();
      if (mounted) {
        setState(() {
          _properties = response; 
          _applyFilters();
        });
      }
    } catch (error) {
      debugPrint('Error fetching properties: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching properties: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    double? startPrice = double.tryParse(_startPriceController.text);
    double? endPrice = double.tryParse(_endPriceController.text);

    setState(() {
      _filteredProperties = _properties.where((property) {
        final title = property.displayName.toLowerCase();
        final matchesSearch = title.contains(_searchText.toLowerCase());

        final matchesType = _selectedType == 'All' ||
            _selectedType == null ||
            property.propertyType == _selectedType;

        final matchesLocation = _selectedLocation == 'All' ||
            _selectedLocation == null ||
            property.location == _selectedLocation;
            
        final price = property.price ?? 0;
        final matchesPrice = (startPrice == null || price >= startPrice) &&
            (endPrice == null || price <= endPrice || endPrice == 0);

        final isAvailable = property.isRented == false;

        return matchesSearch &&
            matchesType &&
            matchesLocation &&
            matchesPrice &&
            isAvailable; 
      }).toList();
    });
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final fieldBgColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final labelColor = theme.textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'Search Properties',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // ✅ Remove back button since we have bottom nav
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search by type (e.g., house)...',
                prefixIcon: Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: fieldBgColor,
                labelStyle: TextStyle(color: labelColor),
                floatingLabelStyle: TextStyle(color: primaryColor),
                enabledBorder: _buildBorder(borderColor),
                focusedBorder: _buildBorder(primaryColor, width: 2),
              ),
              onChanged: (value) {
                _searchText = value;
                _applyFilters();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: _propertyTypes
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      _selectedType = value;
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      labelText: 'Property Type',
                      filled: true,
                      fillColor: fieldBgColor,
                      labelStyle: TextStyle(color: labelColor),
                      floatingLabelStyle: TextStyle(color: primaryColor),
                      enabledBorder: _buildBorder(borderColor),
                      focusedBorder: _buildBorder(primaryColor, width: 2),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    items: _locations
                        .map((loc) =>
                            DropdownMenuItem(value: loc, child: Text(loc)))
                        .toList(),
                    onChanged: (value) {
                      _selectedLocation = value;
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      labelText: 'Location',
                      filled: true,
                      fillColor: fieldBgColor,
                      labelStyle: TextStyle(color: labelColor),
                      floatingLabelStyle: TextStyle(color: primaryColor),
                      enabledBorder: _buildBorder(borderColor),
                      focusedBorder: _buildBorder(primaryColor, width: 2),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min Price',
                      prefixIcon:
                          Icon(Icons.currency_rupee, color: primaryColor),
                      filled: true,
                      fillColor: fieldBgColor,
                      labelStyle: TextStyle(color: labelColor),
                      floatingLabelStyle: TextStyle(color: primaryColor),
                      enabledBorder: _buildBorder(borderColor),
                      focusedBorder: _buildBorder(primaryColor, width: 2),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _endPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max Price',
                      prefixIcon:
                          Icon(Icons.currency_rupee, color: primaryColor),
                      filled: true,
                      fillColor: fieldBgColor,
                      labelStyle: TextStyle(color: labelColor),
                      floatingLabelStyle: TextStyle(color: primaryColor),
                      enabledBorder: _buildBorder(borderColor),
                      focusedBorder: _buildBorder(primaryColor, width: 2),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor))
                  : _filteredProperties.isEmpty
                      ? Center(
                          child: Text(
                            'No properties found 😕',
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredProperties.length,
                          itemBuilder: (context, index) {
                            final property = _filteredProperties[index];
                            
                            return SearchResultCard(
                              property: property,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyDetailsPage(
                                      propertyId: property.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
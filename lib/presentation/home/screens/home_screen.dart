import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/property_model.dart'; // ✅ Use Model
import 'package:rent_application/presentation/auth/screens/profile_screen.dart';
import 'package:rent_application/presentation/home/screens/search_screen.dart';
import 'package:rent_application/presentation/property/screens/property_details_screen.dart';
import 'package:rent_application/data/repositories/property_repository.dart';

// --- Import your new widgets ---
import 'package:rent_application/presentation/home/widgets/app_drawer.dart';
import 'package:rent_application/presentation/home/widgets/featured_carousel.dart';
import 'package:rent_application/presentation/home/widgets/category_chip.dart';
import 'package:rent_application/presentation/home/widgets/property_card.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PropertyRepository _propertyRepository = PropertyRepository();

  // ✅ --- Using Property Model, not Maps ---
  List<Property> _filteredProperties = [];
  List<Property> _allProperties = [];
  List<Property> _featuredProperties = [];
  bool _isLoading = false;

  int _selectedIndex = 0;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  // ✅ --- REFACTORED to use Property Model ---
  Future<void> _fetchProperties() async {
    if (_allProperties.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // ✅ --- FIX: Corrected the function name from previous error ---
      final propertiesData = await _propertyRepository.fetchAllAvailableProperties();

      if (!mounted) return;
      setState(() {
        _allProperties = propertiesData;
        _filteredProperties = propertiesData;
        _featuredProperties = _allProperties.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching properties: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load properties: $e")),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // ✅ --- REFACTORED to use Property Model ---
  void _filterByCategory(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
        _filteredProperties = _allProperties;
      } else {
        _selectedCategory = category;
        _filteredProperties = _allProperties
            .where((prop) => prop.propertyType == category) // Use model
            .toList();
      }
    });
  }

  // ✅ --- NEW: Navigation helper ---
  Future<void> _navigateToDetails(String propertyId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(
          propertyId: propertyId,
        ),
      ),
    );
    // When we return, refresh the data
    _fetchProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onPropertyAdded: _fetchProperties),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF004D40),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "AsaanRent",
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 245, 244, 247),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: Color.fromARGB(255, 245, 244, 247)),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProperties,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Featured",
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),

                      // ✅ --- REPLACED with new widget ---
                      FeaturedCarousel(
                        featuredProperties: _featuredProperties,
                        onPropertyTap: _navigateToDetails,
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "Categories",
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // ✅ --- REPLACED with new widget ---
                            CategoryChip(
                              title: "House",
                              icon: Icons.home,
                              isSelected: _selectedCategory == "House",
                              onTap: () => _filterByCategory("House"),
                            ),
                            CategoryChip(
                              title: "Flat",
                              icon: Icons.apartment,
                              isSelected: _selectedCategory == "Flat",
                              onTap: () => _filterByCategory("Flat"),
                            ),
                            CategoryChip(
                              title: "Shop",
                              icon: Icons.store,
                              isSelected: _selectedCategory == "Shop",
                              onTap: () => _filterByCategory("Shop"),
                            ),
                            CategoryChip(
                              title: "Office",
                              icon: Icons.business,
                              isSelected: _selectedCategory == "Office",
                              onTap: () => _filterByCategory("Office"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "Recommended",
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),

                      _filteredProperties.isEmpty
                          ? const Center(child: Text("No properties found"))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: _filteredProperties.length,
                              itemBuilder: (context, index) {
                                // ✅ --- Use model ---
                                final property = _filteredProperties[index];

                                return GestureDetector(
                                  onTap: () => _navigateToDetails(property.id),
                                  // ✅ --- REPLACED with new widget ---
                                  child: PropertyCard(property: property),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF004D40),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Favorite"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
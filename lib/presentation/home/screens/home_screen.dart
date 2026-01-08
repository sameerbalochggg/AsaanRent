import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:asaan_rent/data/models/property_model.dart';
import 'package:asaan_rent/presentation/home/screens/favourite_tab_screen.dart';
import 'package:asaan_rent/presentation/providers/property_provider.dart';
import 'package:asaan_rent/presentation/profile/screens/profile_screen.dart';
import 'package:asaan_rent/presentation/home/screens/search_screen.dart';
import 'package:asaan_rent/presentation/property/screens/property_details_screen.dart';

// --- Import your widgets ---
import 'package:asaan_rent/presentation/home/widgets/app_drawer.dart';
import 'package:asaan_rent/presentation/home/widgets/featured_carousel.dart';
import 'package:asaan_rent/presentation/home/widgets/category_chip.dart';
import 'package:asaan_rent/presentation/home/widgets/property_card.dart';
import 'package:asaan_rent/presentation/widgets/custom_bottom_nav_bar.dart';

// ✅ Import Error Widget
import 'package:asaan_rent/presentation/widgets/error_view.dart';

// ✅ Import Notification Provider & Screen
import 'package:asaan_rent/presentation/providers/notification_provider.dart';
import 'package:asaan_rent/presentation/home/screens/notifications_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedCategory;
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    // Fetch properties
    Provider.of<PropertyProvider>(context, listen: false).fetchAvailableProperties();
    // ✅ Fetch notifications
    Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
  }

  void _filterByCategory(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
  }
  
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()))
          .then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesTabScreen()))
          .then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
          .then((_) => setState(() => _selectedIndex = 0));
    }
  }

  Future<void> _navigateToDetails(String propertyId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PropertyDetailsPage(propertyId: propertyId)),
    );
    if (mounted) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyProvider = context.watch<PropertyProvider>();
    // ✅ Listen to NotificationProvider for unread count
    final notificationProvider = context.watch<NotificationProvider>();
    
    final bool isLoading = propertyProvider.isLoading;
    final String? errorMessage = propertyProvider.errorMessage;
    final List<Property> allProperties = propertyProvider.availableProperties;

    // ✅ --- SHOW ERROR VIEW ---
    if (errorMessage != null && allProperties.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("AsaanRent"), 
          centerTitle: true,
          actions: [
            // Keep notifications accessible even in error state
            Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          ],
        ),
        drawer: AppDrawer(onPropertyAdded: _loadData),
        body: ErrorView(
          message: errorMessage,
          onRetry: _loadData,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    }

    final List<Property> filteredProperties = (_selectedCategory == null)
        ? allProperties
        : allProperties.where((prop) => prop.propertyType == _selectedCategory).toList();

    final List<Property> featuredProperties = allProperties.take(3).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppDrawer(onPropertyAdded: _loadData),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("AsaanRent", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          // ✅ UPDATED NOTIFICATION BELL WITH BADGE
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              // Show Red Dot if unread count > 0
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: isLoading && allProperties.isEmpty
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              color: theme.primaryColor,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Featured", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 10),
                      FeaturedCarousel(featuredProperties: featuredProperties, onPropertyTap: _navigateToDetails),
                      const SizedBox(height: 20),
                      Text("Categories", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            CategoryChip(title: "House", icon: Icons.home, isSelected: _selectedCategory == "House", onTap: () => _filterByCategory("House")),
                            CategoryChip(title: "Flat", icon: Icons.apartment, isSelected: _selectedCategory == "Flat", onTap: () => _filterByCategory("Flat")),
                            CategoryChip(title: "Shop", icon: Icons.store, isSelected: _selectedCategory == "Shop", onTap: () => _filterByCategory("Shop")),
                            CategoryChip(title: "Office", icon: Icons.business, isSelected: _selectedCategory == "Office", onTap: () => _filterByCategory("Office")),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text("Recommended", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 10),
                      filteredProperties.isEmpty
                          ? Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(_selectedCategory == null ? "No properties available." : "No properties found for $_selectedCategory", style: GoogleFonts.poppins(color: Colors.grey[600]))))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
                              itemCount: filteredProperties.length,
                              itemBuilder: (context, index) {
                                final property = filteredProperties[index];
                                return GestureDetector(
                                  onTap: () => _navigateToDetails(property.id.toString()),
                                  child: PropertyCard(property: property),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
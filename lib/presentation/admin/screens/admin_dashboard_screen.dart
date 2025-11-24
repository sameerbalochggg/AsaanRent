import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/models/report_model.dart';
import 'package:rent_application/data/repositories/auth_repository.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:rent_application/presentation/auth/screens/login.dart';
import 'package:rent_application/presentation/property/screens/property_details_screen.dart';

// ✅ --- Import Admin Widgets ---
import 'package:rent_application/presentation/admin/widgets/admin_property_card.dart';
import 'package:rent_application/presentation/admin/screens/user_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> 
    with SingleTickerProviderStateMixin 
{
  final PropertyRepository _propertyRepo = PropertyRepository();
  final AuthRepository _authRepo = AuthRepository();
  
  late TabController _tabController;

  List<Property> _allProperties = [];
  List<Property> _filteredProperties = []; // For search results
  List<Report> _allReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      final propertiesFuture = _propertyRepo.fetchAllPropertiesForAdmin();
      final reportsFuture = _propertyRepo.fetchAllReports();

      final results = await Future.wait([propertiesFuture, reportsFuture]);

      if (mounted) {
        setState(() {
          _allProperties = results[0] as List<Property>;
          _filteredProperties = _allProperties; // Initialize filtered list
          _allReports = results[1] as List<Report>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading admin data: $e")),
        );
      }
    }
  }

  void _filterProperties(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProperties = _allProperties;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredProperties = _allProperties.where((property) {
          final title = property.displayName.toLowerCase();
          final location = property.displayLocation.toLowerCase();
          // Safe access to ownerName
          final owner = property.displayOwnerName.toLowerCase();
          
          return title.contains(lowerQuery) || 
                 location.contains(lowerQuery) ||
                 owner.contains(lowerQuery);
        }).toList();
      }
    });
  }

  Future<void> _toggleVerification(Property property) async {
    try {
      final newStatus = !property.isVerified;
      await _propertyRepo.updateVerificationStatus(property.id, newStatus);
      
      if (mounted) {
        setState(() {
          final index = _allProperties.indexWhere((p) => p.id == property.id);
          if (index != -1) {
            final updatedProperty = property.copyWith(isVerified: newStatus);
            _allProperties[index] = updatedProperty;
            
            // Update filtered list as well
            final filteredIndex = _filteredProperties.indexWhere((p) => p.id == property.id);
            if (filteredIndex != -1) {
              _filteredProperties[filteredIndex] = updatedProperty;
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? "Property Verified ✅" : "Property Unverified ❌"),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint("Verification Error: $e");
      if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update status: $e"), backgroundColor: Colors.red),
          );
      }
    }
  }

  Future<void> _deleteProperty(String id) async {
    try {
      await _propertyRepo.deleteProperty(id); 
      
      if (mounted) {
         setState(() {
           _allProperties.removeWhere((p) => p.id == id);
           _filteredProperties.removeWhere((p) => p.id == id);
         });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Property Deleted"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
      if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete: $e"), backgroundColor: Colors.red),
          );
      }
    }
  }
  
  Future<void> _logout() async {
    await _authRepo.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _navigateToDetails(String propertyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(
          propertyId: propertyId,
        ),
      ),
    );
  }

  void _navigateToUserList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserListScreen(),
      ),
    );
  }

  Widget _buildReportsList() {
    final theme = Theme.of(context);
    
    return _allReports.isEmpty
        ? const Center(child: Text("No new reports."))
        : ListView.builder(
            itemCount: _allReports.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final report = _allReports[index];
              return Card(
                color: theme.cardColor,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.flag, color: Colors.red),
                  title: Text(
                    report.reason, 
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color
                    )
                  ),
                  subtitle: Text(
                    "Property ID: ${report.propertyId}",
                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color),
                  onTap: () {
                    _navigateToDetails(report.propertyId);
                  },
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Admin Dashboard", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        actions: [
          // ✅ Users Button
          IconButton(
            onPressed: _navigateToUserList, 
            icon: const Icon(Icons.people),
            tooltip: "View Users",
          ),
          IconButton(
            onPressed: _loadAdminData, 
            icon: const Icon(Icons.refresh)
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: "Properties (${_allProperties.length})"),
            Tab(text: "Reports (${_allReports.length})"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. Properties List with Search
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search by Title, Location, or Owner...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                        ),
                        onChanged: _filterProperties,
                      ),
                    ),
                    
                    Expanded(
                      child: _filteredProperties.isEmpty 
                        ? const Center(child: Text("No properties match your search."))
                        : ListView.builder(
                            itemCount: _filteredProperties.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final property = _filteredProperties[index];
                              return GestureDetector(
                                onTap: () => _navigateToDetails(property.id),
                                child: AdminPropertyCard(
                                  property: property,
                                  onVerifyToggle: () => _toggleVerification(property),
                                  onDelete: () => _deleteProperty(property.id),
                                ),
                              );
                            },
                          ),
                    ),
                  ],
                ),

                // 2. Reports List
                _buildReportsList(),
              ],
            ),
    );
  }
}
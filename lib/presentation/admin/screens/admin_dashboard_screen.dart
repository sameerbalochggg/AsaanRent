import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/auth_repository.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:rent_application/presentation/auth/screens/login.dart';

// ✅ --- Import Admin Widgets ---
import 'package:rent_application/presentation/admin/widgets/admin_property_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final PropertyRepository _propertyRepo = PropertyRepository();
  final AuthRepository _authRepo = AuthRepository();

  List<Property> _allProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      // Use the repository method we created earlier
      final data = await _propertyRepo.fetchAllPropertiesForAdmin();
      if (mounted) {
        setState(() {
          _allProperties = data;
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

  Future<void> _toggleVerification(Property property) async {
    try {
      final newStatus = !property.isVerified;
      // Call repository to update database
      await _propertyRepo.updateVerificationStatus(property.id, newStatus);
      
      // Update local state immediately (Optimistic UI)
      if (mounted) {
        setState(() {
          final index = _allProperties.indexWhere((p) => p.id == property.id);
          if (index != -1) {
            // Create a copy with the new status
            _allProperties[index] = property.copyWith(isVerified: newStatus);
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
      
      // Refresh local list
      if (mounted) {
         setState(() {
           _allProperties.removeWhere((p) => p.id == id);
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
        backgroundColor: Colors.red[800], // Distinct color for Admin
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAdminData, 
            icon: const Icon(Icons.refresh)
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allProperties.isEmpty 
             ? const Center(child: Text("No properties found."))
             : ListView.builder(
              itemCount: _allProperties.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final property = _allProperties[index];
                return AdminPropertyCard(
                  property: property,
                  onVerifyToggle: () => _toggleVerification(property),
                  onDelete: () => _deleteProperty(property.id),
                );
              },
            ),
    );
  }
}
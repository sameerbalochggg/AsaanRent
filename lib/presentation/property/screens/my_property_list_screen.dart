import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:rent_application/presentation/property/widgets/my_property_card.dart';

class MyPropertyListPage extends StatefulWidget {
  const MyPropertyListPage({Key? key}) : super(key: key);

  @override
  State<MyPropertyListPage> createState() => _MyPropertyListPageState();
}

class _MyPropertyListPageState extends State<MyPropertyListPage> {
  final PropertyRepository _repository = PropertyRepository();

  List<Property> properties = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedProperties = await _repository.fetchUserProperties();
      if (mounted) {
        setState(() {
          properties = fetchedProperties;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProperty(int index) async {
    try {
      // ✅ --- FIX: This is now String -> void ---
      await _repository.deleteProperty(properties[index].id);
      
      if (mounted) {
        setState(() {
          properties.removeAt(index);
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Property deleted successfully'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete property: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        // ✅ --- ADDED centerTitle: true ---
        centerTitle: true,
        title: Text(
          "My Properties",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF004D40),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 80, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading properties',
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey[500]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProperties,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : properties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work_outlined,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No properties yet',
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first property to get started',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProperties,
                      color: theme.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          return MyPropertyCard(
                            property: properties[index],
                            onUpdate: (updatedProperty) {
                              setState(() {
                                properties[index] = updatedProperty;
                              });
                            },
                            onDelete: () => _deleteProperty(index),
                          );
                        },
                      ),
                    ),
    );
  }
}
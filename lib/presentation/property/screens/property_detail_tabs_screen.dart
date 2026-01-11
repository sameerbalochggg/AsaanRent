import 'package:flutter/material.dart';
import 'package:asaan_rent/data/models/property_model.dart';
import 'package:asaan_rent/data/repositories/property_repository.dart';
import 'package:asaan_rent/presentation/property/widgets/edit_property_tab.dart';
import 'package:asaan_rent/core/theme.dart';
import 'package:asaan_rent/presentation/widgets/success_dialog.dart'; // ✅ Import success dialog

class PropertyDetailTabsScreen extends StatefulWidget {
  final String propertyId; // Receives a String (UUID)
  final Function(Property) onUpdate;
  final VoidCallback onDelete;

  const PropertyDetailTabsScreen({
    Key? key,
    required this.propertyId,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<PropertyDetailTabsScreen> createState() =>
      _PropertyDetailTabsScreenState();
}

class _PropertyDetailTabsScreenState extends State<PropertyDetailTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PropertyRepository _repository = PropertyRepository();

  Property? _currentProperty;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadPropertyDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPropertyDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final property = await _repository.fetchPropertyById(widget.propertyId);
      
      if (mounted) {
        setState(() {
          _currentProperty = property;
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

  // Toggle rental status with success dialog
  Future<void> _toggleRentalStatus() async {
    if (_currentProperty == null) return;

    try {
      final newStatus = !_currentProperty!.isRented;

      await _repository.toggleRentalStatus(_currentProperty!.id, newStatus);

      if (mounted) {
        setState(() {
          _currentProperty = _currentProperty!.copyWith(isRented: newStatus);
        });
      }

      widget.onUpdate(_currentProperty!);

      if (mounted) {
        SuccessDialog.show(
          context: context,
          message: newStatus
              ? 'Property marked as rented'
              : 'Property marked as available',
          primaryColor: Theme.of(context).primaryColor,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  // ✅ UPDATED: Delete Property with Success Dialog
  Future<void> _onDeleteProperty() async {
    Navigator.pop(context); // 1. Close the "Are you sure?" dialog
    
    try {
      // 2. Perform delete operation
      await _repository.deleteProperty(_currentProperty!.id);
      widget.onDelete();
      
      if (mounted) {
        // 3. Show Success Dialog
        SuccessDialog.show(
          context: context,
          title: "Deleted",
          message: "Property deleted successfully.",
          primaryColor: Colors.red, // Red to indicate destructive success
          autoCloseDuration: const Duration(seconds: 2),
        );

        // 4. Wait for dialog to display briefly, then pop the screen
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context, true); // Pop the edit screen
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
      );
    }

    if (errorMessage != null || _currentProperty == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to load property',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPropertyDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_currentProperty!.displayName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Property'),
                  content: const Text(
                      'Are you sure you want to delete this property?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: _onDeleteProperty, 
                      child: const Text('Delete',
                          style: TextStyle(color: kDestructiveColor)), 
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Edit'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mark as Rented/Available Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor, 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _toggleRentalStatus,
              icon: Icon(
                _currentProperty!.isRented
                    ? Icons.check_circle
                    : Icons.home_work,
                size: 24,
              ),
              label: Text(
                _currentProperty!.isRented
                    ? 'Mark as Available'
                    : 'Mark as Rented',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentProperty!.isRented
                    ? Colors.green[600]
                    : Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Status Indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: _currentProperty!.isRented
                ? Colors.orange[50]
                : Colors.green[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _currentProperty!.isRented ? Icons.person : Icons.key,
                  color: _currentProperty!.isRented
                      ? Colors.orange[900]
                      : Colors.green[900],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Status: ${_currentProperty!.isRented ? "RENTED" : "AVAILABLE"}',
                  style: TextStyle(
                    color: _currentProperty!.isRented
                        ? Colors.orange[900]
                        : Colors.green[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Edit Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                EditPropertyTab(
                  property: _currentProperty!,
                  primaryColor: theme.primaryColor,
                  onSave: (updatedProperty) async {
                    try {
                      await _repository.updateProperty(updatedProperty);
                      if (mounted) {
                        setState(() {
                          _currentProperty = updatedProperty;
                        });
                      }
                      widget.onUpdate(updatedProperty);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
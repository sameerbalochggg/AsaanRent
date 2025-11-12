import 'package:flutter/material.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:rent_application/presentation/property/widgets/edit_property_tab.dart';

class PropertyDetailTabsScreen extends StatefulWidget {
  final String propertyId;
  final Color primaryColor;
  final Function(Property) onUpdate;
  final VoidCallback onDelete;

  const PropertyDetailTabsScreen({
    Key? key,
    required this.propertyId,
    required this.primaryColor,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? 'Property marked as RENTED'
                  : 'Property marked as AVAILABLE',
            ),
            backgroundColor: widget.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Loading...', style: TextStyle(color: Colors.white)),
          backgroundColor: widget.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: CircularProgressIndicator(color: widget.primaryColor),
        ),
      );
    }

    if (errorMessage != null || _currentProperty == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Error', style: TextStyle(color: Colors.white)),
          backgroundColor: widget.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
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
                  backgroundColor: widget.primaryColor,
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_currentProperty!.displayName,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: widget.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
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
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await _repository
                              .deleteProperty(_currentProperty!.id);
                          widget.onDelete();
                          if (mounted) {
                            Navigator.pop(context);
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
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                EditPropertyTab(
                  property: _currentProperty!,
                  primaryColor: widget.primaryColor,
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
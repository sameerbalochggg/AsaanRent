import 'package:flutter/material.dart';
import 'package:rent_application/data/models/property_model.dart';

class EditPropertyTab extends StatefulWidget {
  final Property property;
  final Color primaryColor;
  final Function(Property) onSave;

  const EditPropertyTab({
    Key? key,
    required this.property,
    required this.primaryColor,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditPropertyTab> createState() => _EditPropertyTabState();
}

class _EditPropertyTabState extends State<EditPropertyTab> {
  late TextEditingController _propertyTypeController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _propertyTypeController =
        TextEditingController(text: widget.property.propertyType ?? '');
    _locationController =
        TextEditingController(text: widget.property.location ?? '');
    _priceController =
        TextEditingController(text: widget.property.price?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.property.description ?? '');
  }

  @override
  void dispose() {
    _propertyTypeController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_propertyTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property type cannot be empty')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final updatedProperty = widget.property.copyWith(
      propertyType: _propertyTypeController.text,
      location: _locationController.text,
      price: price,
      description: _descriptionController.text,
    );

    await widget.onSave(updatedProperty);

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Property updated successfully'),
          backgroundColor: widget.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Property Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _propertyTypeController,
            decoration: InputDecoration(
              labelText: 'Property Type (e.g., House, Shop)',
              labelStyle: TextStyle(color: widget.primaryColor),
              prefixIcon: Icon(Icons.home_work, color: widget.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              labelStyle: TextStyle(color: widget.primaryColor),
              prefixIcon: Icon(Icons.location_on, color: widget.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monthly Price',
              labelStyle: TextStyle(color: widget.primaryColor),
              prefixIcon: Icon(Icons.attach_money, color: widget.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: widget.primaryColor),
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Icon(Icons.description, color: widget.primaryColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
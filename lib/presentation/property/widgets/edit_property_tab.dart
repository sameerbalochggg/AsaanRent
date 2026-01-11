import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asaan_rent/data/models/property_model.dart';

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
  late TextEditingController _phoneController; // ✅ Added phone controller
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
    // ✅ Initialize phone controller with existing phone number
    _phoneController =
        TextEditingController(text: widget.property.phone ?? '');
    _descriptionController =
        TextEditingController(text: widget.property.description ?? '');
  }

  @override
  void dispose() {
    _propertyTypeController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _phoneController.dispose(); // ✅ Dispose phone controller
    _descriptionController.dispose();
    super.dispose();
  }

  // ✅ Show success dialog with animated checkmark
  void _showSuccessDialog({String message = 'Property updated successfully'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Auto-close after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Animated checkmark with green background
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Validate phone number format
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any spaces or dashes
    final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it's a valid Pakistani phone number (11 digits starting with 0)
    // or international format (10-15 digits)
    if (cleanPhone.length < 10 || cleanPhone.length > 15) {
      return 'Phone number must be 10-15 digits';
    }
    
    // Check if it contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      return 'Phone number must contain only digits';
    }
    
    return null;
  }

  Future<void> _saveChanges() async {
    // ✅ Validate property type
    if (_propertyTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property type cannot be empty'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ✅ Validate price
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ✅ Validate phone number
    final phoneError = _validatePhone(_phoneController.text);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    // ✅ Include phone number in updated property
    final updatedProperty = widget.property.copyWith(
      propertyType: _propertyTypeController.text,
      location: _locationController.text,
      price: price,
      phone: _phoneController.text.trim(), // ✅ Add phone number
      description: _descriptionController.text,
    );

    await widget.onSave(updatedProperty);

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }

    if (mounted) {
      _showSuccessDialog();
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
          
          // Property Type Field
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
          
          // Location Field
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
          
          // Price Field
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
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
          
          // ✅ Phone Number Field (NEW)
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            decoration: InputDecoration(
              labelText: 'Contact Phone Number',
              labelStyle: TextStyle(color: widget.primaryColor),
              prefixIcon: Icon(Icons.phone, color: widget.primaryColor),
              hintText: '03001234567',
              helperText: 'Owner contact number (10-15 digits)',
              helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
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
          
          // Description Field
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
          
          // Save Button
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
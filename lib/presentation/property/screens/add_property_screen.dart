import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:rent_application/data/repositories/storage_repository.dart';
import 'package:rent_application/presentation/property/screens/map_screen.dart';
import 'package:rent_application/presentation/property/widgets/add_property/section_header_widget.dart';
import 'package:rent_application/presentation/property/widgets/add_property/property_type_dropdown.dart';
import 'package:rent_application/presentation/property/widgets/add_property/location_fields_widget.dart';
import 'package:rent_application/presentation/property/widgets/add_property/map_selector_widget.dart';
import 'package:rent_application/presentation/property/widgets/add_property/price_field_widget.dart';
import 'package:rent_application/presentation/property/widgets/add_property/residential_fields_widget.dart';
import 'package:rent_application/presentation/property/widgets/add_property/description_field_widget.dart';
import 'package:rent_application/presentation/property/widgets/add_property/contact_fields_widget.dart';
import 'package:rent_application/presentation/property/widgets/add_property/image_picker_widget.dart';
import 'package:rent_application/presentation/property/widgets/add_property/submit_button_widget.dart';
import 'package:rent_application/core/utils/image_compressor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyRepository _propertyRepo = PropertyRepository();
  final StorageRepository _storageRepo = StorageRepository();

  // Controllers
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // State variables
  double? _latitude;
  double? _longitude;
  String? _selectedLocationName;
  String? bedrooms;
  String? bathrooms;
  String? propertyType;
  String _selectedCountryCode = "+92";

  final Map<String, bool> facilities = {
    "kitchen": false,
    "parking": false,
    "furnished": false,
    "electricity": false,
    "water": false,
    "gas": false,
    "ac": false,
    "balcony": false,
    "garden": false,
  };

  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _showResidentialFields {
    return propertyType == "House" ||
        propertyType == "Flat" ||
        propertyType == "Apartment";
  }

  void _fetchUserEmail() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.email != null) {
      setState(() {
        _emailController.text = user.email!;
      });
    }
  }

  Future<void> _pickImages() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final selected = await _picker.pickMultiImage();
      if (selected.isNotEmpty && mounted) {
        setState(() {
          _images.addAll(selected);
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    } finally {
      _isPicking = false;
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _pickLocationFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _latitude = result["latitude"] as double?;
        _longitude = result["longitude"] as double?;
        _selectedLocationName =
            result["address"] as String? ?? "Location Selected";
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      _showSnackBar("📷 Please upload at least one image", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User not authenticated. Please login first.");
      }

      final imageUrls = await Future.wait(
        _images.map((img) async {
          final compressedFile = await ImageCompressor.compressImage(img);
          return _storageRepo.uploadFile(compressedFile, 'property-images');
        }),
      );

      final fullPhone = "$_selectedCountryCode${_phoneController.text}";

      final Map<String, dynamic> propertyData = {
        "owner_id": userId,
        "is_rented": false,
        "property_type": propertyType,
        "location": _locationController.text,
        "price": double.tryParse(_priceController.text) ?? 0,
        "description": _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        "phone": fullPhone,
        "email": _emailController.text,
        "images": imageUrls,
        "latitude": _latitude,
        "longitude": _longitude,
      };

      if (_showResidentialFields) {
        int? bedroomsInt = int.tryParse(bedrooms ?? '');
        if (bedrooms == "5+") bedroomsInt = 5;
        int? bathroomsInt = int.tryParse(bathrooms ?? '');
        if (bathrooms == "5+") bathroomsInt = 5;

        propertyData.addAll({
          "area": _areaController.text,
          "bedrooms": bedroomsInt,
          "bathrooms": bathroomsInt,
          ...facilities,
        });
      }

      await _propertyRepo.addProperty(propertyData);

      if (!mounted) return;
      _showSnackBar("✅ Property added successfully!");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("⚠️ Error: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Add New Property",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF004D40),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeaderWidget(
                  title: "Property Type",
                  icon: Icons.home_work,
                ),
                const SizedBox(height: 12),
                PropertyTypeDropdown(
                  value: propertyType,
                  onChanged: (val) {
                    setState(() {
                      propertyType = val;
                      if (!_showResidentialFields) {
                        bedrooms = null;
                        bathrooms = null;
                        _areaController.clear();
                        facilities.updateAll((key, value) => false);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
                const SectionHeaderWidget(
                  title: "Location",
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 12),
                LocationFieldsWidget(controller: _locationController),
                const SizedBox(height: 12),
                MapSelectorWidget(
                  latitude: _latitude,
                  longitude: _longitude,
                  selectedLocationName: _selectedLocationName,
                  onTap: _pickLocationFromMap,
                ),
                const SizedBox(height: 24),
                const SectionHeaderWidget(
                  title: "Pricing",
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 12),
                PriceFieldWidget(controller: _priceController),
                if (_showResidentialFields) ...[
                  const SizedBox(height: 24),
                  const SectionHeaderWidget(
                    title: "Property Details",
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  ResidentialFieldsWidget(
                    areaController: _areaController,
                    bedrooms: bedrooms,
                    bathrooms: bathrooms,
                    facilities: facilities,
                    onBedroomsChanged: (val) => setState(() => bedrooms = val),
                    onBathroomsChanged: (val) => setState(() => bathrooms = val),
                    onFacilityChanged: (key, value) {
                      setState(() {
                        facilities[key] = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 24),
                const SectionHeaderWidget(
                  title: "Description (Optional)",
                  icon: Icons.description,
                ),
                const SizedBox(height: 12),
                DescriptionFieldWidget(controller: _descriptionController),
                const SizedBox(height: 24),
                const SectionHeaderWidget(
                  title: "Contact Information",
                  icon: Icons.contact_phone,
                ),
                const SizedBox(height: 12),
                ContactFieldsWidget(
                  phoneController: _phoneController,
                  emailController: _emailController,
                  selectedCountryCode: _selectedCountryCode,
                  onCountryCodeChanged: (val) {
                    setState(() => _selectedCountryCode = val!);
                  },
                ),
                const SizedBox(height: 24),
                const SectionHeaderWidget(
                  title: "Property Images",
                  icon: Icons.photo_library,
                ),
                const SizedBox(height: 12),
                ImagePickerWidget(
                  images: _images,
                  onPickImages: _pickImages,
                  onRemoveImage: _removeImage,
                ),
                const SizedBox(height: 32),
                SubmitButtonWidget(
                  isLoading: _isLoading,
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
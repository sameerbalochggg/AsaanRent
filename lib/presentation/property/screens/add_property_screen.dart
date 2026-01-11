import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asaan_rent/data/repositories/property_repository.dart';
import 'package:asaan_rent/data/repositories/storage_repository.dart';
import 'package:asaan_rent/presentation/property/screens/map_screen.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/section_header_widget.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/property_type_dropdown.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/location_fields_widget.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/map_selector_widget.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/price_field_widget.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/residential_fields_widget.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/description_field_widget.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/contact_fields_widget.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/image_picker_widget.dart';
import 'package:asaan_rent/presentation/property/widgets/add_property/submit_button_widget.dart';
import 'package:asaan_rent/core/utils/image_compressor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ --- IMPORTS ---
import 'package:asaan_rent/core/utils/error_handler.dart';
import 'package:asaan_rent/presentation/widgets/success_dialog.dart'; // ✅ Imported SuccessDialog

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
  // bool _isLoading = false; // ❌ Removed Loading State (Requirement)

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
    } catch (error) {
      debugPrint("Error picking images: $error");
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, error);
      }
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

  // ✅ UPDATED: Validate, Show Success, Run in Background
  void _submitForm() {
    // 1. Validate UI Fields
    if (!_formKey.currentState!.validate()) return;
    
    if (_images.isEmpty) {
      ErrorHandler.showWarningSnackBar(
        context,
        "📷 Please upload at least one image",
      );
      return;
    }

    // 2. Capture Data for Background Task
    // We capture values immediately because controllers might be disposed if we pop the screen
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ErrorHandler.showErrorSnackBar(context, "User not authenticated");
      return;
    }

    final rawImages = List<XFile>.from(_images); // Copy list
    final fullPhone = "$_selectedCountryCode${_phoneController.text}";
    final basicData = {
      "owner_id": userId,
      "is_rented": false,
      "property_type": propertyType,
      "location": _locationController.text,
      "price": double.tryParse(_priceController.text) ?? 0,
      "description": _descriptionController.text.isEmpty ? null : _descriptionController.text,
      "phone": fullPhone,
      "email": _emailController.text,
      "latitude": _latitude,
      "longitude": _longitude,
    };
    
    // Residential Specific Data
    Map<String, dynamic> residentialData = {};
    if (_showResidentialFields) {
      int? bedroomsInt = int.tryParse(bedrooms ?? '');
      if (bedrooms == "5+") bedroomsInt = 5;
      int? bathroomsInt = int.tryParse(bathrooms ?? '');
      if (bathrooms == "5+") bathroomsInt = 5;
      
      residentialData = {
        "area": _areaController.text,
        "bedrooms": bedroomsInt,
        "bathrooms": bathroomsInt,
        ...facilities,
      };
    }

    // 3. Fire Background Task (Do NOT await)
    // We pass the captured data to a detached function
    _uploadPropertyInBackground(
      userId: userId,
      basicData: basicData,
      residentialData: residentialData,
      images: rawImages,
      repo: _propertyRepo,
      storage: _storageRepo,
    );

    // 4. Show Success Dialog Immediately
    SuccessDialog.show(
      context: context,
      title: "Adding Property...",
      message: "Your property is being uploaded in the background.",
      primaryColor: Colors.green,
      autoCloseDuration: const Duration(seconds: 3),
    );

    // 5. Navigate Home (Pop) after a short delay to let user see the dialog
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    });
  }

  // ✅ Detached Background Task
  // This function is static or independent so it doesn't rely on the Widget's state
  Future<void> _uploadPropertyInBackground({
    required String userId,
    required Map<String, dynamic> basicData,
    required Map<String, dynamic> residentialData,
    required List<XFile> images,
    required PropertyRepository repo,
    required StorageRepository storage,
  }) async {
    try {
      debugPrint("🚀 Background Upload Started...");

      // A. Upload Images
      final imageUrls = await Future.wait(
        images.map((img) async {
          final compressedFile = await ImageCompressor.compressImage(img);
          return storage.uploadFile(compressedFile, 'property-images');
        }),
      );

      // B. Merge Data
      final finalData = {
        ...basicData,
        ...residentialData,
        "images": imageUrls,
      };

      // C. Save to Database
      await repo.addProperty(finalData);
      
      debugPrint("✅ Background Upload Complete!");
    } catch (e) {
      // Since UI is gone, we can only log the error
      debugPrint("❌ Background Upload Failed: $e");
      ErrorHandler.logError(e);
    }
  }

  // ✅ NEW: Image Upload Guidelines Widget
  Widget _buildImageGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                "Image Upload Guidelines",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem("Upload clear and real property images"),
          _buildGuidelineItem("Add at least 3–7 photos"),
          _buildGuidelineItem("Avoid blurry or fake images"),
          _buildGuidelineItem("No personal or sensitive content"),
          _buildGuidelineItem("Use recent photos only"),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.red.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
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
                
                // ✅ Image Guidelines Box
                _buildImageGuidelines(),
                
                const SizedBox(height: 16),
                ImagePickerWidget(
                  images: _images,
                  onPickImages: _pickImages,
                  onRemoveImage: _removeImage,
                ),
                const SizedBox(height: 32),
                SubmitButtonWidget(
                  isLoading: false, // ✅ Always false (no spinner)
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
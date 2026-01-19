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
import 'package:asaan_rent/core/utils/error_handler.dart';
import 'package:asaan_rent/presentation/widgets/success_dialog.dart';

// ✅ Import your Home Screen
import 'package:asaan_rent/presentation/home/screens/home_screen.dart'; 

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

  void _submitForm() {
    // 1. Validate UI Fields (This triggers validators on ALL FormFields, including our custom Map one)
    if (!_formKey.currentState!.validate()) return;
    
    if (_images.isEmpty) {
      ErrorHandler.showWarningSnackBar(
        context,
        "📷 Please upload at least one image",
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ErrorHandler.showErrorSnackBar(context, "User not authenticated");
      return;
    }

    // 2. Prepare Data
    final rawImages = List<XFile>.from(_images);
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

    // 3. Fire Background Task
    _performUpload(
      basicData: basicData,
      residentialData: residentialData,
      images: rawImages,
    );

    // 4. Show Success Dialog Immediately
    SuccessDialog.show(
      context: context,
      title: "Success!",
      message: "Property is uploading in background.",
      primaryColor: Colors.green,
      autoCloseDuration: const Duration(seconds: 2),
    );

    // 5. Navigate to Home Screen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()), 
          (route) => false,
        );
      }
    });
  }

  // Independent Upload Logic
  Future<void> _performUpload({
    required Map<String, dynamic> basicData,
    required Map<String, dynamic> residentialData,
    required List<XFile> images,
  }) async {
    try {
      debugPrint("🚀 Background Upload Started...");
      
      final imageUrls = await Future.wait(
        images.map((img) async {
          final compressedFile = await ImageCompressor.compressImage(img);
          return _storageRepo.uploadFile(compressedFile, 'property-images');
        }),
      );

      final finalData = {
        ...basicData,
        ...residentialData,
        "images": imageUrls,
      };

      await _propertyRepo.addProperty(finalData);
      
      debugPrint("✅ Background Upload Finished Successfully!");
    } catch (e) {
      debugPrint("❌ Background Upload Failed: $e");
    }
  }

  // ... (Existing Guidelines Widgets) ...
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

                // ✅ WRAPPED MAP SELECTOR IN FormField FOR VALIDATION
                FormField<bool>(
                  validator: (value) {
                    // Check if latitude or longitude is null
                    if (_latitude == null || _longitude == null) {
                      return "Please select a location on the map";
                    }
                    return null;
                  },
                  builder: (FormFieldState<bool> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MapSelectorWidget(
                          latitude: _latitude,
                          longitude: _longitude,
                          selectedLocationName: _selectedLocationName,
                          onTap: () async {
                            await _pickLocationFromMap();
                            // Tell the FormField that the state has changed so it can re-validate
                            state.didChange(_latitude != null);
                          },
                        ),
                        // ✅ Display Error Message if Validation Fails
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
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
                
                _buildImageGuidelines(),
                
                const SizedBox(height: 16),
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
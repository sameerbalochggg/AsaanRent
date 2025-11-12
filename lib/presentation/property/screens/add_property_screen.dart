import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:rent_application/data/repositories/storage_repository.dart';
import 'package:rent_application/presentation/property/screens/map_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

// --- Image Compression ---
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
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
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  // Dropdown values
  String? bedrooms;
  String? bathrooms;
  String? propertyType;

  String _selectedCountryCode = "+92"; 

  final Map<String, bool> facilities = {
    "kitchen": false, "parking": false, "furnished": false,
    "electricity": false, "water": false, "gas": false,
    "ac": false, "balcony": false, "garden": false,
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
  
  // ✅ --- HELPER GETTER ---
  /// Checks if the selected type is residential
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

  Future<void> _pickLocationFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );

    if (result != null && result is Map<String, double>) {
      setState(() {
        _latitudeController.text = result["latitude"]!.toStringAsFixed(6);
        _longitudeController.text = result["longitude"]!.toStringAsFixed(6);
      });
    }
  }

  Future<File> _compressImage(XFile xfile) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      xfile.path,
      targetPath,
      minWidth: 1920,
      minHeight: 1080,
      quality: 80,
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }
    debugPrint('Original size: ${await xfile.length()} bytes');
    debugPrint('Compressed size: ${await result.length()} bytes');
    return File(result.path);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📷 Please upload at least one image")),
      );
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
          final compressedFile = await _compressImage(img);
          return _storageRepo.uploadFile(compressedFile, 'property-images');
        }),
      );

      final fullPhone = "$_selectedCountryCode${_phoneController.text}";

      // ✅ --- Start building the data map with COMMON fields ---
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
        "latitude": double.tryParse(_latitudeController.text),
        "longitude": double.tryParse(_longitudeController.text),
      };
      
      // ✅ --- Conditionally add RESIDENTIAL fields ---
      if (_showResidentialFields) {
        int? bedroomsInt = int.tryParse(bedrooms ?? '');
        if (bedrooms == "5+") bedroomsInt = 5;
        int? bathroomsInt = int.tryParse(bathrooms ?? '');
        if (bathrooms == "5+") bathroomsInt = 5;
        
        propertyData.addAll({
          "area": double.tryParse(_areaController.text), // Fix from last time
          "bedrooms": bedroomsInt,
          "bathrooms": bathroomsInt,
          ...facilities, // Add all facilities
        });
      }
      
      // ✅ --- Conditionally add COMMERCIAL fields (if any) ---
      // For example, if Shop/Office had its own facility map
      // else { ... }

      await _propertyRepo.addProperty(propertyData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Property added successfully!")),
      );
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Add Property",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004D40),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "For Rent",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // --- Property Type Dropdown ---
                DropdownButtonFormField<String>(
                  value: propertyType,
                  decoration: _inputDecoration(
                    "Property Type",
                    icon: Icons.home,
                  ),
                  isExpanded: true,
                  items: ["House", "Shop", "Office", "Flat", "Apartment"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      propertyType = val;
                      // ✅ --- Clear residential-only fields if type is changed ---
                      if (!_showResidentialFields) {
                        bedrooms = null;
                        bathrooms = null;
                        _areaController.clear();
                        facilities.updateAll((key, value) => false);
                      }
                    });
                  },
                  validator: (val) =>
                      val == null ? "Select property type" : null,
                ),
                const SizedBox(height: 20),
                
                _sectionTitle("Basic Info"),
                
                // --- Location ---
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _locationController,
                        decoration: _inputDecoration(
                          "Location (City, Area, Landmark)",
                          icon: Icons.location_on,
                        ),
                        validator: (val) =>
                            val!.isEmpty ? "Enter property location" : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        onTap: _pickLocationFromMap,
                        decoration: _inputDecoration("Map", icon: Icons.map),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _latitudeController,
                  readOnly: true,
                  decoration: _inputDecoration(
                    "Latitude",
                    icon: Icons.my_location,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _longitudeController,
                  readOnly: true,
                  decoration: _inputDecoration(
                    "Longitude",
                    icon: Icons.my_location,
                  ),
                ),
                const SizedBox(height: 16),
                
                _sectionTitle("Property Details"),
                
                // --- Price ---
                TextFormField(
                  controller: _priceController,
                  decoration: _inputDecoration(
                    "Price",
                    icon: Icons.attach_money,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? "Enter price" : null,
                ),
                const SizedBox(height: 12),

                // ✅ --- START: Conditional Fields ---
                // AnimatedSwitcher provides a smooth fade in/out
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _showResidentialFields
                      ? Column(
                          key: const ValueKey('residential'), // Key for animation
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _areaController,
                              decoration: _inputDecoration(
                                "Area (e.g. 200 Sq Yards)",
                                icon: Icons.square_foot,
                              ),
                              keyboardType: TextInputType.number, 
                              validator: (val) => val!.isEmpty
                                  ? "Enter property area"
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: bedrooms,
                              decoration: _inputDecoration("Bedrooms", icon: Icons.bed),
                              isExpanded: true,
                              items: ["1", "2", "3", "4", "5+"]
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) => setState(() => bedrooms = val),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: bathrooms,
                              decoration: _inputDecoration(
                                "Bathrooms",
                                icon: Icons.bathtub,
                              ),
                              isExpanded: true,
                              items: ["1", "2", "3", "4", "5+"]
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) => setState(() => bathrooms = val),
                            ),
                            const SizedBox(height: 16),
                            _sectionTitle("Facilities"),
                            Wrap(
                              spacing: 8,
                              children: facilities.keys.map((facilityKey) {
                                String displayLabel;
                                if (facilityKey == "ac") {
                                  displayLabel = "AC";
                                } else {
                                  displayLabel = facilityKey[0].toUpperCase() +
                                      facilityKey.substring(1);
                                }
                                return FilterChip(
                                  label: Text(displayLabel),
                                  selected: facilities[facilityKey]!,
                                  selectedColor: Colors.teal,
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: facilities[facilityKey]!
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: facilities[facilityKey]!
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      facilities[facilityKey] = selected;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        )
                      : const SizedBox(key: ValueKey('empty')), // Show nothing
                ),
                // ✅ --- END: Conditional Fields ---

                const SizedBox(height: 16),
                _sectionTitle("Description (optional)"),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(
                    "Description",
                    icon: Icons.text_snippet,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                _sectionTitle("Owner Info"),
                _ownerInfoWidget(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: _inputDecoration("Email", icon: Icons.email),
                ),
                const SizedBox(height: 16),

                _sectionTitle("Images"),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._images.map(
                      (img) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(img.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // --- Submit Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Add Property",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Private Helper Widgets ---
  
  InputDecoration _inputDecoration(
    String label, {
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _ownerInfoWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        final dropdownDecoration = _inputDecoration("Code").copyWith(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
        );

        final phoneDecoration = _inputDecoration(
          "Phone Number",
          icon: Icons.phone,
          hint: "e.g. 3001234567",
        ).copyWith(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCountryCode,
                isExpanded: true,
                decoration: dropdownDecoration,
                items: ["+92", "+91", "+1", "+44", "+971"]
                    .map(
                      (code) => DropdownMenuItem(
                        value: code,
                        child: Text(code, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCountryCode = val!),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: phoneDecoration,
                keyboardType: TextInputType.phone,
                validator: (val) => val!.isEmpty ? "Enter phone number" : null,
              ),
            ],
          );
        } else {
          return Row(
            children: [
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<String>(
                  value: _selectedCountryCode,
                  isExpanded: true,
                  decoration: dropdownDecoration,
                  items: ["+92", "+91", "+1", "+44", "+971"]
                      .map(
                        (code) => DropdownMenuItem(
                          value: code,
                          child: Text(code, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCountryCode = val!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: phoneDecoration,
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                      val!.isEmpty ? "Enter phone number" : null,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
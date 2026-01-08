import 'package:flutter/material.dart';
import 'package:asaan_rent/data/models/property_model.dart';
import 'package:asaan_rent/data/repositories/property_repository.dart';
import 'package:asaan_rent/core/utils/error_handler.dart'; // ✅ Import ErrorHandler

class PropertyProvider with ChangeNotifier {
  final PropertyRepository _propertyRepo = PropertyRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage; // ✅ Added error state
  String? get errorMessage => _errorMessage;

  List<Property> _availableProperties = [];
  List<Property> get availableProperties => _availableProperties;

  Future<void> fetchAvailableProperties() async {
    _isLoading = true;
    _errorMessage = null; // Reset error
    notifyListeners();

    try {
      _availableProperties = await _propertyRepo.fetchAllAvailableProperties();
    } catch (e) {
      // ✅ Convert raw error to friendly message
      _errorMessage = ErrorHandler.getMessage(e); 
      debugPrint("Error in PropertyProvider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
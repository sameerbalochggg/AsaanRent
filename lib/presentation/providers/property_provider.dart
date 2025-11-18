import 'package:flutter/material.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/property_repository.dart';

class PropertyProvider with ChangeNotifier {
  final PropertyRepository _propertyRepo = PropertyRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Property> _availableProperties = [];
  List<Property> get availableProperties => _availableProperties;

  // This is the function all screens will call to get or refresh data
  Future<void> fetchAvailableProperties() async {
    _isLoading = true;
    notifyListeners(); // Tell listeners we are loading

    try {
      // Get only available properties from the repository
      _availableProperties = await _propertyRepo.fetchAllAvailableProperties();
    } catch (e) {
      debugPrint("Error in PropertyProvider: $e");
      // You could store an error message here if you want
    } finally {
      _isLoading = false;
      notifyListeners(); // Tell listeners we are done loading (and send data)
    }
  }
}
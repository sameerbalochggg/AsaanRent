import 'package:flutter/material.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/models/report_model.dart'; // ✅ Added Import for Report
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

class PropertyRepository {
  /// Fetches all *available* properties for the HomePage.
  Future<List<Property>> fetchAllAvailableProperties() async {
    try {
      final response =
          await _supabase.from('properties').select().eq('is_rented', false);
      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error in fetchAllAvailableProperties: $e");
      rethrow;
    }
  }

  /// Fetches *all* properties (available and rented) for the SearchPage.
  Future<List<Property>> getAllPropertiesForSearch() async {
    try {
      final response = await _supabase.from('properties').select();
      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error in getAllPropertiesForSearch: $e");
      rethrow;
    }
  }

  /// Fetches a list of properties based on a list of IDs (UUIDs).
  Future<List<Property>> getPropertiesByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .filter('id', 'in', ids); // ✅ Corrected syntax
      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error in getPropertiesByIds: $e");
      rethrow;
    }
  }

  /// Fetches all properties for a specific user.
  Future<List<Property>> fetchUserProperties() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final response = await _supabase
          .from('properties')
          .select('*')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user properties: $e');
    }
  }

  /// ✅ NEW: Fetch all properties posted by a specific user (by user_id) - For Admin
  Future<List<Property>> fetchPropertiesByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('properties')
          .select('*')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      debugPrint('✅ Fetched ${response.length} properties for user: $userId');

      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching user properties: $e');
      throw Exception('Failed to fetch user properties: $e');
    }
  }

  /// Fetches a single property by its ID (UUID).
  Future<Property> fetchPropertyById(String propertyId) async {
    try {
      final response = await _supabase
          .from('properties')
          .select('*')
          .eq('id', propertyId) // Use the String ID
          .single();
      return Property.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching property by ID: $e');
      throw Exception('Failed to fetch property details: $e');
    }
  }

  /// Adds a new property to the database.
  Future<void> addProperty(Map<String, dynamic> propertyData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      // 1. Fetch the user's profile to get their name
      final profileResponse = await _supabase
          .from('profiles')
          .select('username')
          .eq('user_id', userId)
          .maybeSingle();

      String? ownerName;
      if (profileResponse != null) {
        ownerName = profileResponse['username'] as String?;
      }

      // 2. Add the username to the property data
      if (ownerName != null) {
        propertyData['username'] = ownerName;
      }
      
      // Ensure owner_id is set
      propertyData['owner_id'] = userId;

      await _supabase.from('properties').insert(propertyData);
    } catch (e) {
      debugPrint("Error adding property: $e");
      rethrow;
    }
  }

  /// Updates an existing property.
  Future<void> updateProperty(Property property) async {
    try {
      await _supabase
          .from('properties')
          .update(property.toJson())
          .eq('id', property.id); // Use String id
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  /// Toggles the rental status of a property.
  Future<void> toggleRentalStatus(String propertyId, bool isRented) async {
    try {
      await _supabase
          .from('properties')
          .update({
            'is_rented': isRented,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId);
    } catch (e) {
      throw Exception('Failed to update rental status: $e');
    }
  }

  /// Deletes a property by its ID.
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _supabase.from('properties').delete().eq('id', propertyId);
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  // ✅ --- ADMIN: Fetch ALL properties (even unverified ones) ---
  Future<List<Property>> fetchAllPropertiesForAdmin() async {
    try {
      // No filter for 'is_rented' because admin needs to see everything
      final response = await _supabase
          .from('properties')
          .select()
          .order('created_at', ascending: false); // Newest first
      
      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching admin properties: $e");
      rethrow;
    }
  }

  // ✅ --- ADMIN: Verify or Unverify a property ---
  Future<void> updateVerificationStatus(String propertyId, bool isVerified) async {
    try {
      await _supabase
          .from('properties')
          .update({'is_verified': isVerified})
          .eq('id', propertyId);
    } catch (e) {
      throw Exception('Failed to update verification: $e');
    }
  }

  // ✅ --- USER: Report a property ---
  Future<void> reportProperty(String propertyId, String reason) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      await _supabase.from('reports').insert({
        'property_id': propertyId,
        'reporter_id': userId,
        'reason': reason,
      });
    } catch (e) {
      debugPrint("Error reporting property: $e");
      rethrow;
    }
  }

  // ✅ --- ADMIN: Fetch ALL reports ---
  Future<List<Report>> fetchAllReports() async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching reports: $e");
      rethrow;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:asaan_rent/data/models/property_model.dart';
import 'package:asaan_rent/data/models/report_model.dart'; // ✅ Added Import for Report
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ --- Import Notification Repository ---
import 'package:asaan_rent/data/repositories/notification_repository.dart';

final _supabase = Supabase.instance.client;

class PropertyRepository {
  // ✅ --- Create instance of NotificationRepository ---
  final NotificationRepository _notificationRepo = NotificationRepository();

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
          .filter('id', 'in', ids); 
      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error in getPropertiesByIds: $e");
      rethrow;
    }
  }

  /// Fetches all properties for a specific user (Current User).
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

  // ✅ --- MISSING METHOD ADDED HERE ---
  /// Fetches all properties for a specific user ID (For Admin View).
  Future<List<Property>> fetchPropertiesByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('properties')
          .select('*')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching properties by user ID: $e");
      throw Exception('Failed to fetch properties for user: $userId');
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

  // ✅ --- ADMIN: Verify or Unverify a property + Send Notification ---
  Future<void> updateVerificationStatus(String propertyId, bool isVerified) async {
    try {
      // 1. Update property status
      await _supabase
          .from('properties')
          .update({'is_verified': isVerified})
          .eq('id', propertyId);

      // 2. Fetch property details to get owner ID and title
      final property = await fetchPropertyById(propertyId);
      
      // 3. Send Notification to the Owner if verified
      if (isVerified && property.ownerId != null) {
         await _notificationRepo.sendVerificationNotification(
           property.ownerId!, 
           property.displayName
         );
      }
      
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
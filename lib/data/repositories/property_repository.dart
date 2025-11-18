import 'package:flutter/material.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

class PropertyRepository {
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

  Future<List<Property>> getAllPropertiesForSearch() async {
    try {
      final response = await _supabase.from('properties').select();
      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error in getAllPropertiesForSearch: $e");
      rethrow;
    }
  }

  // ✅ --- FIX: Now accepts List<String> (UUIDs) ---
  Future<List<Property>> getPropertiesByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .inFilter('id', ids); 
      return (response as List).map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error in getPropertiesByIds: $e");
      rethrow;
    }
  }

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

  // ✅ --- FIX: Now accepts String propertyId (UUID) ---
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

  Future<void> addProperty(Map<String, dynamic> propertyData) async {
    try {
      await _supabase.from('properties').insert(propertyData);
    } catch (e) {
      debugPrint("Error adding property: $e");
      rethrow;
    }
  }

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

  // ✅ --- FIX: Now accepts String propertyId (UUID) ---
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

  // ✅ --- FIX: Now accepts String propertyId (UUID) ---
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _supabase.from('properties').delete().eq('id', propertyId);
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }
}
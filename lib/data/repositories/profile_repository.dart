import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_application/data/models/user_profile_model.dart';

final _supabase = Supabase.instance.client;

class ProfileRepository {
  /// ✅ Get the current user's profile from Supabase
  Future<UserProfile?> getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ No profile found for user: ${user.id}');
        return null;
      }

      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error getting profile: $e');
      rethrow;
    }
  }

  /// ✅ Create a new profile after registration (optional use)
  Future<void> createProfile(Map<String, dynamic> profileData) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final data = {
        'user_id': user.id,
        ...profileData,
      };

      await _supabase.from('profiles').insert(data);
      debugPrint("✅ Profile created successfully for ${user.id}");
    } catch (e) {
      debugPrint("❌ Error creating profile: $e");
      rethrow;
    }
  }

  /// ✅ Update the existing user's profile in Supabase
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      await _supabase
          .from('profiles')
          .update(profileData)
          .eq('user_id', user.id);

      debugPrint("✅ Profile updated successfully for ${user.id}");
    } catch (e) {
      debugPrint("❌ Error updating profile: $e");
      rethrow;
    }
  }

  /// ✅ Fetch the owner's name by user_id (for properties, etc.)
  Future<String> fetchOwnerName(String ownerId) async {
    try {
      final ownerResponse = await _supabase
          .from('profiles')
          .select('username')
          .eq('user_id', ownerId)
          .maybeSingle();

      if (ownerResponse != null && ownerResponse['username'] != null) {
        return ownerResponse['username'] as String;
      }
      return "Property Owner";
    } catch (e) {
      debugPrint('⚠️ Could not fetch owner name: $e');
      return "Property Owner";
    }
  }
}

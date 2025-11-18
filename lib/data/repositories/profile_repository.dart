import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_application/data/models/user_profile_model.dart';
import 'package:path/path.dart' as path;

final _supabase = Supabase.instance.client;

class ProfileRepository {
  /// Get the current user's profile from Supabase
  Future<UserProfile?> getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ No profile found for user: ${user.id}');
        return null;
      }

      debugPrint('✅ Profile fetched successfully');
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error getting profile: $e');
      rethrow;
    }
  }

  /// Create a new profile after registration
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

  /// Update profile with optional image upload
  Future<void> updateProfile(
    Map<String, dynamic> profileData, {
    File? imageFile,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      String? avatarUrl;

      // Upload image if provided
      if (imageFile != null) {
        avatarUrl = await uploadAvatar(imageFile);
        if (avatarUrl != null) {
          profileData['avatar_url'] = avatarUrl;
        }
      }
      
      profileData.removeWhere((key, value) => value == null);

      // Update profile data
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

  /// Upload avatar image to Supabase Storage
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = '${user.id}_$timestamp$extension';
      final filePath = fileName;

      debugPrint('📤 Uploading image: $filePath');

      // Delete old avatar if exists
      try {
        final existingFiles = await _supabase.storage
            .from('avatars')
            .list(path: '', searchOptions: SearchOptions(search: user.id));

        for (var file in existingFiles) {
          await _supabase.storage.from('avatars').remove([file.name]);
          debugPrint('🗑️ Deleted old avatar: ${file.name}');
        }
      } catch (e) {
        debugPrint('⚠️ No old avatar to delete or error: $e');
      }

      // Upload new image
      await _supabase.storage.from('avatars').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      debugPrint('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Delete avatar from storage
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      // Extract filename from URL
      final uri = Uri.parse(avatarUrl);
      final fileName = uri.pathSegments.last;

      await _supabase.storage.from('avatars').remove([fileName]);
      debugPrint('✅ Avatar deleted: $fileName');
    } catch (e) {
      debugPrint('❌ Error deleting avatar: $e');
      rethrow;
    }
  }

  /// Fetch the owner's name by user_id (for properties, etc.)
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

  /// ✅ --- UPDATED: Now uses String propertyId (UUID) ---
  Future<void> toggleFavorite(String propertyId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get current favorites
      final userData = await _supabase
          .from('profiles')
          .select('favorites')
          .eq('user_id', user.id)
          .maybeSingle();

      // ✅ --- FIX: Database stores UUIDs (Strings) ---
      List<String> favorites = [];

      if (userData != null && userData['favorites'] != null) {
        favorites = List<String>.from(userData['favorites'].map((id) => id.toString()));
      }

      // Toggle logic
      if (favorites.contains(propertyId)) {
        favorites.remove(propertyId); 
      } else {
        favorites.add(propertyId);
      }

      // Save back to Supabase
      await _supabase
          .from('profiles')
          .update({'favorites': favorites}) // Save the list of Strings
          .eq('user_id', user.id);

      debugPrint("❤️ Favorites updated: $favorites");
    } catch (e) {
      debugPrint("❌ Error updating favorites: $e");
      rethrow;
    }
  }
}
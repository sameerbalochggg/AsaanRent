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
      debugPrint('❤️ Favorites in profile: ${response['favorites']}');
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
        'favorites': [], // Initialize with empty array
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
  /// ✅ UPDATED: Now also updates properties table via database trigger
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

      // Update profile data in profiles table
      // ✅ The database trigger will automatically update the properties table
      await _supabase
          .from('profiles')
          .update(profileData)
          .eq('user_id', user.id);

      debugPrint("✅ Profile updated successfully for ${user.id}");
      debugPrint("✅ Properties table will be updated automatically via database trigger");
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

  /// ✅ IMPROVED: Toggle favorite with better error handling and verification
  Future<void> toggleFavorite(String propertyId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      debugPrint("🔄 Toggling favorite for property: $propertyId");

      // Get current favorites with single() to ensure we get data
      final userData = await _supabase
          .from('profiles')
          .select('favorites')
          .eq('user_id', user.id)
          .single();

      // Parse favorites safely
      List<String> favorites = [];
      if (userData['favorites'] != null) {
        final rawFavorites = userData['favorites'];
        if (rawFavorites is List) {
          favorites = List<String>.from(
            rawFavorites.map((id) => id.toString())
          );
        }
      }

      debugPrint("📋 Current favorites: $favorites");

      // Toggle logic
      if (favorites.contains(propertyId)) {
        favorites.remove(propertyId);
        debugPrint("💔 Removing from favorites");
      } else {
        favorites.add(propertyId);
        debugPrint("❤️ Adding to favorites");
      }

      debugPrint("📋 Updated favorites list: $favorites");

      // Save back to Supabase with verification
      final updateResponse = await _supabase
          .from('profiles')
          .update({'favorites': favorites})
          .eq('user_id', user.id)
          .select();

      debugPrint("✅ Update response: $updateResponse");

      // Verify the update was successful
      if (updateResponse.isNotEmpty) {
        final verifiedFavorites = updateResponse[0]['favorites'];
        debugPrint("🔍 Verified favorites in database: $verifiedFavorites");
        
        if (verifiedFavorites == null || 
            (verifiedFavorites is List && verifiedFavorites.isEmpty && favorites.isNotEmpty)) {
          debugPrint("⚠️ WARNING: Favorites were not saved correctly!");
          throw Exception("Favorites update verification failed");
        }
      } else {
        debugPrint("⚠️ WARNING: No data returned from update");
      }

      debugPrint("✅ Favorites updated and verified successfully");

    } catch (e, stackTrace) {
      debugPrint("❌ Error updating favorites: $e");
      debugPrint("Stack trace: $stackTrace");
      rethrow;
    }
  }

  /// ✅ NEW: Get user's favorite property IDs
  Future<List<String>> getFavorites() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint("⚠️ No authenticated user for getFavorites");
        return [];
      }

      final response = await _supabase
          .from('profiles')
          .select('favorites')
          .eq('user_id', user.id)
          .single();

      if (response['favorites'] != null) {
        final rawFavorites = response['favorites'];
        if (rawFavorites is List) {
          final favorites = List<String>.from(
            rawFavorites.map((id) => id.toString())
          );
          debugPrint("📋 Fetched ${favorites.length} favorites: $favorites");
          return favorites;
        }
      }

      debugPrint("📋 No favorites found, returning empty list");
      return [];
    } catch (e) {
      debugPrint("❌ Error fetching favorites: $e");
      return [];
    }
  }

  /// ✅ NEW: Check if a property is favorited
  Future<bool> isFavorite(String propertyId) async {
    try {
      final favorites = await getFavorites();
      return favorites.contains(propertyId);
    } catch (e) {
      debugPrint("❌ Error checking favorite status: $e");
      return false;
    }
  }

  /// ✅ NEW: Listen to profile changes in real-time
  Stream<UserProfile?> watchProfile() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .map((data) {
          if (data.isEmpty) return null;
          debugPrint("🔄 Profile updated via stream: ${data.first['favorites']}");
          return UserProfile.fromJson(data.first);
        });
  }

  /// ✅ NEW: Debug method to check profile state
  Future<void> debugProfileState() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint("❌ No authenticated user");
        return;
      }

      debugPrint("=" * 50);
      debugPrint("🔍 DEBUG PROFILE STATE");
      debugPrint("=" * 50);
      debugPrint("👤 Current user ID: ${user.id}");
      debugPrint("📧 User email: ${user.email}");

      final profile = await _supabase
          .from('profiles')
          .select('*')
          .eq('user_id', user.id)
          .single();

      debugPrint("📊 Full profile data: $profile");
      debugPrint("❤️ Favorites: ${profile['favorites']}");
      debugPrint("❤️ Favorites type: ${profile['favorites'].runtimeType}");
      
      if (profile['favorites'] != null && profile['favorites'] is List) {
        debugPrint("❤️ Favorites count: ${(profile['favorites'] as List).length}");
      }
      
      debugPrint("=" * 50);
    } catch (e, stackTrace) {
      debugPrint("❌ Debug error: $e");
      debugPrint("Stack: $stackTrace");
    }
  }

  /// ✅ NEW: Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('profiles')
          .update({'favorites': []})
          .eq('user_id', user.id);

      debugPrint("✅ All favorites cleared");
    } catch (e) {
      debugPrint("❌ Error clearing favorites: $e");
      rethrow;
    }
  }

  /// ✅ NEW: Add multiple properties to favorites at once
  Future<void> addMultipleFavorites(List<String> propertyIds) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final currentFavorites = await getFavorites();
      final updatedFavorites = {...currentFavorites, ...propertyIds}.toList();

      await _supabase
          .from('profiles')
          .update({'favorites': updatedFavorites})
          .eq('user_id', user.id);

      debugPrint("✅ Added ${propertyIds.length} properties to favorites");
    } catch (e) {
      debugPrint("❌ Error adding multiple favorites: $e");
      rethrow;
    }
  }

  /// ✅ NEW: Remove multiple properties from favorites at once
  Future<void> removeMultipleFavorites(List<String> propertyIds) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final currentFavorites = await getFavorites();
      final updatedFavorites = currentFavorites
          .where((id) => !propertyIds.contains(id))
          .toList();

      await _supabase
          .from('profiles')
          .update({'favorites': updatedFavorites})
          .eq('user_id', user.id);

      debugPrint("✅ Removed ${propertyIds.length} properties from favorites");
    } catch (e) {
      debugPrint("❌ Error removing multiple favorites: $e");
      rethrow;
    }
  }
}
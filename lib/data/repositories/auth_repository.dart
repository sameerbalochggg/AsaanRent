import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  /// Signs in a user with email and password.
  ///
  /// Throws a [AuthException] if login fails.
  /// Returns the [User] object on success.
  Future<User> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('Login failed, user data not returned.');
      }
      return response.user!;
    } catch (e) {
      // Re-throw the original exception to be handled by the UI
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
      // Re-throw to let the UI show an error if needed
      rethrow;
    }
  }

  // ✅ --- NEW FUNCTION ADDED ---
  /// Gets the currently signed-in user, if one exists.
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}
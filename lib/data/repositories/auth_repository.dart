import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  /// Signs in a user with email and password.
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
      rethrow;
    }
  }

  /// Registers a new user with email, password, and username.
  Future<User> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'rentapp://login-callback',
        data: {
          'username': username, // This saves to 'raw_user_meta_data'
        },
      );
      
      if (response.user == null) {
        throw Exception("Sign up failed, user data not returned.");
      }
      
      if (response.user?.identities?.isEmpty ?? true) {
         throw Exception("This email is already registered. Please login.");
      }
      
      return response.user!;
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
      rethrow;
    }
  }
  
  /// Gets the currently signed-in user, if one exists.
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Send Password Reset OTP to the user's email
  Future<void> sendPasswordResetOtp(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: "rentapp://reset-callback/",
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verifies the OTP and signs the user in
  Future<User> verifyPasswordResetOtp(String email, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        token: otp,
        email: email,
      );
      if (response.user == null) {
        throw Exception("OTP verification failed.");
      }
      return response.user!;
    } catch (e) {
      rethrow;
    }
  }

  // ✅ --- MISSING FUNCTION ADDED ---
  /// Updates the user's password after they have been authenticated
  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch(e) {
      rethrow;
    }
  }
}
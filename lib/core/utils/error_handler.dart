import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  /// Returns a user-friendly error message based on the exception type.
  static String getMessage(Object error) {
    debugPrint("🔴 ErrorHandler Caught: $error");

    if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is PostgrestException) {
      return _handleDatabaseError(error);
    } else if (error is SocketException) {
      return "No internet connection. Please check your network.";
    } else if (error.toString().contains("SocketException")) {
      // Sometimes SocketException is wrapped in another exception
      return "No internet connection. Please check your network.";
    }

    // Default fallback
    return "Something went wrong. Please try again.";
  }

  static String _handleAuthError(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains("invalid login credentials")) {
      return "Incorrect email or password.";
    } else if (message.contains("user not found")) {
      return "No account found with this email.";
    } else if (message.contains("email not confirmed")) {
      return "Please confirm your email address before logging in.";
    } else if (message.contains("already registered")) {
      return "This email is already in use. Please login.";
    }
    return error.message; // Fallback to the actual message if generic
  }

  static String _handleDatabaseError(PostgrestException error) {
    // You can add specific codes here if you know them
    // e.g., code '23505' is a unique constraint violation (duplicate data)
    if (error.code == '23505') {
      return "This record already exists.";
    } else if (error.code == '42501' || error.code == '42P17') {
      return "You do not have permission to perform this action.";
    } else if (error.code == '22P02') {
      return "Invalid data format. Please check your inputs.";
    }
    
    // For unknown DB errors, generic message is better than raw SQL error
    return "Database error occurred. Please try again later.";
  }

  /// Shows a standardized SnackBar with the error message
  static void showErrorSnackBar(BuildContext context, Object error) {
    final message = getMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
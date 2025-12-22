import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🔹 Centralized Error Handler for the entire application
/// Handles all types of errors: Auth, Database, Network, and Generic errors
class ErrorHandler {
  /// Returns a user-friendly error message based on the exception type.
  /// 
  /// Usage:
  /// ```dart
  /// try {
  ///   await someOperation();
  /// } catch (e) {
  ///   String message = ErrorHandler.getMessage(e);
  ///   print(message);
  /// }
  /// ```
  static String getMessage(Object error) {
    debugPrint("🔴 ErrorHandler Caught: $error");

    // Handle Supabase Auth Errors
    if (error is AuthException) {
      return _handleAuthError(error);
    } 
    
    // Handle Supabase Database Errors
    else if (error is PostgrestException) {
      return _handleDatabaseError(error);
    } 
    
    // Handle Storage Errors
    else if (error is StorageException) {
      return _handleStorageError(error);
    }
    
    // Handle Network/Socket Errors
    else if (error is SocketException) {
      return "No internet connection. Please check your network.";
    } 
    
    // Handle Timeout Errors
    else if (error is TimeoutException) {
      return "Request timed out. Please try again.";
    }
    
    // Handle Format Errors
    else if (error is FormatException) {
      return "Invalid data format. Please check your input.";
    }
    
    // Check if error string contains specific keywords
    else if (error.toString().toLowerCase().contains("socketexception")) {
      return "No internet connection. Please check your network.";
    } 
    else if (error.toString().toLowerCase().contains("timeout")) {
      return "Request timed out. Please try again.";
    }
    else if (error.toString().toLowerCase().contains("certificate")) {
      return "Security certificate error. Please check your connection.";
    }

    // Default fallback for unknown errors
    return "Something went wrong. Please try again.";
  }

  /// Handles Authentication-specific errors from Supabase
  static String _handleAuthError(AuthException error) {
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode;

    // Check by status code first (more reliable)
    switch (statusCode) {
      case '400':
        if (message.contains("invalid login credentials")) {
          return "Incorrect email or password.";
        } else if (message.contains("email not confirmed")) {
          return "Please confirm your email before logging in.";
        } else if (message.contains("password")) {
          return "Password must be at least 6 characters.";
        }
        return "Invalid request. Please check your input.";
      
      case '401':
        return "Authentication failed. Please login again.";
      
      case '403':
        return "Access denied. You don't have permission.";
      
      case '404':
        return "User not found. Please check your email.";
      
      case '422':
        if (message.contains("email")) {
          return "Invalid email format.";
        }
        return "Invalid data provided.";
      
      case '429':
        return "Too many attempts. Please try again later.";
      
      case '500':
        return "Server error. Please try again later.";
    }

    // Check by message content
    if (message.contains("invalid login credentials")) {
      return "Incorrect email or password.";
    } else if (message.contains("user not found")) {
      return "No account found with this email.";
    } else if (message.contains("email not confirmed")) {
      return "Please confirm your email address before logging in.";
    } else if (message.contains("already registered") || 
               message.contains("already exists")) {
      return "This email is already in use. Please login.";
    } else if (message.contains("weak password")) {
      return "Password is too weak. Use at least 8 characters.";
    } else if (message.contains("invalid email")) {
      return "Please enter a valid email address.";
    } else if (message.contains("token") || message.contains("expired")) {
      return "Session expired. Please login again.";
    } else if (message.contains("network")) {
      return "Network error. Please check your connection.";
    }

    // Fallback to the actual message if it's user-friendly
    return error.message.isNotEmpty ? error.message : "Authentication failed.";
  }

  /// Handles Database-specific errors from Supabase
  static String _handleDatabaseError(PostgrestException error) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();

    // Handle specific PostgreSQL error codes
    switch (code) {
      case '23505': // Unique violation
        return "This record already exists.";
      
      case '23503': // Foreign key violation
        return "Cannot delete. This item is being used elsewhere.";
      
      case '23502': // Not null violation
        return "Required field is missing.";
      
      case '42501': // Insufficient privilege
      case '42P17': // Insufficient privilege
        return "You don't have permission to perform this action.";
      
      case '22P02': // Invalid text representation
        return "Invalid data format. Please check your inputs.";
      
      case '42P01': // Undefined table
        return "Database configuration error. Please contact support.";
      
      case '42703': // Undefined column
        return "Database schema error. Please contact support.";
      
      case '22001': // String data right truncation
        return "Input text is too long.";
      
      case '22003': // Numeric value out of range
        return "Number value is out of range.";
      
      case '23514': // Check violation
        return "Invalid data value provided.";
    }

    // Check message content
    if (message.contains("duplicate") || message.contains("unique")) {
      return "This record already exists.";
    } else if (message.contains("foreign key")) {
      return "Cannot complete operation. Related data exists.";
    } else if (message.contains("null value")) {
      return "Required field cannot be empty.";
    } else if (message.contains("permission") || message.contains("denied")) {
      return "You don't have permission to perform this action.";
    } else if (message.contains("not found")) {
      return "Record not found.";
    } else if (message.contains("timeout")) {
      return "Database operation timed out. Please try again.";
    }

    // For unknown DB errors, show generic message
    return "Database error occurred. Please try again later.";
  }

  /// Handles Storage-specific errors from Supabase
  static String _handleStorageError(StorageException error) {
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode;

    if (statusCode == '404') {
      return "File not found.";
    } else if (statusCode == '413') {
      return "File is too large. Maximum size is 50MB.";
    } else if (statusCode == '415') {
      return "File type not supported.";
    } else if (statusCode == '400') {
      return "Invalid file. Please try another file.";
    }

    if (message.contains("not found")) {
      return "File not found.";
    } else if (message.contains("size") || message.contains("large")) {
      return "File is too large. Please upload a smaller file.";
    } else if (message.contains("type") || message.contains("format")) {
      return "File format not supported.";
    } else if (message.contains("permission") || message.contains("access")) {
      return "You don't have permission to access this file.";
    } else if (message.contains("bucket")) {
      return "Storage configuration error. Please contact support.";
    }

    return "File upload failed. Please try again.";
  }

  /// ✅ FIXED: Safely checks if context is valid before showing SnackBar
  static bool _isContextValid(BuildContext context) {
    try {
      // Check if the context is still mounted and the widget tree is stable
      return context.mounted;
    } catch (e) {
      return false;
    }
  }

  /// Shows a standardized error SnackBar
  /// 
  /// Usage:
  /// ```dart
  /// try {
  ///   await someOperation();
  /// } catch (e) {
  ///   ErrorHandler.showErrorSnackBar(context, e);
  /// }
  /// ```
  static void showErrorSnackBar(
    BuildContext context, 
    Object error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    // ✅ Check if context is valid before showing SnackBar
    if (!_isContextValid(context)) {
      debugPrint("⚠️ Context is not valid. Skipping SnackBar.");
      return;
    }

    final message = getMessage(error);
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: duration,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint("⚠️ Error showing SnackBar: $e");
    }
  }

  /// Shows a success SnackBar (for consistent UI)
  /// 
  /// Usage:
  /// ```dart
  /// ErrorHandler.showSuccessSnackBar(context, "Login successful!");
  /// ```
  static void showSuccessSnackBar(
    BuildContext context, 
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    // ✅ Check if context is valid before showing SnackBar
    if (!_isContextValid(context)) {
      debugPrint("⚠️ Context is not valid. Skipping SnackBar.");
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: duration,
        ),
      );
    } catch (e) {
      debugPrint("⚠️ Error showing SnackBar: $e");
    }
  }

  /// Shows a warning SnackBar
  /// 
  /// Usage:
  /// ```dart
  /// ErrorHandler.showWarningSnackBar(context, "Please complete your profile");
  /// ```
  static void showWarningSnackBar(
    BuildContext context, 
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    // ✅ Check if context is valid before showing SnackBar
    if (!_isContextValid(context)) {
      debugPrint("⚠️ Context is not valid. Skipping SnackBar.");
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: duration,
        ),
      );
    } catch (e) {
      debugPrint("⚠️ Error showing SnackBar: $e");
    }
  }

  /// Shows an info SnackBar
  /// 
  /// Usage:
  /// ```dart
  /// ErrorHandler.showInfoSnackBar(context, "New update available");
  /// ```
  static void showInfoSnackBar(
    BuildContext context, 
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    // ✅ Check if context is valid before showing SnackBar
    if (!_isContextValid(context)) {
      debugPrint("⚠️ Context is not valid. Skipping SnackBar.");
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: duration,
        ),
      );
    } catch (e) {
      debugPrint("⚠️ Error showing SnackBar: $e");
    }
  }

  /// Logs error for debugging (only in debug mode)
  static void logError(Object error, [StackTrace? stackTrace]) {
    debugPrint("═══════════════════════════════════════");
    debugPrint("🔴 ERROR CAUGHT:");
    debugPrint("Error: $error");
    if (stackTrace != null) {
      debugPrint("StackTrace: $stackTrace");
    }
    debugPrint("═══════════════════════════════════════");
  }
}
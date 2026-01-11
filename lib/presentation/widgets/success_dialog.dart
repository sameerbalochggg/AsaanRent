import 'package:flutter/material.dart';

/// ✅ Reusable Success Dialog Component
/// Shows a green checkmark with auto-dismiss
class SuccessDialog {
  /// Shows success dialog with custom message
  /// 
  /// Usage:
  /// ```dart
  /// SuccessDialog.show(
  ///   context: context,
  ///   title: 'Success!',
  ///   message: 'Property marked as rented',
  /// );
  /// ```
  static void show({
    required BuildContext context,
    String title = 'Success!',
    required String message,
    Duration autoCloseDuration = const Duration(seconds: 2),
    Color? primaryColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Auto-close after specified duration
        Future.delayed(autoCloseDuration, () {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Green checkmark circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor ?? Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ✅ Example usage in your "Mark as Rented" button
/// 
/// Add this to wherever you have the "Mark as Rented" functionality:
/// 
/// ```dart
/// ElevatedButton(
///   onPressed: () async {
///     // Your existing mark as rented logic here
///     await markPropertyAsRented();
///     
///     // Show success dialog
///     if (mounted) {
///       SuccessDialog.show(
///         context: context,
///         title: 'Success!',
///         message: 'Property marked as rented',
///       );
///     }
///   },
///   child: const Text('Mark as Rented'),
/// )
/// ```
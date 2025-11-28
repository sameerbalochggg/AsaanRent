import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ❌ --- REMOVED UNUSED IMPORT ---
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_application/data/repositories/auth_repository.dart';
import 'package:rent_application/presentation/auth/screens/login.dart';

// ✅ --- Import Widgets ---
import 'package:rent_application/presentation/auth/widgets/reset_password_header.dart';
import 'package:rent_application/presentation/auth/widgets/reset_password_form.dart';

// ✅ --- Import Error Handler ---
import 'package:rent_application/core/utils/error_handler.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();

  bool _loading = false;
  bool _updated = false;
  bool _isTyping = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onDone() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _loading = true);

    try {
      await _authRepository.updateUserPassword(_newPasswordController.text.trim());

      setState(() {
        _loading = false;
        _updated = true;
      });

      if (!mounted) return;
      
      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 72),
              const SizedBox(height: 12),
              Text(
                "Successful",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your password has been updated successfully",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      // ✅ Use centralized ErrorHandler for snackbars
      ErrorHandler.showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Reset Password"),
        elevation: 0,
        // AppBar colors are handled by main theme
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // ✅ 1. Header Widget
              ResetPasswordHeader(email: widget.email),

              const SizedBox(height: 30),

              // ✅ 2. Form Widget
              ResetPasswordForm(
                formKey: _formKey,
                newPasswordController: _newPasswordController,
                confirmPasswordController: _confirmPasswordController,
                isLoading: _loading,
                isUpdated: _updated,
                isTyping: _isTyping,
                onDone: _onDone,
                onTypingChanged: (value) => setState(() => _isTyping = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
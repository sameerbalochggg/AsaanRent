import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final bool isUpdated;
  final bool isTyping;
  final VoidCallback onDone;
  final ValueChanged<bool> onTypingChanged;

  const ResetPasswordForm({
    super.key,
    required this.formKey,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.isUpdated,
    required this.isTyping,
    required this.onDone,
    required this.onTypingChanged,
  });

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a password";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must include at least one uppercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must include at least one number";
    }
    if (!RegExp(r'[!@#\$%^&*(),.?\":{}|<>]').hasMatch(value)) {
      return "Password must include at least one special character";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != widget.newPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: widget.formKey,
          autovalidateMode: widget.isTyping
              ? AutovalidateMode.always
              : AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              // New Password
              TextFormField(
                controller: widget.newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                validator: _validatePassword,
                onChanged: (_) => widget.onTypingChanged(true),
              ),
              const SizedBox(height: 20),

              // Confirm Password
              TextFormField(
                controller: widget.confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: Icon(Icons.lock, color: theme.primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: _validateConfirmPassword,
                onChanged: (_) => widget.onTypingChanged(true),
              ),
              const SizedBox(height: 30),

              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: widget.isUpdated
                        ? Colors.grey
                        : theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (widget.isLoading || widget.isUpdated)
                      ? null
                      : widget.onDone,
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.isUpdated ? "Updated ✅" : "Done",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
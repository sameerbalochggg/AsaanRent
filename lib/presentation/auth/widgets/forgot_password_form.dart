import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController otpController;
  final bool isLoading;
  final bool otpSent;
  final int secondsRemaining;
  final VoidCallback onSendOtp;
  final VoidCallback onVerifyOtp;

  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.otpController,
    required this.isLoading,
    required this.otpSent,
    required this.secondsRemaining,
    required this.onSendOtp,
    required this.onVerifyOtp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // --- Email Input Row ---
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined, color: theme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.primaryColor, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        } else if (!value.contains("@")) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // --- Send OTP Button / Timer ---
                  secondsRemaining > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$secondsRemaining s",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 101, 90, 90),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.send, color: theme.primaryColor),
                          onPressed: isLoading ? null : onSendOtp,
                        ),
                ],
              ),
              
              const SizedBox(height: 25),

              // --- OTP Input & Verify Button (Conditional) ---
              if (otpSent) ...[
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter OTP",
                    prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the OTP";
                    } else if (value.length < 6) {
                      return "OTP must be at least 6 digits";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.primaryColor,
                    ),
                    onPressed: isLoading ? null : onVerifyOtp,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : Text(
                            "Verify OTP",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
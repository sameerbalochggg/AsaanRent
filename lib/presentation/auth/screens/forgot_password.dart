import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/core/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_application/core/images.dart';
import 'reset_password.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _loading = false;
  bool _otpSent = false;

  int _secondsRemaining = 0;
  Timer? _timer;

  /// ✅ OTP button now has a 90s countdown timer.
  void _startOtpTimer() {
    setState(() => _secondsRemaining = 90);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      }
    });
  }

  /// Send OTP to user email via Supabase
  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();

      // ✅ Send OTP to email
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: "rentapp://reset-callback/", // your deep link
      );

      setState(() => _otpSent = true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent to your email.")),
      );

      _startOtpTimer(); // start 90s countdown
    } on AuthException catch (error) {
      String errorMessage = "Something went wrong. Please try again.";
      final err = error.message.toLowerCase();

      if (err.contains("not found") || err.contains("invalid login")) {
        errorMessage = "This email is not registered. Please sign up first.";
      } else if (err.contains("network") || err.contains("socket")) {
        errorMessage = "Unable to connect. Please check your internet connection.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error. Try again.")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Verify OTP entered by user
  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter OTP code")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final otp = _otpController.text.trim();

      // ✅ Verify OTP
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        token: otp,
        email: email,
      );

      if (response.user != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP verified successfully!")),
        );

        // 👉 Navigate to Reset Password Page (with email passed)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: email),
          ),
        );
      }
    } on AuthException catch (error) {
      String errorMessage = "Something went wrong. Please try again.";
      final err = error.message.toLowerCase();

      if (err.contains("invalid") || err.contains("expired")) {
        errorMessage = "The OTP you entered is invalid or expired. Please request a new one.";
      } else if (err.contains("network") || err.contains("socket")) {
        errorMessage = "Unable to connect. Please check your internet connection.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error. Try again.")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF004D40),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Logo
              Image.asset(
                houseImg,
                height: 180,
              ),
              const SizedBox(height: 50),

              Text(
                "Enter your registered email below. We'll send you an OTP.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                            _secondsRemaining > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "$_secondsRemaining s",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color.fromARGB(255, 101, 90, 90),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.send,
                                        color: Color(0xFF004D40)),
                                    onPressed: _loading ? null : _sendOtp,
                                  ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        if (_otpSent) ...[
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Enter OTP",
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                backgroundColor: verifyOTPColor,
                              ),
                              onPressed: _loading ? null : _verifyOtp,
                              child: _loading
                                  ? const CircularProgressIndicator(color: Colors.white)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

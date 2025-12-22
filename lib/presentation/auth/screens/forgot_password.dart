import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rent_application/core/utils/error_handler.dart';
import 'package:rent_application/data/repositories/auth_repository.dart';
import 'package:rent_application/presentation/auth/screens/reset_password.dart';

// ✅ --- Import Widgets ---
import 'package:rent_application/presentation/auth/widgets/forgot_password_header.dart';
import 'package:rent_application/presentation/auth/widgets/forgot_password_form.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();

  bool _loading = false;
  bool _otpSent = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

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

  // ✅ UPDATED: Send OTP with enhanced ErrorHandler usage
  Future<void> _sendOtp() async {
    // Validation check
    if (_emailController.text.isEmpty || !_emailController.text.contains("@")) {
      // ✅ Use ErrorHandler's warning SnackBar
      ErrorHandler.showWarningSnackBar(
        context,
        "Please enter a valid email address",
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      final email = _emailController.text.trim();
      await _authRepository.sendPasswordResetOtp(email);

      setState(() => _otpSent = true);

      if (!mounted) return;
      
      // ✅ Use ErrorHandler's success SnackBar
      ErrorHandler.showSuccessSnackBar(
        context,
        "OTP sent to your email. Please check your inbox.",
      );

      _startOtpTimer();
    } catch (error) {
      // ✅ Use ErrorHandler for consistent error display
      ErrorHandler.logError(error); // Log for debugging
      
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ✅ UPDATED: Verify OTP with enhanced ErrorHandler usage
  Future<void> _verifyOtp() async {
    // Validation check
    if (_otpController.text.isEmpty) {
      // ✅ Use ErrorHandler's warning SnackBar
      ErrorHandler.showWarningSnackBar(
        context,
        "Please enter the OTP code",
      );
      return;
    }

    // Check OTP length (usually 6 digits)
    if (_otpController.text.trim().length < 6) {
      ErrorHandler.showWarningSnackBar(
        context,
        "OTP code must be 6 digits",
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      final email = _emailController.text.trim();
      final otp = _otpController.text.trim();

      await _authRepository.verifyPasswordResetOtp(email, otp);

      if (!mounted) return;
      
      // ✅ Use ErrorHandler's success SnackBar
      ErrorHandler.showSuccessSnackBar(
        context,
        "OTP verified successfully!",
      );

      // Navigate to reset password screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: email),
        ),
      );
      
    } catch (error) {
      // ✅ Use ErrorHandler for consistent error display
      ErrorHandler.logError(error); // Log for debugging
      
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Forgot Password"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // ✅ 1. Header
              const ForgotPasswordHeader(),
              
              const SizedBox(height: 30),

              // ✅ 2. Form
              ForgotPasswordForm(
                formKey: _formKey,
                emailController: _emailController,
                otpController: _otpController,
                isLoading: _loading,
                otpSent: _otpSent,
                secondsRemaining: _secondsRemaining,
                onSendOtp: _sendOtp,
                onVerifyOtp: _verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
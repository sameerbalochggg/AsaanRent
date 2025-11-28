import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/repositories/auth_repository.dart';

// ✅ --- Import New Widgets ---
import 'package:rent_application/presentation/auth/widgets/register_header.dart';
import 'package:rent_application/presentation/auth/widgets/register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _nameController.text.trim(),
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Registration Successful! Please check your email."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Back to login

    } catch (e) {
      String errorMessage = "Something went wrong. Please try again.";
      final errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains("email") && errorStr.contains("exists")) {
        errorMessage = "This email is already registered. Please login.";
      } else if (errorStr.contains("invalid email")) {
        errorMessage = "Please enter a valid email address.";
      } else if (errorStr.contains("password")) {
        errorMessage = "Password is too weak. Try a stronger one.";
      } else if (errorStr.contains("network") || errorStr.contains("socket")) {
        errorMessage = "Unable to connect. Please check your internet.";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // ✅ 1. Header Widget
              const RegisterHeader(),

              const SizedBox(height: 30),

              // ✅ 2. Form Widget
              RegisterForm(
                formKey: _formKey,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                isLoading: _isLoading,
                onRegister: _registerUser,
              ),

              const SizedBox(height: 20),

              // ✅ 3. Login Link (Footer)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // go back to LoginPage
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/presentation/auth/screens/register.dart'; 

// 🔹 Import your Home & Admin Pages
import 'package:asaan_rent/presentation/home/screens/home_screen.dart';
import 'package:asaan_rent/presentation/admin/screens/admin_dashboard_screen.dart';

// ✅ --- REPOSITORY IMPORTS ---
import 'package:asaan_rent/data/repositories/auth_repository.dart';
import 'package:asaan_rent/data/repositories/profile_repository.dart';

// ✅ --- WIDGET IMPORTS ---
import 'package:asaan_rent/presentation/auth/widgets/login_header.dart';
import 'package:asaan_rent/presentation/auth/widgets/login_form.dart';

// ✅ --- ERROR HANDLER IMPORT ---
import 'package:asaan_rent/core/utils/error_handler.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ✅ Initialize Repositories
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Sign In via Auth Repository
      await _authRepository.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Fetch Profile to Check Role
      final profile = await _profileRepository.getProfile();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );

      // ✅ 3. ROLE-BASED REDIRECTION
      if (profile != null && profile.role == 'admin') {
        // Redirect Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        // Redirect Normal User
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }

    } catch (e) {
      // ✅ USE ERROR HANDLER INSTEAD OF MANUAL ERROR CHECKING
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(context, e);
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
              const LoginHeader(),
              
              const SizedBox(height: 30),

              // ✅ 2. Form Widget
              LoginForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                isLoading: _isLoading,
                onLogin: _loginUser,
              ),
              
              const SizedBox(height: 20),

              // ✅ 3. Register Link (Simple enough to keep here)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    child: Text(
                      "Register",
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
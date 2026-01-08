import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/core/images.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          houseImg,
          height: 110,
        ),
        const SizedBox(height: 15),
        Text(
          "Create Account",
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Register to get started",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
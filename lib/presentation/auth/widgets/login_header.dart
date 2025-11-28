import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/core/images.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

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
          "Welcome To AssanRent",
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Login to continue",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
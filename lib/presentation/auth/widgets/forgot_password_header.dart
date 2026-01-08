import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/core/images.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
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
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
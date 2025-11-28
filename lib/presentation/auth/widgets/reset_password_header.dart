import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordHeader extends StatelessWidget {
  final String email;

  const ResetPasswordHeader({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          "Resetting password for:",
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
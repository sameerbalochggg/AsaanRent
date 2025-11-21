import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF004D40), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF004D40),
          ),
        ),
      ],
    );
  }
}

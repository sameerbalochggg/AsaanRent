import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactFieldsWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final String selectedCountryCode;
  final ValueChanged<String?> onCountryCodeChanged;

  const ContactFieldsWidget({
    super.key,
    required this.phoneController,
    required this.emailController,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 110,
              decoration: _cardDecoration(),
              child: DropdownButtonFormField<String>(
                value: selectedCountryCode,
                decoration: _inputDecoration("Code"),
                items: ["+92", "+91", "+1", "+44", "+971"]
                    .map((code) => DropdownMenuItem(value: code, child: Text(code)))
                    .toList(),
                onChanged: onCountryCodeChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: _cardDecoration(),
                child: TextFormField(
                  controller: phoneController,
                  // ✅ Added hintText here
                  decoration: _inputDecoration(
                    "Phone Number", 
                    icon: Icons.phone, 
                    hintText: "e.g 3232635195",
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.isEmpty ? "Enter phone number" : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(),
          child: TextFormField(
            controller: emailController,
            readOnly: true,
            decoration: _inputDecoration("Email", icon: Icons.email),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ✅ Updated to accept optional hintText
  InputDecoration _inputDecoration(String label, {IconData? icon, String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText, // ✅ Shows the example text inside the field
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
      labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF004D40), size: 20)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF004D40), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
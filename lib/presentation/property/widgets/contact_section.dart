import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatelessWidget {
  final String ownerName;
  final String phoneNumber;
  final String email;

  const ContactSection({
    super.key,
    required this.ownerName,
    required this.phoneNumber,
    required this.email,
  });

  Future<void> _launchCaller(String number) async {
    final sanitized = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri url = Uri(scheme: 'tel', path: sanitized);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String emailAddress) async {
    final Uri url = Uri(scheme: 'mailto', path: emailAddress);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchWhatsApp(String number) async {
    final sanitized = number.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrl = Uri.parse(
        "whatsapp://send?phone=$sanitized&text=Hello, I'm interested in your property");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      final webUrl = Uri.parse(
          "https://wa.me/$sanitized?text=Hello, I'm interested in your property");
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF00695C)],
              ),
            ),
            child: Text(
              "Contact Owner",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Owner Name
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF004D40),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ownerName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Phone Number
                if (phoneNumber.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone,
                          color: Color(0xFF004D40), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phoneNumber,
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                if (phoneNumber.isNotEmpty) const SizedBox(height: 8),

                // Email
                if (email.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.email,
                          color: Color(0xFF004D40), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (phoneNumber.isNotEmpty)
                      _buildIconButton(
                        icon: Icons.call,
                        label: 'Call',
                        color: const Color(0xFF004D40),
                        onTap: () => _launchCaller(phoneNumber),
                      ),
                    if (email.isNotEmpty)
                      _buildIconButton(
                        icon: Icons.email,
                        label: 'Email',
                        color: const Color(0xFF004D40),
                        onTap: () => _launchEmail(email),
                      ),
                    if (phoneNumber.isNotEmpty)
                      _buildIconButton(
                        icon: FontAwesomeIcons.whatsapp,
                        label: 'WhatsApp',
                        color: const Color(0xFF004D40),
                        onTap: () => _launchWhatsApp(phoneNumber),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color,
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 22),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
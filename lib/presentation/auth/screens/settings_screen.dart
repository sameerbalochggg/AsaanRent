import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/presentation/auth/screens/forgot_password.dart'; // ✅ Import your Reset Password Page

// --- App Color Scheme ---
const kPrimaryColor = Color(0xFF004D40);
const kScaffoldBgColor = Color(0xFFF8F9FA); // Light grey background
const kDestructiveColor = Colors.red;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables for toggles
  bool _notificationsOn = true;
  bool _darkModeOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkModeOn ? Colors.black : kScaffoldBgColor,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        children: [
          // --- Account Section ---
          _buildSectionHeader("Account"),
          _buildSettingItem(
            context,
            icon: Icons.lock_outline,
            title: "Change Password",
            subtitle: "Update your login password",
            onTap: () {
              // ✅ Navigate to Reset Password Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.delete_outline,
            title: "Delete Account",
            subtitle: "Permanently delete your account",
            isDestructive: true,
            onTap: () {
              // TODO: Show confirmation dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Show Delete Account Dialog')),
              );
            },
          ),

          // --- Preferences Section ---
          _buildSectionHeader("Preferences"),
          _buildSwitchItem(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            subtitle: "Receive push notifications",
            value: _notificationsOn,
            onChanged: (newValue) {
              setState(() {
                _notificationsOn = newValue;
              });
            },
          ),
          _buildSwitchItem(
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            subtitle: "Enable dark theme",
            value: _darkModeOn,
            onChanged: (newValue) {
              setState(() {
                _darkModeOn = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  // --- Section Header Widget ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: kPrimaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // --- Setting Item (e.g., Change Password) ---
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? kDestructiveColor : (_darkModeOn ? Colors.white : Colors.black87);
    final iconColor = isDestructive ? kDestructiveColor : (_darkModeOn ? Colors.white70 : Colors.grey[700]);

    return Container(
      color: _darkModeOn ? Colors.grey[900] : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: _darkModeOn ? Colors.grey[400] : Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // --- Switch Item (e.g., Dark Mode, Notifications) ---
  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: _darkModeOn ? Colors.grey[900] : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: _darkModeOn ? Colors.white70 : Colors.grey[700]),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: _darkModeOn ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: _darkModeOn ? Colors.grey[400] : Colors.grey[600]),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: kPrimaryColor,
        ),
      ),
    );
  }
}

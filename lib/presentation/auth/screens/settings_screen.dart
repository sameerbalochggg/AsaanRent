import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 
import 'package:asaan_rent/presentation/providers/theme_provider.dart'; 
import 'package:asaan_rent/core/theme.dart'; 

// ✅ --- Added Import for Forgot Password Page ---
import 'package:asaan_rent/presentation/auth/screens/forgot_password.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage(),
                ),
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
            value: isDarkMode,
            onChanged: (newValue) {
              context.read<ThemeProvider>().toggleTheme(newValue);
            },
          ),
        ],
      ),
    );
  }

  // Helper widget for section headers
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

  // Helper widget for standard settings items
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? kDestructiveColor : theme.textTheme.bodyLarge?.color;
    final iconColor = isDestructive ? kDestructiveColor : Colors.grey[700];

    return Container(
      color: theme.cardColor,
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
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Helper widget for settings items with a toggle switch
  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color, 
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.grey[600]),
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
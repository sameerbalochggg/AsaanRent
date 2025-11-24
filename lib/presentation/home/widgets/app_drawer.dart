import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// ✅ Repository & Auth Imports
import 'package:rent_application/data/repositories/auth_repository.dart';
import 'package:rent_application/presentation/auth/screens/login.dart';

// ✅ Screen Imports
import 'package:rent_application/presentation/property/screens/my_property_list_screen.dart';
import 'package:rent_application/presentation/property/screens/add_property_screen.dart';
import 'package:rent_application/presentation/profile/screens/profile_screen.dart';
import 'package:rent_application/presentation/auth/screens/settings_screen.dart';

// ✅ Provider Import
import 'package:rent_application/presentation/providers/profile_provider.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onPropertyAdded;
  const AppDrawer({super.key, required this.onPropertyAdded});

  // Helper method for navigation
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Logout', style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?',
                    style: GoogleFonts.poppins()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.poppins()),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Logout',
                  style: GoogleFonts.poppins(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog

                try {
                  await AuthRepository().signOut();

                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Logout failed: $e"),
                        backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _shareApp(BuildContext context) {
    Navigator.pop(context);

    const String appLink =
        "https://play.google.com/store/apps/details?id=com.yourapp.id";
    final String shareText =
        "Check out AsaanRent, the best app for finding rentals in Balochistan!\n\n$appLink";

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color ?? Colors.black54;

    return Drawer(
      backgroundColor: theme.cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ✅ Separated Header to prevent unnecessary rebuilds
          const _DrawerHeader(),
          
          _DrawerTile(
            icon: Icons.home_outlined,
            title: "Home",
            iconColor: iconColor,
            onTap: () => Navigator.pop(context),
          ),
          
          _DrawerTile(
            icon: Icons.person_outline,
            title: "My Profile",
            iconColor: iconColor,
            onTap: () => _navigateTo(context, const ProfileScreen()),
          ),
          
          _DrawerTile(
            icon: Icons.favorite_border,
            title: "My Favorites",
            iconColor: iconColor,
            onTap: () {
              debugPrint("Navigate to Favorites");
              Navigator.pop(context);
            },
          ),
          
          const Divider(),
          
          _DrawerSectionHeader(text: "My Rentals"),
          
          _DrawerTile(
            icon: Icons.add_business_outlined,
            title: "My Property List",
            iconColor: iconColor,
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyPropertyListPage(),
                ),
              );
              onPropertyAdded();
            },
          ),
          
          _DrawerTile(
            icon: Icons.add_business_outlined,
            title: "Add New Property",
            iconColor: iconColor,
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPropertyScreen(),
                ),
              );
              if (result == true) {
                onPropertyAdded();
              }
            },
          ),
          
          const Divider(),
          
          _DrawerTile(
            icon: Icons.settings_outlined,
            title: "Settings",
            iconColor: iconColor,
            onTap: () => _navigateTo(context, const SettingsScreen()),
          ),
          
          _DrawerTile(
            icon: Icons.support_agent_outlined,
            title: "Help & Support",
            iconColor: iconColor,
            onTap: () {
              Navigator.pop(context);
              debugPrint("Navigate to Help & Support");
            },
          ),
          
          _DrawerTile(
            icon: Icons.info_outline,
            title: "About App",
            iconColor: iconColor,
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: "AsaanRent",
                applicationVersion: "1.0.0",
                applicationIcon: Icon(Icons.house,
                    size: 40, color: theme.primaryColor),
                applicationLegalese: "© 2025 AsaanRent. All rights reserved.",
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Your one-stop solution for finding and listing rental properties.",
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
              );
            },
          ),
          
          _DrawerTile(
            icon: Icons.share_outlined,
            title: "Share App",
            iconColor: iconColor,
            onTap: () => _shareApp(context),
          ),
          
          const Divider(),
          
          _DrawerTile(
            icon: Icons.logout,
            title: "Logout",
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}

// ✅ --- SEPARATED DRAWER HEADER WIDGET ---
// This prevents the entire drawer from rebuilding when only user data changes
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // ✅ Use Selector to only rebuild when specific fields change
    return Selector<ProfileProvider, _ProfileData>(
      selector: (_, provider) => _ProfileData(
        displayName: provider.displayName,
        email: provider.email,
        avatarUrl: provider.avatarUrl,
        isLoading: provider.isLoading,
      ),
      builder: (context, profileData, child) {
        return UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            color: theme.primaryColor,
          ),
          accountName: Text(
            profileData.isLoading ? "Loading..." : profileData.displayName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          accountEmail: Text(
            profileData.isLoading ? "..." : profileData.email,
            style: GoogleFonts.poppins(),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: (profileData.avatarUrl != null &&
                    profileData.avatarUrl!.isNotEmpty)
                ? NetworkImage(profileData.avatarUrl!)
                : null,
            child: (profileData.avatarUrl == null ||
                    profileData.avatarUrl!.isEmpty)
                ? Icon(
                    Icons.person,
                    size: 40,
                    color: theme.primaryColor,
                  )
                : null,
          ),
        );
      },
    );
  }
}

// ✅ --- DATA CLASS FOR SELECTOR ---
// Only rebuild when these specific fields change
class _ProfileData {
  final String displayName;
  final String email;
  final String? avatarUrl;
  final bool isLoading;

  _ProfileData({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.isLoading,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProfileData &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          email == other.email &&
          avatarUrl == other.avatarUrl &&
          isLoading == other.isLoading;

  @override
  int get hashCode =>
      displayName.hashCode ^
      email.hashCode ^
      avatarUrl.hashCode ^
      isLoading.hashCode;
}

// ✅ --- REUSABLE DRAWER TILE WIDGET ---
// Prevents rebuilding of individual tiles
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: titleColor,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ✅ --- REUSABLE SECTION HEADER WIDGET ---
class _DrawerSectionHeader extends StatelessWidget {
  final String text;

  const _DrawerSectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
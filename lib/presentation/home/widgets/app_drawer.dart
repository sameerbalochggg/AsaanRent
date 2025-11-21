import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/repositories/auth_repository.dart';
import 'package:rent_application/presentation/auth/screens/login.dart';
import 'package:rent_application/presentation/property/screens/my_property_list_screen.dart';
import 'package:rent_application/presentation/property/screens/add_property_screen.dart';
import 'package:rent_application/presentation/profile/screens/profile_screen.dart';
import 'package:rent_application/presentation/auth/screens/settings_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
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
                Navigator.of(dialogContext).pop();

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
     
     const String appLink = "https://play.google.com/store/apps/details?id=com.yourapp.id"; 
     final String shareText = "Check out AsaanRent, the best app for finding rentals in Balochistan!\n\n$appLink";

     Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color ?? Colors.black54;
    final profileProvider = context.watch<ProfileProvider>();

    return Drawer(
      // ✅ Use the theme's card color for the drawer background
      backgroundColor: Theme.of(context).cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            // ✅ Use theme color
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            accountName: Text(
              profileProvider.isLoading ? "Loading..." : profileProvider.displayName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              profileProvider.isLoading ? "..." : profileProvider.email,
              style: GoogleFonts.poppins(),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (profileProvider.avatarUrl != null &&
                      profileProvider.avatarUrl!.isNotEmpty)
                  ? NetworkImage(profileProvider.avatarUrl!)
                  : null,
              child: (profileProvider.avatarUrl == null ||
                      profileProvider.avatarUrl!.isEmpty)
                  ? Icon(
                      Icons.person,
                      size: 40,
                      // ✅ Use theme color
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home_outlined, color: iconColor),
            title: Text("Home", style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person_outline, color: iconColor),
            title: Text("My Profile", style: GoogleFonts.poppins()),
            onTap: () {
              _navigateTo(context, const ProfileScreen());
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite_border, color: iconColor),
            title: Text("My Favorites", style: GoogleFonts.poppins()),
            onTap: () {
              debugPrint("Navigate to Favorites (screen not created)");
              Navigator.pop(context);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text(
              "My Rentals",
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add_business_outlined, color: iconColor),
            title: Text("My Property List", style: GoogleFonts.poppins()),
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
          ListTile(
            leading: Icon(Icons.add_business_outlined, color: iconColor),
            title: Text("Add New Property", style: GoogleFonts.poppins()),
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
          ListTile(
            leading: Icon(Icons.settings_outlined, color: iconColor),
            title: Text("Settings", style: GoogleFonts.poppins()),
            onTap: () {
               _navigateTo(context, const SettingsScreen());
            },
          ),
          ListTile(
            leading: Icon(Icons.support_agent_outlined, color: iconColor),
            title: Text("Help & Support", style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              debugPrint("Navigate to Help & Support");
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: Text("About App", style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: "AsaanRent",
                applicationVersion: "1.0.0",
                applicationIcon: Icon(Icons.house,
                    size: 40, color: Theme.of(context).primaryColor),
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
          ListTile(
            leading: Icon(Icons.share_outlined, color: iconColor),
            title: Text("Share App", style: GoogleFonts.poppins()),
            onTap: () => _shareApp(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(color: Colors.red),
            ),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
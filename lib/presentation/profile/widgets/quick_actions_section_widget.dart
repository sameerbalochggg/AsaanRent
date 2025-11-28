import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ✅ --- Navigation Imports ---
import 'package:rent_application/presentation/property/screens/my_property_list_screen.dart';
import 'package:rent_application/presentation/home/screens/favourite_tab_screen.dart';
import 'package:rent_application/presentation/auth/screens/settings_screen.dart';

class QuickActionsSectionWidget extends StatelessWidget {
  const QuickActionsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickActionCard(
              icon: FontAwesomeIcons.houseUser,
              label: "My Listings",
              onTap: () {
                // ✅ Navigate to My Listings
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyPropertyListPage(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            _QuickActionCard(
              icon: FontAwesomeIcons.heart,
              label: "Favorites",
              onTap: () {
                // ✅ Navigate to Favorites
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesTabScreen(),
                  ),
                );
              },
            ),
            // ❌ --- REMOVED Payments Button ---
            const SizedBox(width: 8),
            _QuickActionCard(
              icon: FontAwesomeIcons.gear,
              label: "Settings",
              onTap: () {
                // ✅ Navigate to Settings
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1.5,
        color: theme.cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(icon, color: theme.primaryColor, size: 20),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
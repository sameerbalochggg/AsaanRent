import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/data/models/property_model.dart';

class SearchResultCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ --- Get theme-aware colors ---
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subtitleColor = theme.textTheme.bodySmall?.color;

    final imageUrl = (property.images != null && property.images!.isNotEmpty)
        ? property.images![0]
        : null;

    return InkWell(
      onTap: onTap,
      child: Card(
        color: cardColor, // Use theme card color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl ?? 'https://placehold.co/150x150/grey/white?text=No+Image',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: theme.dividerColor.withOpacity(0.1),
                  child: Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
          title: Text(
            property.displayName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: textColor, // Use theme text color
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                property.displayLocation,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: subtitleColor, // Use theme subtitle color
                ),
              ),
              const SizedBox(height: 4),
              Text(
                property.displayPrice,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: primaryColor, // Use theme primary color
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.home_work_outlined,
            color: primaryColor, // Use theme primary color
            size: 28,
          ),
        ),
      ),
    );
  }
}
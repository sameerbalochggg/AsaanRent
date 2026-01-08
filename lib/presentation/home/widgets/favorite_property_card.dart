import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/data/models/property_model.dart';
import 'package:asaan_rent/core/theme.dart';
import 'package:asaan_rent/presentation/property/screens/property_details_screen.dart'; // ✅ Add this import

class FavoritesPropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onRemove;
  final VoidCallback? onTap; // ✅ Optional callback for custom navigation

  const FavoritesPropertyCard({
    super.key,
    required this.property,
    required this.onRemove,
    this.onTap, // ✅ Added optional parameter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell( // ✅ Wrapped with InkWell for tap functionality
      onTap: onTap ?? () {
        // ✅ Navigate to PropertyDetailsPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsPage(
              propertyId: property.id, // ✅ Pass the String UUID
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16), // ✅ Match card border radius
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: isDark ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: theme.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: (property.images != null && property.images!.isNotEmpty)
                      ? Image.network(
                          property.images!.first,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(context);
                          },
                        )
                      : _buildPlaceholderImage(context),
                ),
                // Remove from Favorites Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remove from favorites'),
                            content: const Text(
                              'Are you sure you want to remove this property from your favorites?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onRemove();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: kDestructiveColor,
                                ),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Rental Status Badge
                if (property.isRented)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'RENTED',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Property Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Text(
                        property.displayPrice,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.displayLocation,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
      child: Icon(
        Icons.home,
        size: 64,
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
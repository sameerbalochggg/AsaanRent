import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/data/models/property_model.dart';

class PropertyInfoCard extends StatelessWidget {
  final Property property;

  const PropertyInfoCard({super.key, required this.property});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Map<String, bool> _getFeatures(Property property) {
    return {
      "Kitchen": property.kitchen ?? false,
      "Parking": property.parking ?? false,
      "Furnished": property.furnished ?? false,
      "Electricity": property.electricity ?? false,
      "Water": property.water ?? false,
      "Gas": property.gas ?? false,
      "AC": property.ac ?? false,
      "Balcony": property.balcony ?? false,
      "Garden": property.garden ?? false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final features = _getFeatures(property);
    final activeFeatures = features.entries.where((f) => f.value).toList();

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12), // Removed top margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ❌ --- ALL THIS WAS REMOVED as it's now in PropertyHeaderCard ---
            // Text(property.displayName, ...),
            // Text(property.displayPrice, ...),
            // const Divider(height: 24),
            // Row(...), // Area
            // const SizedBox(height: 12),
            // Row(...), // Bedrooms & Bathrooms
            // const Divider(height: 24),
            // Row(...), // Location
            // const Divider(height: 24),

            // --- This is all that's left, which is correct ---

            // Description
            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              property.displayDescription,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            // Facilities
            if (activeFeatures.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Facilities',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: activeFeatures.map((f) {
                  return Chip(
                    avatar: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF004D40),
                      size: 18,
                    ),
                    label: Text(
                      f.key,
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    backgroundColor: const Color(0xFF004D40).withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],

            // Posted Date
            if (property.createdAt != null) ...[
              const Divider(height: 24),
              Text(
                'Posted on: ${_formatDate(property.createdAt)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
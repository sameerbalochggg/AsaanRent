import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/data/models/property_model.dart';

class PropertyFeaturesGrid extends StatelessWidget {
  final Property property;
  const PropertyFeaturesGrid({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.hotel_outlined,
        'label': 'Bedrooms',
        'value': property.bedrooms?.toString() ?? 'N/A',
      },
      {
        'icon': Icons.bathtub_outlined,
        'label': 'Bathrooms',
        'value': property.bathrooms?.toString() ?? 'N/A',
      },
      {
        'icon': Icons.square_foot_outlined,
        'label': 'Area',
        'value': property.area != null ? '${property.area.toString()} sqft' : 'N/A',
      },
      {
        'icon': Icons.home_work_outlined,
        'label': 'Type',
        'value': property.propertyType ?? 'N/A',
      },
    ];

    final relevantFeatures = features
        .where((f) => f['value'] != 'N/A' && f['value'] != '0' && f['value'] != null)
        .toList();

    if (relevantFeatures.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Features',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: relevantFeatures.length == 1 ? 1 : 2,
              // ✅ --- THIS IS THE FIX ---
              // A smaller number makes the box TALLER.
              childAspectRatio: 1.5, // Was 1.9, which was too wide
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: relevantFeatures.length,
            itemBuilder: (context, index) {
              final feature = relevantFeatures[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF004D40).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF004D40).withOpacity(0.1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: const Color(0xFF004D40),
                      size: 28,
                    ),
                    const SizedBox(height: 8), 
                    
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${feature['value']} ", 
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF004D40),
                            ),
                          ),
                          TextSpan(
                            text: feature['label'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
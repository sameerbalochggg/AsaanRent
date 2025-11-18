import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/presentation/property/screens/property_detail_tabs_screen.dart';

class MyPropertyCard extends StatelessWidget {
  final Property property;
  final Function(Property) onUpdate;
  final VoidCallback onDelete;

  const MyPropertyCard({
    Key? key,
    required this.property,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardColor = theme.cardColor;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor, 
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailTabsScreen(
                // ✅ --- FIX: Pass the String id ---
                propertyId: property.id, 
                onUpdate: onUpdate,
                onDelete: onDelete,
              ),
            ),
          );

          if (result == true) {
            onUpdate(property);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        if (property.displayLocation.isNotEmpty)
                          Text(
                            property.displayLocation,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: property.isRented
                          ? Colors.orange[100]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.isRented ? 'RENTED' : 'AVAILABLE',
                      style: GoogleFonts.poppins(
                        color: property.isRented
                            ? Colors.orange[900]
                            : Colors.green[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                property.displayPrice,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              if (property.area != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Area: ${property.area}', // ✅ Use String 'area'
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
              if (property.bedrooms != null || property.bathrooms != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (property.bedrooms != null) ...[
                      Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${property.bedrooms} Bed',
                          style: GoogleFonts.poppins(color: Colors.grey[600])),
                      const SizedBox(width: 16),
                    ],
                    if (property.bathrooms != null) ...[
                      Icon(Icons.bathtub, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${property.bathrooms} Bath',
                          style: GoogleFonts.poppins(color: Colors.grey[600])),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.arrow_forward, size: 16, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to view details',
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
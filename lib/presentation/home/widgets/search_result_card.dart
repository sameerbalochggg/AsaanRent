import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/property_model.dart';

class SearchResultCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF004D40);

  @override
  Widget build(BuildContext context) {
    final imageUrl = (property.images != null && property.images!.isNotEmpty)
        ? property.images![0]
        : null;

    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white, // Card background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shadowColor: Colors.grey.withOpacity(0.2),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl ?? 'https://via.placeholder.com/150', // Placeholder
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          title: Text(
            property.displayName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs ${property.price ?? 0}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          trailing: const Icon(
            Icons.home_work_outlined,
            color: primaryColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}
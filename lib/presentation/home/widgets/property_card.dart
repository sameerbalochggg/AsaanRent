import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asaan_rent/data/models/property_model.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (property.images != null && property.images!.isNotEmpty)
        ? property.images![0]
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF004D40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl != null
                ? Image.network(imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          height: 100,
                          color: Colors.grey[300],
                          child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 40, color: Colors.grey)),
                        ))
                : Container(
                    height: 100,
                    color: const Color(0xFF004D40),
                    child: const Center(
                        child: Icon(Icons.image,
                            size: 40, color: Color(0xFF004D40))),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.displayName, // ✅ Use Model
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                const SizedBox(height: 4),
                Text("Rs ${property.price ?? 0}", // ✅ Use Model
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Color.fromARGB(255, 245, 244, 247))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Color.fromARGB(255, 196, 194, 194)),
                    Expanded(
                      child: Text(property.displayLocation, // ✅ Use Model
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Color.fromARGB(255, 196, 194, 194))),
                    ),
                    const Icon(Icons.favorite_border,
                        size: 18, color: Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
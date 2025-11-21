import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class MapSelectorWidget extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? selectedLocationName;
  final VoidCallback onTap;

  const MapSelectorWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.selectedLocationName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: latitude != null ? const Color(0xFF004D40) : Colors.grey[300]!,
            width: latitude != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF004D40).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.map,
                color: Color(0xFF004D40),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    latitude != null ? "Location Selected" : "Select on Map",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: latitude != null
                          ? const Color(0xFF004D40)
                          : Colors.grey[700],
                    ),
                  ),
                  if (latitude != null)
                    Text(
                      selectedLocationName ??
                          "Lat: ${latitude!.toStringAsFixed(4)}, Lng: ${longitude!.toStringAsFixed(4)}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              latitude != null ? Icons.check_circle : Icons.arrow_forward_ios,
              color: latitude != null ? Colors.green : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
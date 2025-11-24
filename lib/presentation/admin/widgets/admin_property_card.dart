import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_application/data/models/property_model.dart';

class AdminPropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onVerifyToggle;
  final VoidCallback onDelete;

  const AdminPropertyCard({
    super.key,
    required this.property,
    required this.onVerifyToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        // --- Image ---
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (property.images != null && property.images!.isNotEmpty)
              ? Image.network(
                  property.images!.first,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
        
        // --- Title & Status ---
        title: Row(
          children: [
            Expanded(
              child: Text(
                property.displayName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // ✅ Verification Icon
            if (property.isVerified)
              const Icon(Icons.verified, size: 16, color: Colors.blue)
          ],
        ),
        
        // --- Details ---
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              property.displayLocation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            // ✅ Owner Name (Fixed logic: uses getter which maps to username)
            Text(
               "Owner: ${property.displayOwnerName}", 
               style: GoogleFonts.poppins(
                 fontSize: 11, 
                 fontWeight: FontWeight.w500,
                 color: theme.primaryColor,
               ),
            ),
            const SizedBox(height: 8),
            // --- Admin Actions ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Verification Button
                OutlinedButton.icon(
                  onPressed: onVerifyToggle,
                  icon: Icon(
                    property.isVerified ? Icons.close : Icons.check,
                    size: 16,
                    color: property.isVerified ? Colors.orange : Colors.green,
                  ),
                  label: Text(
                    property.isVerified ? "Unverify" : "Verify",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: property.isVerified ? Colors.orange : Colors.green,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: BorderSide(
                      color: property.isVerified ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Property?"),
                        content: const Text("This action cannot be undone."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
      child: const Icon(Icons.home, color: Colors.grey),
    );
  }
}
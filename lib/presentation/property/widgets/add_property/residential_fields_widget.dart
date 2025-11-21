import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class ResidentialFieldsWidget extends StatelessWidget {
  final TextEditingController areaController;
  final String? bedrooms;
  final String? bathrooms;
  final Map<String, bool> facilities;
  final ValueChanged<String?> onBedroomsChanged;
  final ValueChanged<String?> onBathroomsChanged;
  final Function(String, bool) onFacilityChanged;

  const ResidentialFieldsWidget({
    super.key,
    required this.areaController,
    required this.bedrooms,
    required this.bathrooms,
    required this.facilities,
    required this.onBedroomsChanged,
    required this.onBathroomsChanged,
    required this.onFacilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: _cardDecoration(),
          child: TextFormField(
            controller: areaController,
            decoration: _inputDecoration("Area (Sq Yards/Marla)", icon: Icons.square_foot),
            validator: (val) => val!.isEmpty ? "Enter property area" : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: _cardDecoration(),
                child: DropdownButtonFormField<String>(
                  value: bedrooms,
                  decoration: _inputDecoration("Bedrooms", icon: Icons.bed),
                  items: ["1", "2", "3", "4", "5+"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onBedroomsChanged,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: _cardDecoration(),
                child: DropdownButtonFormField<String>(
                  value: bathrooms,
                  decoration: _inputDecoration("Bathrooms", icon: Icons.bathtub),
                  items: ["1", "2", "3", "4", "5+"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onBathroomsChanged,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _FacilitiesSection(
          facilities: facilities,
          onFacilityChanged: onFacilityChanged,
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF004D40), size: 20)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF004D40), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _FacilitiesSection extends StatelessWidget {
  final Map<String, bool> facilities;
  final Function(String, bool) onFacilityChanged;

  const _FacilitiesSection({
    required this.facilities,
    required this.onFacilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Facilities & Amenities",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: facilities.keys.map((facilityKey) {
              String displayLabel = facilityKey == "ac"
                  ? "AC"
                  : facilityKey[0].toUpperCase() + facilityKey.substring(1);
              return FilterChip(
                label: Text(displayLabel),
                selected: facilities[facilityKey]!,
                selectedColor: const Color(0xFF004D40),
                checkmarkColor: Colors.white,
                backgroundColor: Colors.grey[100],
                labelStyle: GoogleFonts.poppins(
                  color: facilities[facilityKey]! ? Colors.white : Colors.grey[700],
                  fontWeight: facilities[facilityKey]! ? FontWeight.w600 : FontWeight.w400,
                ),
                onSelected: (selected) => onFacilityChanged(facilityKey, selected),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
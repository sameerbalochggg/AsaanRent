import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng selectedPoint = const LatLng(25.9936, 63.0710); // Default: Turbat

  @override
  Widget build(BuildContext context) {
    const String apiKey = "ra3XW7aUWbDkcll0N9Tq"; // ✅ Your MapTiler API key

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40), // ✅ Custom color
        iconTheme: const IconThemeData(color: Colors.white), // ✅ Back arrow white
        title: const Text(
          "Pick Location",
          style: TextStyle(color: Colors.white), // ✅ Title white
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: selectedPoint,
              initialZoom: 13,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedPoint = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey",
                userAgentPackageName: 'com.example.myapp',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedPoint,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFF004D40),
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ✅ Floating Done button at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF004D40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Return lat/lng values to previous screen
                Navigator.pop(context, {
                  "latitude": selectedPoint.latitude,
                  "longitude": selectedPoint.longitude,
                });
              },
              child: Text(
                "Done (Lat: ${selectedPoint.latitude.toStringAsFixed(4)}, "
                "Lng: ${selectedPoint.longitude.toStringAsFixed(4)})",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
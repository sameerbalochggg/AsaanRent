import 'package:flutter/material.dart'; // Added for debugPrint

// ❌ --- REMOVED ---
// import 'earning_model.dart';
// import 'rental_record_model.dart';

class Property {
  final String id;
  final String? ownerId;
  final String? propertyType;
  final String? location;
  final double? price;
  final double? area; // ✅ --- MODIFIED: This is now double? ---
  final int? bedrooms;
  final int? bathrooms;
  final bool? kitchen;
  final bool? parking;
  final bool? furnished;
  final bool? electricity;
  final bool? water;
  final bool? gas;
  final bool? ac;
  final bool? balcony;
  final bool? garden;
  final String? description;
  final String? phone;
  final String? email;
  final List<String>? images;
  final double? latitude;
  final double? longitude;
  final bool isRented;
  final DateTime? createdAt;

  Property({
    required this.id,
    this.ownerId,
    this.propertyType,
    this.location,
    this.price,
    this.area,
    this.bedrooms,
    this.bathrooms,
    this.kitchen,
    this.parking,
    this.furnished,
    this.electricity,
    this.water,
    this.gas,
    this.ac,
    this.balcony,
    this.garden,
    this.description,
    this.phone,
    this.email,
    this.images,
    this.latitude,
    this.longitude,
    this.isRented = false,
    this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    
    // --- Helper function for safe parsing ---
    double? safeDoubleParse(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? safeIntParse(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }
    // ----------------------------------------

    try {
      return Property(
        id: json['id'].toString(),
        ownerId: json['owner_id']?.toString(),
        propertyType: json['property_type'] as String?,
        location: json['location'] as String?,
        
        // ✅ --- MODIFIED: Using safe parsing ---
        price: safeDoubleParse(json['price']),
        area: safeDoubleParse(json['area']),
        bedrooms: safeIntParse(json['bedrooms']),
        bathrooms: safeIntParse(json['bathrooms']),
        
        kitchen: json['kitchen'] as bool?,
        parking: json['parking'] as bool?,
        furnished: json['furnished'] as bool?,
        electricity: json['electricity'] as bool?,
        water: json['water'] as bool?,
        gas: json['gas'] as bool?,
        ac: json['ac'] as bool?,
        balcony: json['balcony'] as bool?,
        garden: json['garden'] as bool?,
        description: json['description'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        images: json['images'] != null
            ? (json['images'] is List ? List<String>.from(json['images']) : null)
            : null,
            
        // ✅ --- MODIFIED: Using safe parsing ---
        latitude: safeDoubleParse(json['latitude']),
        longitude: safeDoubleParse(json['longitude']),
        
        isRented: json['is_rented'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
    } catch (e) {
      debugPrint("Error parsing Property.fromJson: $e");
      debugPrint("Failing JSON: $json");
      rethrow; // Re-throw the error so it can be caught by the repository
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'property_type': propertyType,
      'location': location,
      'price': price,
      'area': area, // ✅ --- MODIFIED: This will now be a double? ---
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'kitchen': kitchen,
      'parking': parking,
      'furnished': furnished,
      'electricity': electricity,
      'water': water,
      'gas': gas,
      'ac': ac,
      'balcony': balcony,
      'garden': garden,
      'description': description,
      'phone': phone,
      'email': email,
      'is_rented': isRented,
      // Note: 'images' is often handled separately (during upload)
      // 'latitude': latitude,
      // 'longitude': longitude,
    };
  }

  Property copyWith({
    String? id,
    String? ownerId,
    String? propertyType,
    String? location,
    double? price,
    double? area, // ✅ --- MODIFIED ---
    int? bedrooms,
    int? bathrooms,
    bool? kitchen,
    bool? parking,
    bool? furnished,
    bool? electricity,
    bool? water,
    bool? gas,
    bool? ac,
    bool? balcony,
    bool? garden,
    String? description,
    String? phone,
    String? email,
    bool? isRented,
  }) {
    return Property(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      propertyType: propertyType ?? this.propertyType,
      location: location ?? this.location,
      price: price ?? this.price,
      area: area ?? this.area,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      kitchen: kitchen ?? this.kitchen,
      parking: parking ?? this.parking,
      furnished: furnished ?? this.furnished,
      electricity: electricity ?? this.electricity,
      water: water ?? this.water,
      gas: gas ?? this.gas,
      ac: ac ?? this.ac,
      balcony: balcony ?? this.balcony,
      garden: garden ?? this.garden,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isRented: isRented ?? this.isRented,
    );
  }

  // Helper getters for display
  String get displayName => propertyType ?? 'Property';
  String get displayLocation => location ?? 'No location';
  String get displayPrice =>
      price != null ? 'PKR ${price!.toStringAsFixed(0)}' : 'Price not set';
  String get displayDescription => description ?? 'No description';
}
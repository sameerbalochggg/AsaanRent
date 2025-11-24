import 'package:flutter/material.dart';

class Property {
  final String id; // UUID
  final String? ownerId;
  final String? ownerName;
  final String? propertyType;
  final String? location;
  final double? price;
  final String? area; // String? to match DB text type
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
  final bool isVerified; // ✅ ADDED: Admin verification status
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? profileId;

  Property({
    required this.id,
    this.ownerId,
    this.ownerName,
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
    this.isVerified = false, // ✅ Default to false
    this.createdAt,
    this.updatedAt,
    this.profileId,
  });

  // --- Helper functions for safe parsing ---
  static double? _safeDoubleParse(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _safeIntParse(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
  // ----------------------------------------

  factory Property.fromJson(Map<String, dynamic> json) {
    try {
      return Property(
        id: json['id'].toString(), // Always String
        ownerId: json['owner_id']?.toString(),
        // Map 'username' from DB to 'ownerName' in model
        ownerName: json['owner_name'] as String? ?? json['username'] as String?, 
        propertyType: json['property_type'] as String?,
        location: json['location'] as String?,
        price: _safeDoubleParse(json['price']),
        area: json['area']?.toString(),
        bedrooms: _safeIntParse(json['bedrooms']),
        bathrooms: _safeIntParse(json['bathrooms']),
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
        latitude: _safeDoubleParse(json['latitude']),
        longitude: _safeDoubleParse(json['longitude']),
        isRented: json['is_rented'] as bool? ?? false,
        isVerified: json['is_verified'] as bool? ?? false, // ✅ Parse isVerified
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        profileId: _safeIntParse(json['profile_id']),
      );
    } catch (e) {
      debugPrint("Error parsing Property.fromJson: $e");
      debugPrint("Failing JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'username': ownerName, // Write back to 'username' column if needed
      'property_type': propertyType,
      'location': location,
      'price': price,
      'area': area,
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
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'is_rented': isRented,
      'is_verified': isVerified, // ✅ Include isVerified
      'profile_id': profileId,
    };
  }

  Property copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? propertyType,
    String? location,
    double? price,
    String? area,
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
    List<String>? images,
    double? latitude,
    double? longitude,
    bool? isRented,
    bool? isVerified, // ✅ Added to copyWith
    DateTime? createdAt,
    DateTime? updatedAt,
    int? profileId,
  }) {
    return Property(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
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
      images: images ?? this.images,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isRented: isRented ?? this.isRented,
      isVerified: isVerified ?? this.isVerified, // ✅ Handle copy
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileId: profileId ?? this.profileId,
    );
  }

  // Helper getters for display
  String get displayName => propertyType ?? 'Property';
  String get displayLocation => location ?? 'No location';
  String get displayPrice =>
      price != null ? 'PKR ${price!.toStringAsFixed(0)}' : 'Price not set';
  String get displayDescription => description ?? 'No description';
  String get displayOwnerName => ownerName ?? 'Property Owner';
}
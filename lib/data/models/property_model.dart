import 'package:flutter/material.dart';

class Property {
  final String id; // ✅ FIX: Changed to String to match uuid
  final String? ownerId;
  final String? propertyType;
  final String? location;
  final double? price;
  final String? area; // ✅ FIX: Changed to String? to match DB
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
  final int? profileId; // ✅ ADDED: From your screenshot

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
    this.profileId,
  });

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

  factory Property.fromJson(Map<String, dynamic> json) {
    try {
      return Property(
        id: json['id'] as String, // ✅ FIX: Parse as String
        ownerId: json['owner_id'] as String?,
        propertyType: json['property_type'] as String?,
        location: json['location'] as String?,
        price: _safeDoubleParse(json['price']),
        area: json['area'] as String?, // ✅ FIX: Parse as String?
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
            ? (json['images'] as List).map((e) => e.toString()).toList()
            : null,
        latitude: _safeDoubleParse(json['latitude']),
        longitude: _safeDoubleParse(json['longitude']),
        isRented: json['is_rented'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        profileId: _safeIntParse(json['profile_id']), // ✅ ADDED
      );
    } catch (e) {
      debugPrint("Error parsing Property.fromJson: $e");
      debugPrint("Failing JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    // This map is used for UPDATING, so we don't send id, owner_id, or created_at
    return {
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
      'profile_id': profileId,
    };
  }

  Property copyWith({
    String? id,
    String? ownerId,
    String? propertyType,
    String? location,
    double? price,
    String? area, // ✅ FIX
    int? bedrooms,
    int? bathrooms,
    // ... (all bools)
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
    DateTime? createdAt,
    int? profileId,
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
      images: images ?? this.images,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isRented: isRented ?? this.isRented,
      createdAt: createdAt ?? this.createdAt,
      profileId: profileId ?? this.profileId,
    );
  }

  // Helper getters for display
  String get displayName => propertyType ?? 'Property';
  String get displayLocation => location ?? 'No location';
  String get displayPrice =>
      price != null ? 'PKR ${price!.toStringAsFixed(0)}' : 'Price not set';
  String get displayDescription => description ?? 'No description';
}
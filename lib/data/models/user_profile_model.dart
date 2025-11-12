import 'package:flutter/material.dart';

class UserProfile {
  final int id; // The primary key (bigint)
  final String userId; // The foreign key (uuid)
  
  final String? username;
  final String? profession;
  final String? phone;
  final String? location;
  final String? bio;
  final String? language;
  final String? avatarUrl;
  final String? email; // ✅ --- ADDED EMAIL ---
  final DateTime? updatedAt;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.userId,
    this.username,
    this.profession,
    this.phone,
    this.location,
    this.bio,
    this.language,
    this.avatarUrl,
    this.email, // ✅ --- ADDED EMAIL ---
    this.updatedAt,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      return UserProfile(
        id: json['id'] as int,
        userId: json['user_id'] as String,
        username: json['username'] as String?,
        profession: json['profession'] as String?,
        phone: json['phone'] as String?,
        location: json['location'] as String?,
        bio: json['bio'] as String?,
        language: json['language'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        email: json['email'] as String?, // ✅ --- ADDED EMAIL ---
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
    } catch (e) {
      debugPrint("Error parsing UserProfile: $e");
      debugPrint("Failing JSON: $json");
      rethrow;
    }
  }

  // toJson is used when UPDATING the profile
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'profession': profession,
      'phone': phone,
      'location': location,
      'bio': bio,
      'language': language,
      'avatar_url': avatarUrl,
      'email': email, // ✅ --- ADDED EMAIL ---
    };
  }

  // copyWith method for the Edit screen
  UserProfile copyWith({
    int? id,
    String? userId,
    String? username,
    String? profession,
    String? phone,
    String? location,
    String? bio,
    String? language,
    String? avatarUrl,
    String? email, // ✅ --- ADDED EMAIL ---
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profession: profession ?? this.profession,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      language: language ?? this.language,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email, // ✅ --- ADDED EMAIL ---
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
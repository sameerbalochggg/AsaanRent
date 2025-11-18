import 'package:flutter/material.dart';

class UserProfile {
  final int id; // This is the bigint Primary Key
  final String userId; // This is the uuid Foreign Key to auth.users
  
  final String? username;
  final String? profession;
  final String? phone;
  final String? location;
  final String? bio;
  final String? language;
  final String? avatarUrl;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final List<String>? favorites; // List of UUIDs (Strings)

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
    this.updatedAt,
    this.createdAt,
    this.favorites,
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
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        favorites: json['favorites'] != null
            ? List<String>.from(json['favorites'].map((id) => id.toString()))
            : [],
      );
    } catch (e) {
      debugPrint("Error parsing UserProfile: $e");
      debugPrint("Failing JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'profession': profession,
      'phone': phone,
      'location': location,
      'bio': bio,
      'language': language,
      'avatar_url': avatarUrl,
      'favorites': favorites,
    };
  }

  // ✅ --- ADDED copyWith method ---
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
    DateTime? updatedAt,
    DateTime? createdAt,
    List<String>? favorites,
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
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      favorites: favorites ?? this.favorites,
    );
  }
}
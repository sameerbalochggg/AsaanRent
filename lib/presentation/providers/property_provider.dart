import 'package:flutter/material.dart';
import 'package:rent_application/data/models/user_profile_model.dart';
import 'package:rent_application/data/repositories/auth_repository.dart';
import 'package:rent_application/data/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider with ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  UserProfile? _profile;
  User? _user;

  String get email => _user?.email ?? "user.email@example.com";
  String get displayName => _profile?.username ?? "Your Name";
  String? get avatarUrl => _profile?.avatarUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    // Load the profile as soon as the provider is created
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = _authRepo.getCurrentUser();
      if (_user != null) {
        _profile = await _profileRepo.getProfile();
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_controller.dart';
import '../../models/login_response.dart';

class LoginProvider extends ChangeNotifier {
  // State variables
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _error = '';
  User? _currentUser;
  String? _accessToken;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get error => _error;
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;

  final AuthController _authController = AuthController();

  // Initialize login status
  Future<void> loadLoginStatus() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final success = prefs.getBool('success') ?? false;

      if (success) {
        _isLoggedIn = true;
        _accessToken = prefs.getString('accessToken');

        // Load user data
        _currentUser = User(
          id: prefs.getString('userId') ?? '',
          name: prefs.getString('name') ?? '',
          email: prefs.getString('email'),
          phone: prefs.getString('phone') ?? '',
          address: prefs.getString('address') ?? '',
          profilePicture: prefs.getString('profilePicture') ?? '',
          gender: prefs.getString('gender') ?? '',
          role: prefs.getString('role') ?? '',
          isVerified: prefs.getBool('isVerified') ?? false,
          status: prefs.getString('status') ?? '',
          phoneVerified: prefs.getBool('phoneVerified') ?? false,
          referralCode: prefs.getString('referralCode') ?? '',
          referredBy: prefs.getString('referredBy'),
          referralPoints: prefs.getInt('referralPoints') ?? 0,
          rewardPoints: prefs.getInt('rewardPoints') ?? 0,
          totalReferrals: prefs.getInt('totalReferrals') ?? 0,
          createdAt: DateTime.now(), // Default value for stored data
          updatedAt: DateTime.now(), // Default value for stored data
          v: 0, // Default value for stored data
        );
      } else {
        _isLoggedIn = false;
        _currentUser = null;
        _accessToken = null;
      }
    } catch (e) {
      _error = 'Error loading login status: $e';
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login method
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authController.login(email, password);

      if (result != null && result.success == true) {
        _isLoggedIn = true;
        _currentUser = result.user;
        _accessToken = result.accessToken;
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result?.message ?? 'Login failed';
        _isLoggedIn = false;
        _currentUser = null;
        _accessToken = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login error: $e';
      _isLoggedIn = false;
      _currentUser = null;
      _accessToken = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authController.clearLoginData();
      _isLoggedIn = false;
      _currentUser = null;
      _accessToken = null;
      _error = '';
    } catch (e) {
      _error = 'Logout error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile(User updatedUser) async {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  // Check if user is verified
  bool get isUserVerified => _currentUser?.isVerified ?? false;

  // Check if phone is verified
  bool get isPhoneVerified => _currentUser?.phoneVerified ?? false;

  // Get user display name
  String get userDisplayName {
    if (_currentUser?.name != null && _currentUser!.name.isNotEmpty) {
      return _currentUser!.name;
    }
    return _currentUser?.email ?? _currentUser?.phone ?? 'User';
  }

  // Get user avatar
  String? get userAvatar => _currentUser?.profilePicture;

  // Check if user has profile picture
  bool get hasProfilePicture =>
      _currentUser?.profilePicture != null &&
      _currentUser!.profilePicture.isNotEmpty;
}

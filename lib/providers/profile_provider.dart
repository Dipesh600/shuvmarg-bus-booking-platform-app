import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:sumarg/controllers/referal_controller/referal_controller.dart';
import 'package:sumarg/models/referal_dashboard_response.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthController _authController;
  final ReferalController _referalController;

  ProfileProvider({
    AuthController? authController,
    ReferalController? referalController,
  })  : _authController = authController ?? AuthController(),
        _referalController = referalController ?? ReferalController();

  bool _isLoading = true;
  bool _yatraLoading = true;
  bool _referralLoading = true;
  String _error = '';

  String? _accessToken;
  String? _name;
  String? _email;
  String? _phone;
  String? _profilePic;
  double? _yatraPoints;
  int _trips = 0;
  ReferralDashboard? _referralDashboard;

  bool get isLoading => _isLoading;
  bool get yatraLoading => _yatraLoading;
  bool get referralLoading => _referralLoading;
  String get error => _error;

  String? get accessToken => _accessToken;
  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get profilePic => _profilePic;
  double? get yatraPoints => _yatraPoints;
  int get trips => _trips;
  ReferralDashboard? get referralDashboard => _referralDashboard;

  bool get needsLogin => _accessToken == null;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    // If not a force refresh and we already have essential data, allow background update or return.
    // For profile, we usually want to check if accessToken exists first.
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');

    if (_accessToken == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // If we have local data and not forcing, we can skip the "loading" phase.
    bool wasLoaded = _name != null || _email != null;
    
    if (!wasLoaded || forceRefresh) {
      if (!wasLoaded) {
        _isLoading = true;
        _error = '';
        notifyListeners();
      }

      _name = prefs.getString('name');
      _email = prefs.getString('email');
      _phone = prefs.getString('phone');
      _profilePic = prefs.getString('profilePicture');

      _isLoading = false;
      notifyListeners();
    }

    // Always fetch dynamic data in background or foreground depending on state.
    await Future.wait([
      _loadYatraPoints(forceRefresh: forceRefresh),
      _loadReferralDashboard(forceRefresh: forceRefresh),
    ]);
  }

  Future<void> refreshProfile() async {
    await loadProfile(forceRefresh: true);
  }

  Future<void> _loadYatraPoints({bool forceRefresh = false}) async {
    // Show loading only if we don't have points yet.
    bool showLoading = _yatraPoints == null;
    
    if (showLoading) {
      _yatraLoading = true;
      notifyListeners();
    }

    try {
      final details = await _authController.getUserDetails();
      if (details.status && details.data != null) {
        _yatraPoints = details.data!.yatrapoints;
      }
    } catch (_) {
      // ignore
    } finally {
      if (showLoading) {
        _yatraLoading = false;
        notifyListeners();
      } else {
        // If it was a silent update, we might still want to notify if data changed.
        // But yatra points usually change after transactions.
        notifyListeners();
      }
    }
  }

  Future<void> _loadReferralDashboard({bool forceRefresh = false}) async {
    bool showLoading = _referralDashboard == null;

    if (showLoading) {
      _referralLoading = true;
      notifyListeners();
    }

    try {
      final dashboard = await _referalController.getReferalDashboard();
      _referralDashboard = dashboard;
    } catch (_) {
      // ignore
    } finally {
      if (showLoading) {
        _referralLoading = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}

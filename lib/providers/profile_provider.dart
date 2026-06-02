import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:sumarg/controllers/referal_controller/referal_controller.dart';
import 'package:sumarg/models/referal_dashboard_response.dart';
import 'package:sumarg/utils/api_endpoints.dart';
import 'package:sumarg/apis/api_services.dart';

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
  bool _walletLoading = false;
  bool _isWalletEnabled = false;
  bool _referralLoading = true;
  String _error = '';

  String? _accessToken;
  String? _name;
  String? _email;
  String? _phone;
  String? _profilePic;
  double? _yatraPoints;
  double? _walletBalance;
  int _trips = 0;
  ReferralDashboard? _referralDashboard;

  bool get isLoading => _isLoading;
  bool get yatraLoading => _yatraLoading;
  bool get walletLoading => _walletLoading;
  bool get isWalletEnabled => _isWalletEnabled;
  bool get referralLoading => _referralLoading;
  String get error => _error;

  String? get accessToken => _accessToken;
  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get profilePic => _profilePic;
  double? get yatraPoints => _yatraPoints;
  double? get walletBalance => _walletBalance;
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

    bool wasLoaded = _name != null || _email != null;
    
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

    // Always fetch dynamic data in background or foreground depending on state.
    await Future.wait([
      _loadYatraPoints(forceRefresh: forceRefresh),
      _loadWalletBalance(forceRefresh: forceRefresh),
      _loadReferralDashboard(forceRefresh: forceRefresh),
    ]);
  }

  Future<void> refreshProfile() async {
    await loadProfile(forceRefresh: true);
  }

  /// Lightweight refresh — only re-fetches wallet balance.
  /// Call this when returning from WalletScreen, after a booking, etc.
  Future<void> refreshWalletBalance() async {
    await _loadWalletBalance(forceRefresh: true);
  }

  Future<void> _loadYatraPoints({bool forceRefresh = false}) async {
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
    } catch (_) {}
    finally {
      _yatraLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadWalletBalance({bool forceRefresh = false}) async {
    _walletLoading = true;
    notifyListeners();
    try {
      final endpoint = '${ApiEndpoints.baseUrl}/api/wallet/details?page=1&limit=1';
      final data = await ApiService().getDataWithToken(endpoint);
      if (data != null && data['status'] == true) {
        _walletBalance = (data['data']['balance'] as num).toDouble();
        _isWalletEnabled = data['data']['isPinSet'] == true;
      } else {
        _walletBalance ??= 0.0;
        _isWalletEnabled = false;
      }
    } catch (_) {
      _walletBalance ??= 0.0;
      _isWalletEnabled = false;
    } finally {
      _walletLoading = false;
      notifyListeners();
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

  /// Called after the user successfully sets their wallet PIN.
  void markWalletEnabled() {
    _isWalletEnabled = true;
    notifyListeners();
  }
}

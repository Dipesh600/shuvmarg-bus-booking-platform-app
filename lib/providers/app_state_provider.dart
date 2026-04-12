import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/connectivity_service.dart';

class AppStateProvider extends ChangeNotifier {
  // App state variables
  bool _isOnline = true;
  bool _isLoading = false;
  String _error = '';
  String _currentRoute = '';
  bool _isFirstLaunch = true;
  String _appVersion = '';
  String _buildNumber = '';

  // Theme and UI state
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';

  // Connectivity service
  final ConnectivityService _connectivityService =
      ConnectivityService();

  // Getters
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentRoute => _currentRoute;
  bool get isFirstLaunch => _isFirstLaunch;
  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;

  // Initialize app state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize connectivity service
      await _connectivityService.initialize();
      _isOnline = _connectivityService.isConnected;

      // Load app preferences
      await _loadAppPreferences();

      // Listen to connectivity changes
      _connectivityService.onConnectivityChanged
          .listen((isConnected) {
        _isOnline = isConnected;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to initialize app: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load app preferences from SharedPreferences
  Future<void> _loadAppPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
    } catch (e) {
      debugPrint('Error loading app preferences: $e');
    }
  }

  // Save app preferences
  Future<void> _saveAppPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', _isFirstLaunch);
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setString('selectedLanguage', _selectedLanguage);
    } catch (e) {
      debugPrint('Error saving app preferences: $e');
    }
  }

  // Set current route
  void setCurrentRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Set first launch status
  Future<void> setFirstLaunch(bool isFirst) async {
    _isFirstLaunch = isFirst;
    await _saveAppPreferences();
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveAppPreferences();
    notifyListeners();
  }

  // Set language
  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    await _saveAppPreferences();
    notifyListeners();
  }

  // Set app version info
  void setAppVersion(String version, String build) {
    _appVersion = version;
    _buildNumber = build;
    notifyListeners();
  }

  // Check if user is on a specific route
  bool isOnRoute(String route) => _currentRoute == route;

  // Check if user is on any of the given routes
  bool isOnAnyRoute(List<String> routes) =>
      routes.contains(_currentRoute);

  // Get connectivity status text
  String get connectivityStatus {
    return _isOnline ? 'Online' : 'Offline';
  }

  // Check if app is ready (initialized and online)
  bool get isAppReady => !_isLoading && _isOnline;

  // Dispose resources
  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}

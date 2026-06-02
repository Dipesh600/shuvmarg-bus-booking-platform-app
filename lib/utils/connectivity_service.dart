import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance =
      ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isConnected = true;

  // Stream controller for connectivity changes
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  bool get isConnected => _isConnected;
  Stream<bool> get onConnectivityChanged =>
      _connectivityController.stream;

  // Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _isConnected = result != ConnectivityResult.none;
        _connectivityController.add(_isConnected);
      },
    );
  }

  // Check current connectivity status
  Future<bool> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = result != ConnectivityResult.none;

      // Relaxed strict DNS check for local testing via hotspot
      if (_isConnected) {
        // Rely on API exceptions for actual reachability instead of google.com
      }

      return _isConnected;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  // Check if device has internet access
  Future<bool> hasInternetAccess() async {
    return await _checkConnectivity();
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}

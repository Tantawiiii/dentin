import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to check internet connectivity
/// Uses both connectivity_plus and internet_connection_checker_plus
/// for accurate connection status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _connectionChecker = InternetConnection();

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetStatus>? _connectionStatusSubscription;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connection status
    await _checkConnection();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _onConnectivityChanged(results);
    });

    // Listen to internet connection status changes
    _connectionStatusSubscription = _connectionChecker.onStatusChange.listen((
      InternetStatus status,
    ) {
      _onConnectionStatusChanged(status);
    });
  }

  Future<void> _checkConnection() async {
    try {
      // Check if device has any connectivity
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasConnectivity = connectivityResults.any(
        (result) => result != ConnectivityResult.none,
      );

      if (!hasConnectivity) {
        _updateConnectionStatus(false);
        return;
      }

      // Check if device has actual internet access
      final hasInternet = await _connectionChecker.hasInternetAccess;
      _updateConnectionStatus(hasInternet);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error checking connection: $e');
      }
      // Default to connected to avoid blocking the app
      _updateConnectionStatus(true);
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnectivity = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnectivity) {
      _updateConnectionStatus(false);
    } else {
      // If connectivity exists, check actual internet access
      _connectionChecker.hasInternetAccess.then((hasInternet) {
        _updateConnectionStatus(hasInternet);
      });
    }
  }

  void _onConnectionStatusChanged(InternetStatus status) {
    _updateConnectionStatus(status == InternetStatus.connected);
  }

  Timer? _debounceTimer;

  void _updateConnectionStatus(bool connected) {
    if (_isConnected != connected) {
      if (!connected) {
        // Debounce lost connection to avoid flickering on transient state changes
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(seconds: 2), () {
          if (_isConnected != connected) {
            _isConnected = connected;
            _connectionController.add(connected);
            if (kDebugMode) {
              print('❌ Internet connection lost (confirmed after debounce)');
            }
          }
        });
      } else {
        // Immediate update for restored connection
        _debounceTimer?.cancel();
        _isConnected = connected;
        _connectionController.add(connected);

        if (kDebugMode) {
          print('✅ Internet connection restored');
        }
      }
    } else {
      // If we got a 'connected' signal while a debounce timer was running for 'disconnected',
      // it means the connection was restored before the debounce period ended.
      if (connected && _debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer?.cancel();
        if (kDebugMode) {
          print('ℹ️ Internet connection flickered but recovered quickly');
        }
      }
    }
  }

  /// Check current connection status
  Future<bool> checkConnection() async {
    await _checkConnection();
    return _isConnected;
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _connectionController.close();
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService extends ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  final Connectivity _connectivity = Connectivity();
  
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  
  NetworkService._internal() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }
  
  factory NetworkService() {
    return _instance;
  }
  
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      _isConnected = true;
    }
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    bool wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    if (wasConnected != _isConnected) {
      if (kDebugMode) {
        print('Network connection changed: $_isConnected');
      }
      notifyListeners();
    }
  }
}

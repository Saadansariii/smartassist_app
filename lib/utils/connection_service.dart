import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    await checkConnection();
    _connectivity.onConnectivityChanged.listen((_) async {
      await checkConnection();
    });
  }

  Future<bool> checkConnection() async {
    bool previousConnection = _isConnected;

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _isConnected = false;
      } else {
        // ✅ Perform actual internet check
        final result = await InternetAddress.lookup('google.com');
        _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    } catch (e) {
      _isConnected = false;
    }

    if (previousConnection != _isConnected) {
      _connectionController.add(_isConnected);
    }

    return _isConnected;
  }

  void dispose() {
    _connectionController.close();
  }
}

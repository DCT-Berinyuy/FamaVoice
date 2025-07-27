import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _connectivityResult = results.first;
        notifyListeners();
      }
    });
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> result = await (Connectivity().checkConnectivity());
    if (result.isNotEmpty) {
      _connectivityResult = result.first;
      notifyListeners();
    }
  }

  bool get isOnline => _connectivityResult != ConnectivityResult.none;
}
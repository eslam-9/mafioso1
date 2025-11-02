import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    try {
      // First check connectivity status
      final result = await _connectivity.checkConnectivity();
      final hasConnection = result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet;
      
      print('🔍 [ConnectivityService] Connectivity status: $result');
      print('🔍 [ConnectivityService] Has connection type: $hasConnection');
      
      // If connectivity check fails (common on emulators), try actual network request
      if (!hasConnection || result == ConnectivityResult.none) {
        print('🔍 [ConnectivityService] Connectivity check failed, testing with real request...');
        return await _testInternetConnection();
      }
      
      return true;
    } catch (e) {
      print('❌ [ConnectivityService] Error checking connectivity: $e');
      // Fallback to actual network test
      return await _testInternetConnection();
    }
  }
  
  /// Actually test internet connection by making a real request
  Future<bool> _testInternetConnection() async {
    try {
      print('🌐 [ConnectivityService] Testing actual internet connection...');
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      print('🌐 [ConnectivityService] Internet test result: $isConnected');
      return isConnected;
    } on SocketException catch (e) {
      print('❌ [ConnectivityService] No internet - SocketException: $e');
      return false;
    } catch (e) {
      print('❌ [ConnectivityService] Internet test failed: $e');
      return false;
    }
  }

  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet;
    });
  }
}

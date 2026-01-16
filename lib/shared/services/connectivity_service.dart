import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/utils/logger.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    try {
      // First check connectivity status
      final result = await _connectivity.checkConnectivity();
      final hasConnection =
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet;

      AppLogger.logInfo('[ConnectivityService] Connectivity status: $result');
      AppLogger.logInfo(
        '[ConnectivityService] Has connection type: $hasConnection',
      );

      // If connectivity check fails (common on emulators), try actual network request
      if (!hasConnection || result == ConnectivityResult.none) {
        AppLogger.logInfo(
          '[ConnectivityService] Connectivity check failed, testing with real request...',
        );
        return await _testInternetConnection();
      }

      return true;
    } catch (e) {
      AppLogger.logError(
        '[ConnectivityService] Error checking connectivity',
        e,
      );
      // Fallback to actual network test
      return await _testInternetConnection();
    }
  }

  /// Actually test internet connection by making a real request
  Future<bool> _testInternetConnection() async {
    try {
      AppLogger.logInfo(
        '[ConnectivityService] Testing actual internet connection...',
      );
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      AppLogger.logInfo(
        '[ConnectivityService] Internet test result: $isConnected',
      );
      return isConnected;
    } on SocketException catch (e) {
      AppLogger.logError(
        '[ConnectivityService] No internet - SocketException',
        e,
      );
      return false;
    } catch (e) {
      AppLogger.logError('[ConnectivityService] Internet test failed', e);
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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Manages the persistent anonymous device identity.
/// The UUID is generated once and stored in SharedPreferences forever.
class DeviceIdService {
  static const String _key = 'anonymous_device_id';
  final SharedPreferences _prefs;

  DeviceIdService(this._prefs);

  String get deviceId {
    final existing = _prefs.getString(_key);
    if (existing != null) return existing;

    final newId = const Uuid().v4();
    _prefs.setString(_key, newId);
    return newId;
  }
}

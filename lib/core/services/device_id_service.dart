import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Provides a persistent, anonymous device identifier.
///
/// Uses a random UUID stored in SharedPreferences. Never accesses
/// hardware identifiers (IMEI, MAC address, Android ID, etc.).
class DeviceIdService {
  static const String _key = 'persistent_device_uuid';
  static String? _cachedDeviceId;

  /// Returns the persistent device UUID, creating one if not present.
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);
    if (id == null || id.trim().isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_key, id);
    }
    _cachedDeviceId = id;
    return id;
  }
}

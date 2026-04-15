import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const String _storageKey = 'nkoda_device_id';
  static String? _cachedId;

  /// Pobiera unikalny identyfikator urządzenia. 
  /// Jeśli nie istnieje, generuje nowy i zapisuje go na stałe.
  static Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_storageKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_storageKey, deviceId);
    }

    _cachedId = deviceId;
    return deviceId;
  }
}

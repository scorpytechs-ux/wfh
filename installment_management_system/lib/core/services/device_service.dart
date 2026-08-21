import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const String _deviceIdKey = 'app_persistent_device_id';
  static const _uuid = Uuid();

  static Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);
      if (deviceId != null && deviceId.isNotEmpty) {
        return deviceId;
      }
      final hostname = Platform.localHostname.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final username = (Platform.environment['USERNAME'] ?? Platform.environment['USER'] ?? 'user')
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      deviceId = 'dev_win_${hostname}_$username';
      await prefs.setString(_deviceIdKey, deviceId);
      return deviceId;
    } catch (e) {
      return 'dev_win_default';
    }
  }

  static String getDeviceName() {
    try {
      final hostname = Platform.localHostname;
      if (hostname.isNotEmpty) {
        return 'Windows App ($hostname)';
      }
    } catch (_) {}
    return 'Windows Desktop App';
  }
}


import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  /// Method to check and request all necessary permissions back-to-back
  static Future<void> checkPermissions() async {
    await _requestPermissionUntilGranted(Permission.microphone);
    await _requestPermissionUntilGranted(Permission.camera);
    await _requestPermissionUntilGranted(Permission.notification);
    await _requestPermissionUntilGranted(Permission.phone);


  }

  /// Helper method to request a permission until granted or permanently denied
  static Future<void> _requestPermissionUntilGranted(
      Permission permission) async {
    while (true) {
      final status = await permission.status;

      if (status.isGranted) {
        // Permission is granted, exit the loop
        break;
      } else if (status.isPermanentlyDenied) {
        // Permission is permanently denied, show a message or guide to settings
        print(
            "Permission ${permission.toString()} permanently denied. Please enable it from app settings.");
        openAppSettings();
        break;
      } else {
        // Request the permission
        await permission.request();
      }
    }
  }
}

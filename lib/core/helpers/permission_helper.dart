import 'package:permission_handler/permission_handler.dart';

enum AppPermission {
  camera,
  photos,
  notifications,
  location,
}

class PermissionHelper {
  PermissionHelper._();

  static Permission _map(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.photos:
        return Permission.photos;
      case AppPermission.notifications:
        return Permission.notification;
      case AppPermission.location:
        return Permission.locationWhenInUse;
    }
  }

  static Future<bool> isGranted(AppPermission permission) async {
    final status = await _map(permission).status;
    return status.isGranted;
  }

  static Future<bool> isPermanentlyDenied(AppPermission permission) async {
    final status = await _map(permission).status;
    return status.isPermanentlyDenied;
  }

  static Future<PermissionStatus> check(AppPermission permission) {
    return _map(permission).status;
  }

  static Future<PermissionStatus> request(AppPermission permission) {
    return _map(permission).request();
  }

  static Future<bool> openSettings() {
    return openAppSettings();
  }
}

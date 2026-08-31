import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/helpers/app_session.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/helpers/permission_helper.dart';
import '../../../core/helpers/plant_image_store.dart';
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../data/profile_notifications.dart';

class ProfileController extends GetxController {
  static const _nameKey = 'profile_display_name';
  static const _emailKey = 'profile_email';
  static const _gardenNameKey = 'profile_garden_name';
  static const _locationKey = 'profile_location';
  static const _photoKey = 'profile_photo_path';
  static const _legacyWateringKey = 'profile_notify_watering';
  static const _notifyMasterKey = 'profile_notify_master';
  static const _reminderTimeKey = 'profile_notify_reminder_time';
  static const _lockPinKey = 'profile_lock_pin';
  static const _lockOnKey = 'profile_lock_on';
  static const _lockBioKey = 'profile_lock_bio';
  static const _lockFailsKey = 'profile_lock_fails';
  static const _lockUntilKey = 'profile_lock_until';
  static const _lockStageKey = 'profile_lock_stage';
  static const _userIdKey = 'profile_user_id';

  static const _openRoutes = {
    RouteNames.splash,
    RouteNames.onboarding,
    RouteNames.authentication,
    RouteNames.signup,
    RouteNames.forgotPassword,
    RouteNames.otpVerification,
    RouteNames.resetPassword,
    RouteNames.passwordResetSuccess,
  };

  final RxString userId = ''.obs;
  final RxString displayName = 'Plant lover'.obs;
  final RxString email = ''.obs;
  final RxString gardenName = ''.obs;
  final RxString location = ''.obs;
  final RxnString photoPath = RxnString();
  final RxBool notifyMaster = true.obs;
  final RxString reminderTime = '9:00 AM'.obs;
  final RxMap<String, bool> notifyOn = <String, bool>{}.obs;
  final RxBool passcodeOn = false.obs;
  final RxBool biometricOn = false.obs;
  final RxBool appLocked = false.obs;
  final RxInt failedAttempts = 0.obs;
  final RxInt lockoutStage = 0.obs;
  final Rxn<DateTime> lockoutUntil = Rxn<DateTime>();
  final RxInt lockClock = 0.obs;
  String _pinHash = '';
  var sessionUnlocked = false;
  var _backgrounded = false;
  var _suppressLock = 0;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Good night';
  }

  String get initials {
    final parts = displayName.value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'P';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get hasPhoto {
    final path = photoPath.value;
    if (path == null || path.trim().isEmpty) return false;
    return File(path).existsSync();
  }

  String get emailLabel {
    final value = email.value.trim();
    return value.isEmpty ? 'No email yet' : value;
  }

  String get userIdLabel {
    final id = userId.value;
    if (id.isEmpty) return '—';
    if (id.length <= 16) return id;
    return '${id.substring(0, 16)}...';
  }

  String unsetOr(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Not set' : trimmed;
  }

  void openSubscription() {
    NavigationHelper.toNamed(RouteNames.subscription);
  }

  void openGarden() {
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>()
        .onTabTapped(MainNavigationController.gardenIndex);
  }

  Future<void> logOut() async {
    await AppSession.clearSession();
    NavigationHelper.offAllNamed(RouteNames.authentication);
  }

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_gardenNameKey);
    await prefs.remove(_locationKey);
    await prefs.remove(_photoKey);
    await prefs.remove(_lockPinKey);
    await prefs.setBool(_lockOnKey, false);
    await prefs.setBool(_lockBioKey, false);
    displayName.value = 'Plant lover';
    email.value = '';
    gardenName.value = '';
    location.value = '';
    photoPath.value = null;
    passcodeOn.value = false;
    biometricOn.value = false;
    appLocked.value = false;
    sessionUnlocked = true;
    _pinHash = '';
    failedAttempts.value = 0;
    lockoutStage.value = 0;
    lockoutUntil.value = null;
    await prefs.remove(_lockFailsKey);
    await prefs.remove(_lockUntilKey);
    await prefs.remove(_lockStageKey);
    await prefs.remove(_userIdKey);
    userId.value = '';
    await AppSession.clearSession();
    NavigationHelper.offAllNamed(RouteNames.authentication);
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey)?.trim();
    if (name != null && name.isNotEmpty) displayName.value = name;
    email.value = prefs.getString(_emailKey)?.trim() ?? '';
    gardenName.value = prefs.getString(_gardenNameKey)?.trim() ?? '';
    location.value = prefs.getString(_locationKey)?.trim() ?? '';
    notifyMaster.value = prefs.getBool(_notifyMasterKey) ?? true;
    final time = prefs.getString(_reminderTimeKey)?.trim();
    if (time != null && time.isNotEmpty) reminderTime.value = time;
    for (final id in ProfileNotifications.ids) {
      var value = prefs.getBool(_notifyKey(id));
      if (id == 'water') {
        value ??= prefs.getBool(_legacyWateringKey);
      }
      notifyOn[id] = value ?? true;
    }
    final path = prefs.getString(_photoKey);
    if (path != null && path.trim().isNotEmpty && File(path).existsSync()) {
      photoPath.value = path;
    }
    _pinHash = prefs.getString(_lockPinKey) ?? '';
    passcodeOn.value =
        (prefs.getBool(_lockOnKey) ?? false) && _pinHash.isNotEmpty;
    biometricOn.value =
        (prefs.getBool(_lockBioKey) ?? false) && passcodeOn.value;
    failedAttempts.value = prefs.getInt(_lockFailsKey) ?? 0;
    lockoutStage.value = prefs.getInt(_lockStageKey) ?? 0;
    final untilMillis = prefs.getInt(_lockUntilKey);
    if (untilMillis != null && untilMillis > 0) {
      lockoutUntil.value = DateTime.fromMillisecondsSinceEpoch(untilMillis);
    }
    refreshLockout();
    await _ensureUserId(prefs);
  }

  Future<void> _ensureUserId(SharedPreferences prefs) async {
    var id = prefs.getString(_userIdKey)?.trim() ?? '';
    if (id.isEmpty) {
      id = _newUserId();
      await prefs.setString(_userIdKey, id);
    }
    userId.value = id;
  }

  static String _newUserId() {
    const alphabet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      20,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  Future<bool> saveProfile({
    required String name,
    required String email,
    required String gardenName,
    required String location,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;

    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty) {
      final valid = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
      if (!valid.hasMatch(trimmedEmail)) return false;
    }

    displayName.value = trimmedName;
    this.email.value = trimmedEmail;
    this.gardenName.value = gardenName.trim();
    this.location.value = location.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, displayName.value);
    await prefs.setString(_emailKey, this.email.value);
    await prefs.setString(_gardenNameKey, this.gardenName.value);
    await prefs.setString(_locationKey, this.location.value);
    return true;
  }

  bool isNotifyOn(String id) => notifyOn[id] ?? true;

  Future<void> setNotifyMaster(bool value) async {
    if (value) {
      await PermissionHelper.request(AppPermission.notifications);
    }
    notifyMaster.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifyMasterKey, value);
  }

  Future<void> setReminderTime(String value) async {
    reminderTime.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderTimeKey, value);
  }

  Future<void> setNotify(String id, bool value) async {
    if (value) {
      await PermissionHelper.request(AppPermission.notifications);
    }
    notifyOn[id] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifyKey(id), value);
  }

  static String _notifyKey(String id) => 'profile_notify_$id';

  bool verifyPasscode(String pin) =>
      _pinHash.isNotEmpty && _pinHash == _hashPin(pin);

  bool get isLockedOut {
    final until = lockoutUntil.value;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  String get lockoutLabel {
    final until = lockoutUntil.value;
    if (until == null) return '';
    final left = until.difference(DateTime.now());
    if (left.isNegative) return '';
    final hours = left.inHours;
    final minutes = left.inMinutes.remainder(60);
    if (hours >= 24) {
      return 'Try again in ${left.inDays}d ${hours.remainder(24)}h';
    }
    if (hours > 0) return 'Try again in ${hours}h ${minutes}m';
    final seconds = left.inSeconds.remainder(60);
    if (minutes > 0) return 'Try again in $minutes min';
    return 'Try again in $seconds sec';
  }

  void refreshLockout() {
    lockClock.value++;
    final until = lockoutUntil.value;
    if (until != null && !DateTime.now().isBefore(until)) {
      _endLockout();
    }
  }

  void onRouteChanged(String? route) {
    if (route == null || !passcodeOn.value) return;
    if (_openRoutes.contains(route)) return;
    if (!sessionUnlocked) appLocked.value = true;
  }

  void noteBackgrounded() {
    if (_suppressLock > 0 || !passcodeOn.value) return;
    _backgrounded = true;
    sessionUnlocked = false;
  }

  void lockIfNeeded() {
    if (!passcodeOn.value || _suppressLock > 0) return;
    if (_openRoutes.contains(Get.currentRoute)) return;
    if (_backgrounded || !sessionUnlocked) {
      appLocked.value = true;
      _backgrounded = false;
    }
  }

  Future<bool> tryUnlock(String pin) async {
    refreshLockout();
    if (isLockedOut) return false;
    if (verifyPasscode(pin)) {
      await _resetFails();
      sessionUnlocked = true;
      appLocked.value = false;
      return true;
    }
    await _registerFail();
    return false;
  }

  void unlockWithBiometric() {
    if (isLockedOut || !passcodeOn.value) return;
    sessionUnlocked = true;
    appLocked.value = false;
    _resetFails();
  }

  Future<void> enablePasscode(String pin) async {
    _pinHash = _hashPin(pin);
    passcodeOn.value = true;
    sessionUnlocked = true;
    appLocked.value = false;
    await _resetFails();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lockPinKey, _pinHash);
    await prefs.setBool(_lockOnKey, true);
  }

  Future<void> changePasscode(String pin) async {
    await enablePasscode(pin);
  }

  Future<void> disablePasscode() async {
    _pinHash = '';
    passcodeOn.value = false;
    biometricOn.value = false;
    appLocked.value = false;
    sessionUnlocked = true;
    await _resetFails();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lockPinKey);
    await prefs.setBool(_lockOnKey, false);
    await prefs.setBool(_lockBioKey, false);
  }

  Future<void> setBiometric(bool value) async {
    if (!passcodeOn.value) return;
    biometricOn.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockBioKey, value);
  }

  int get _failLimit => lockoutStage.value == 0 ? 4 : 2;

  Duration get _failPenalty => lockoutStage.value == 0
      ? const Duration(hours: 1)
      : const Duration(hours: 48);

  Future<void> _registerFail() async {
    failedAttempts.value++;
    if (failedAttempts.value >= _failLimit) {
      lockoutUntil.value = DateTime.now().add(_failPenalty);
    }
    await _persistLockout();
  }

  Future<void> _endLockout() async {
    lockoutUntil.value = null;
    lockoutStage.value = lockoutStage.value == 0 ? 1 : 0;
    failedAttempts.value = 0;
    await _persistLockout();
  }

  Future<void> _resetFails() async {
    failedAttempts.value = 0;
    lockoutStage.value = 0;
    lockoutUntil.value = null;
    await _persistLockout();
  }

  Future<void> _persistLockout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lockFailsKey, failedAttempts.value);
    await prefs.setInt(_lockStageKey, lockoutStage.value);
    final until = lockoutUntil.value;
    if (until == null) {
      await prefs.remove(_lockUntilKey);
    } else {
      await prefs.setInt(_lockUntilKey, until.millisecondsSinceEpoch);
    }
  }

  static String _hashPin(String pin) {
    final bytes = utf8.encode('aiplant.lock.v1.$pin');
    var hash = 0xcbf29ce484222325;
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  Future<void> pickPhoto() async {
    _suppressLock++;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      final path = await PlantImageStore.persistCopy(file.path);
      photoPath.value = path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_photoKey, path);
    } finally {
      _suppressLock--;
    }
  }
}

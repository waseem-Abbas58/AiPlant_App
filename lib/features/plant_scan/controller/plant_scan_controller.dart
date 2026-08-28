import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/helpers/app_camera.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/helpers/permission_helper.dart';
import '../../../shared/camera/premium_camera_session.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../model/plant_identify_result.dart';
import '../model/plant_scan_model.dart';
import '../view/identify_failed_view.dart';
import '../view/identify_processing_view.dart';
import '../view/identify_result_view.dart';
import '../view/identify_tips_view.dart';

class PlantScanController extends GetxController {
  static const maxMultipleShots = 5;
  static const visibleMultipleSlots = 3;

  final isIdentifyMode = true.obs;
  final selectedCategory = 0.obs;
  final lastThumbPath = RxnString();
  final capturedPaths = RxList<String>([]);
  final isCameraReady = false.obs;
  final isBusy = false.obs;
  final toxicityFocus = false.obs;

  CameraController? camera;
  List<CameraDescription> _cameras = [];
  Worker? _tabWorker;
  var _usingFront = false;
  var _needsSettle = false;
  final session = PremiumCameraSession();

  ScanCategory get category => ScanCategory.all[selectedCategory.value];

  @override
  void onInit() {
    super.onInit();
    session.onTick = () {
      if (!isClosed) update(['chrome']);
    };
    if (Get.isRegistered<MainNavigationController>()) {
      final nav = Get.find<MainNavigationController>();
      _tabWorker = ever(nav.selectedIndex, _onTabChanged);
      if (nav.selectedIndex.value == 2) {
        startCamera();
      }
    }
  }

  @override
  void onClose() {
    _tabWorker?.dispose();
    session.dispose();
    _disposeCamera();
    super.onClose();
  }

  void _onTabChanged(int index) {
    if (index == 2) {
      startCamera();
    } else {
      releaseCamera();
    }
  }

  void closeScan() {
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>().onTabTapped(0);
  }

  void selectCategory(int index, {bool toxicity = false}) {
    selectedCategory.value = index;
    toxicityFocus.value = toxicity;
  }

  void setIdentifyMode(bool value) {
    if (isIdentifyMode.value == value) return;
    isIdentifyMode.value = value;
    capturedPaths.clear();
  }

  Future<void> startCamera() async {
    if (isCameraReady.value && camera != null) {
      await camera!.resumePreview();
      return;
    }
    await PermissionHelper.request(AppPermission.camera);
    if (!await PermissionHelper.isGranted(AppPermission.camera)) {
      final permanentlyDenied =
          await PermissionHelper.isPermanentlyDenied(AppPermission.camera);
      CustomSnackbar.warning(
        title: 'Camera needed',
        message: permanentlyDenied
            ? 'Enable camera in Settings to identify plants.'
            : 'Camera permission is required to identify plants.',
        actionLabel: permanentlyDenied ? 'Settings' : null,
        onAction: permanentlyDenied ? PermissionHelper.openSettings : null,
      );
      return;
    } 
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      final description = _usingFront
          ? _cameras.firstWhere(
              (item) => item.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (item) => item.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );
      await _openCamera(description);
    } catch (_) {
      isCameraReady.value = false;
    }
  }

  Future<void> _openCamera(CameraDescription description) async {
    await _disposeCamera();
    final next = await AppCamera.open(
      description,
      afterRelease: _needsSettle,
    );
    _needsSettle = false;
    if (isClosed) {
      await next.dispose();
      return;
    }
    camera = next;
    await session.bind(next);
    if (isClosed) return;
    isCameraReady.value = true;
    update(['camera', 'chrome']);
  }

  Future<void> pauseCamera() async {
    try {
      await camera?.pausePreview();
    } catch (_) {}
  }

  Future<void> releaseCamera() => _disposeCamera();

  Future<void> flipCamera() async {
    if (_cameras.length < 2) return;
    _usingFront = !_usingFront;
    session.resetForNewLens();
    isCameraReady.value = false;
    await startCamera();
  }

  Future<void> _disposeCamera() async {
    final current = camera;
    camera = null;
    isCameraReady.value = false;
    update(['camera']);
    if (current != null) {
      await current.dispose();
      _needsSettle = true;
    }
  }

  Future<void> openGallery() async {
    if (isBusy.value) return;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (file == null) return;
    await _acceptImage(file.path);
  }

  Future<void> capture() async {
    if (isBusy.value) return;
    isBusy.value = true;
    try {
      String? path;
      if (isCameraReady.value && camera != null) {
        session.playShutter();
        update(['chrome']);
        final shot = await camera!.takePicture();
        path = shot.path;
      } else {
        final file = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1600,
        );
        path = file?.path;
      }
      if (path == null) return;
      await _acceptImage(path);
    } catch (_) {
      CustomSnackbar.error(
        title: 'Capture failed',
        message: 'Try again or pick a photo from gallery.',
      );
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _acceptImage(String path) async {
    lastThumbPath.value = path;
    if (isIdentifyMode.value) {
      await _runIdentify([path]);
      return;
    }
    if (capturedPaths.length >= maxMultipleShots) {
      CustomSnackbar.info(
        title: '5 photos max',
        message: 'Remove one, or identify these together.',
      );
      return;
    }
    capturedPaths.add(path);
  }

  Future<void> identifyCaptured() async {
    if (isIdentifyMode.value || capturedPaths.isEmpty) return;
    await _runIdentify(List.of(capturedPaths));
  }

  void removeCapturedAt(int index) {
    if (index < 0 || index >= capturedPaths.length) return;
    capturedPaths.removeAt(index);
  }

  void openTips() {
    NavigationHelper.to(IdentifyTipsView.new);
  }

  Future<void> _runIdentify(List<String> paths) async {
    if (paths.isEmpty) return;
    pauseCamera();
    final result = await NavigationHelper.to<PlantIdentifyResult>(
      () => IdentifyProcessingView(
        imagePath: paths.first,
        categoryId: category.id,
      ),
    );
    capturedPaths.clear();
    if (result == null) {
      startCamera();
      return;
    }
    if (!result.isIdentified) {
      NavigationHelper.to(IdentifyFailedView.new);
    } else {
      await _finishSuccess(result);
    }
    startCamera();
  }

  Future<void> _finishSuccess(PlantIdentifyResult result) async {
    if (Get.isRegistered<MyGardenController>()) {
      Get.find<MyGardenController>().addIdentifySnap(
        result.imagePath,
        name: result.commonName,
        scientificName: result.scientificName,
      );
    }
    final plantId = await NavigationHelper.to<String>(
      () => IdentifyResultView(
        result: result,
        openToxicity: toxicityFocus.value,
      ),
    );
    if (plantId != null && Get.isRegistered<MyGardenController>()) {
      Get.find<MyGardenController>().openWaterMeter(plantId: plantId);
    }
    toxicityFocus.value = false;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/helpers/plant_image_store.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../data/garden_local_store.dart';
import '../data/plant_care_engine.dart';
import '../model/my_garden_model.dart';
import '../view/add_plant_camera_view.dart';
import '../view/garden_plant_detail_view.dart';
import '../view/light_meter_view.dart';
import '../view/water_meter_view.dart';
import '../view/plant_photo_review_view.dart';
import '../../plant_scan/controller/plant_scan_controller.dart';
import '../../plant_scan/data/identify_flow.dart';
import '../../plant_scan/data/plant_identify_repository.dart';
import '../../plant_scan/model/plant_identify_result.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../../plant_scan/view/identify_result_view.dart';
import '../widgets/change_group_sheet.dart';
import '../widgets/diary_note_sheet.dart';
import '../widgets/edit_care_task_sheet.dart';
import '../widgets/new_group_sheet.dart';
import '../widgets/plant_crop_sheet.dart';
import '../widgets/plant_editor_sheet.dart';
import '../widgets/plant_more_sheet.dart';
import '../widgets/add_plant_sheet.dart';

class MyGardenController extends GetxController {
  final selectedTaskDate = _dateOnly(DateTime.now()).obs;
  final snaps = RxList<GardenSnap>([]);
  final wishlist = RxList<GardenWishlistItem>([]);
  final diary = RxList<GardenDiaryEntry>([]);
  final groups = RxList<GardenGroup>([GardenGroup.general]);
  final plants = RxList<GardenPlant>([]);
  final completedKeys = <String>{}.obs;
  final selectedGroupId = RxnString();
  final careStreak = 0.obs;
  final lastStreakDay = Rxn<DateTime>();
  final homeTab = 0.obs;
  final snapCollectionTab = 0.obs; // 0 = Seen, 1 = Wishlist
  var _hydrated = false;
  var _saveQueued = false;

  @override
  void onInit() {
    super.onInit();
    _hydrate();
    ever(plants, (_) => _scheduleSave());
    ever(groups, (_) => _scheduleSave());
    ever(snaps, (_) => _scheduleSave());
    ever(wishlist, (_) => _scheduleSave());
    ever(diary, (_) => _scheduleSave());
    ever(completedKeys, (_) => _scheduleSave());
    ever(careStreak, (_) => _scheduleSave());
    ever(lastStreakDay, (_) => _scheduleSave());
  }

  Future<void> _hydrate() async {
    final snapshot = await GardenLocalStore.load();
    if (snapshot == null) {
      _hydrated = true;
      return;
    }
    plants.assignAll(snapshot.plants);
    groups.assignAll(snapshot.groups);
    snaps.assignAll(snapshot.snaps);
    wishlist.assignAll(snapshot.wishlist);
    diary.assignAll(snapshot.diary);
    completedKeys
      ..clear()
      ..addAll(snapshot.completedKeys);
    careStreak.value = snapshot.careStreak;
    lastStreakDay.value = snapshot.lastStreakDay;
    _hydrated = true;
  }

  void _scheduleSave() {
    if (!_hydrated || _saveQueued) return;
    _saveQueued = true;
    Future<void>.delayed(const Duration(milliseconds: 280), () async {
      _saveQueued = false;
      if (!_hydrated) return;
      await GardenLocalStore.save(
        GardenLocalSnapshot(
          plants: plants.toList(),
          groups: groups.toList(),
          snaps: snaps.toList(),
          wishlist: wishlist.toList(),
          diary: diary.toList(),
          completedKeys: completedKeys.toSet(),
          careStreak: careStreak.value,
          lastStreakDay: lastStreakDay.value,
        ),
      );
    });
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime get today => _dateOnly(DateTime.now());

  bool get showGroupChips => true;

  List<GardenPlant> get visiblePlants {
    final selected = selectedGroupId.value;
    if (selected == null) return plants.toList();
    return plants.where((plant) => plant.groupId == selected).toList();
  }

  String careLabelFor(GardenPlant plant) {
    final water = PlantCareEngine.waterStatus(plant);
    if (water == PlantWaterStatus.due) return 'Due today';
    if (water == PlantWaterStatus.dry) return 'Needs water';
    for (final task in _tasksOn(today)) {
      if (task.plantId != plant.id || task.done || task.kind == 'water') {
        continue;
      }
      return switch (task.kind) {
        'mist' => 'Needs mist',
        'fertilizer' => 'Needs fertilizer',
        'rotate' => 'Needs rotate',
        'cut' => 'Needs trim',
        _ => 'Needs care',
      };
    }
    if (water == PlantWaterStatus.fresh) return 'Watered';
    return 'Healthy';
  }

  bool canQuickWater(GardenPlant plant) {
    final water = PlantCareEngine.waterStatus(plant);
    return water == PlantWaterStatus.due || water == PlantWaterStatus.dry;
  }

  void selectGroup(String? groupId) {
    if (selectedGroupId.value == groupId) return;
    selectedGroupId.value = groupId;
  }

  static final minTaskMonth = DateTime(2020, 1, 1);
  static final maxTaskMonth = DateTime(2035, 12, 1);

  BuildContext? get _sheetContext => Get.overlayContext ?? Get.context;

  List<DateTime> get weekDates {
    final selected = selectedTaskDate.value;
    final monday = selected.subtract(Duration(days: selected.weekday - 1));
    return List.generate(
      7,
      (index) => DateTime(monday.year, monday.month, monday.day + index),
    );
  }

  String get taskMonthLabel =>
      DateFormat('MMMM y').format(selectedTaskDate.value);

  String get taskYearLabel => '${selectedTaskDate.value.year}';

  String get taskMonthShortLabel =>
      DateFormat('MMM').format(selectedTaskDate.value);

  String get selectedTaskHeading {
    if (isSameDay(selectedTaskDate.value, today)) return 'Today';
    return DateFormat('EEEE, d MMM').format(selectedTaskDate.value);
  }

  List<GardenTask> get tasksForSelectedDate => _tasksOn(selectedTaskDate.value);

  String _taskKey(String plantId, String kind, DateTime date) {
    final day = _dateOnly(date);
    return '$plantId-$kind-${day.year}-${day.month}-${day.day}';
  }

  bool _dueEveryDays(DateTime start, DateTime date, int days) {
    if (days <= 0) return false;
    final from = _dateOnly(start);
    final to = _dateOnly(date);
    if (to.isBefore(from)) return false;
    final elapsed = to.difference(from).inDays;
    if (elapsed == 0) return false;
    return elapsed % days == 0;
  }

  bool _dueEveryMonths(DateTime start, DateTime date, int months) {
    if (months <= 0) return false;
    final from = DateTime(start.year, start.month);
    final to = DateTime(date.year, date.month);
    if (to.isBefore(from)) return false;
    final diff = (to.year - from.year) * 12 + (to.month - from.month);
    if (diff == 0 || diff % months != 0) return false;
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    return date.day == start.day.clamp(1, lastDay);
  }

  String _kindTitle(GardenCareKind kind) {
    return switch (kind) {
      GardenCareKind.water => 'Water',
      GardenCareKind.mist => 'Mist',
      GardenCareKind.fertilizer => 'Fertilize',
      GardenCareKind.rotate => 'Rotate',
      GardenCareKind.cut => 'Cut',
    };
  }

  List<GardenTask> _tasksOn(DateTime date) {
    final day = _dateOnly(date);
    final items = <GardenTask>[];
    for (final plant in plants) {
      final start = _dateOnly(plant.createdAt);
      void add(GardenCareKind kind, bool due, String timeLabel) {
        if (!due) return;
        final id = _taskKey(plant.id, kind.name, day);
        items.add(
          GardenTask(
            id: id,
            plantId: plant.id,
            plantName: plant.name,
            imagePath: plant.imagePath,
            title: _kindTitle(kind),
            timeLabel: timeLabel,
            date: day,
            kind: kind.name,
            done: completedKeys.contains(id),
          ),
        );
      }

      add(
        GardenCareKind.water,
        PlantCareEngine.waterDueOn(plant, day),
        plant.care.waterTime,
      );
      add(
        GardenCareKind.mist,
        _dueEveryDays(start, day, plant.care.mistDays),
        'Anytime',
      );
      add(
        GardenCareKind.fertilizer,
        _dueEveryMonths(start, day, plant.care.fertilizerMonths),
        'Anytime',
      );
      add(
        GardenCareKind.rotate,
        _dueEveryMonths(start, day, plant.care.rotateMonths),
        'Anytime',
      );
      add(
        GardenCareKind.cut,
        _dueEveryMonths(start, day, plant.care.cutMonths),
        'Anytime',
      );
    }
    return items;
  }

  bool get canGoPreviousMonth {
    final selected = selectedTaskDate.value;
    return DateTime(selected.year, selected.month, 1)
        .isAfter(minTaskMonth);
  }

  bool get canGoNextMonth {
    final selected = selectedTaskDate.value;
    return DateTime(selected.year, selected.month, 1)
        .isBefore(maxTaskMonth);
  }

  void selectTaskDate(DateTime date) {
    final next = _dateOnly(date);
    if (isSameDay(selectedTaskDate.value, next)) return;
    selectedTaskDate.value = next;
  }

  void shiftMonth(int delta) {
    final current = selectedTaskDate.value;
    final nextMonth = DateTime(current.year, current.month + delta, 1);
    if (nextMonth.isBefore(minTaskMonth) || nextMonth.isAfter(maxTaskMonth)) {
      return;
    }
    selectMonthYear(nextMonth);
  }

  bool get canGoPreviousWeek {
    final previous = selectedTaskDate.value.subtract(const Duration(days: 7));
    return !DateTime(previous.year, previous.month, 1).isBefore(minTaskMonth);
  }

  bool get canGoNextWeek {
    final next = selectedTaskDate.value.add(const Duration(days: 7));
    return !DateTime(next.year, next.month, 1).isAfter(maxTaskMonth);
  }

  void shiftWeek(int delta) {
    final next = selectedTaskDate.value.add(Duration(days: 7 * delta));
    if (DateTime(next.year, next.month, 1).isBefore(minTaskMonth) ||
        DateTime(next.year, next.month, 1).isAfter(maxTaskMonth)) {
      return;
    }
    selectedTaskDate.value = _dateOnly(next);
  }

  void toggleTask(GardenTask task) {
    if (task.kind == 'water') {
      final plant = plantById(task.plantId);
      if (plant == null) return;
      if (task.done) {
        undoWatered(plant);
      } else {
        markWatered(plant);
      }
      return;
    }
    if (completedKeys.contains(task.id)) {
      completedKeys.remove(task.id);
      _undoTodayStreak();
    } else {
      completedKeys.add(task.id);
      _refreshStreak();
    }
  }

  GardenPlant? plantById(String id) {
    for (final plant in plants) {
      if (plant.id == id) return plant;
    }
    return null;
  }

  GardenTask? get nextAction {
    final due = _tasksOn(today).where((task) => !task.done);
    for (final task in due) {
      if (task.kind == 'water') return task;
    }
    return due.isEmpty ? null : due.first;
  }

  int get dailyRemaining =>
      _tasksOn(today).where((task) => !task.done).length;

  bool isInGarden(String imagePath) =>
      plants.any((plant) => plant.imagePath == imagePath);

  bool hasPlantNamed(String name) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return false;
    return plants.any((plant) => plant.name.toLowerCase() == n);
  }

  bool isOnWishlist(String imagePath) =>
      wishlist.any((item) => item.imagePath == imagePath);

  List<GardenDiaryEntry> diaryFor(String plantId) {
    final items = diary.where((entry) => entry.plantId == plantId).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  String? coverPathFor(GardenGroup group) =>
      group.coverImagePath ?? lastPlantFor(group.id)?.imagePath;

  bool coverIsAssetFor(GardenGroup group) {
    if (group.coverImagePath != null) return group.coverIsAsset;
    return lastPlantFor(group.id)?.isAssetImage ?? true;
  }

  void _refreshStreak() {
    final todays = _tasksOn(today);
    if (todays.isEmpty) return;
    if (todays.any((task) => !task.done)) return;
    final last = lastStreakDay.value;
    if (last != null && isSameDay(last, today)) return;
    if (last != null &&
        isSameDay(last, today.subtract(const Duration(days: 1)))) {
      careStreak.value = careStreak.value + 1;
    } else {
      careStreak.value = 1;
    }
    lastStreakDay.value = today;
  }

  void _undoTodayStreak() {
    final last = lastStreakDay.value;
    if (last == null || !isSameDay(last, today)) return;
    final todays = _tasksOn(today);
    if (todays.isEmpty || todays.every((task) => task.done)) return;
    careStreak.value = (careStreak.value - 1).clamp(0, 999);
    lastStreakDay.value = careStreak.value <= 0
        ? null
        : today.subtract(const Duration(days: 1));
  }

  int waterIntervalFor(GardenPlant plant) =>
      PlantCareEngine.intervalDays(plant.care);

  DateTime nextWaterDateFor(GardenPlant plant) =>
      PlantCareEngine.nextWaterDate(plant);

  bool hasTasksOn(DateTime date) => _tasksOn(date).isNotEmpty;

  String nextWaterLabel(GardenPlant plant) {
    final next = nextWaterDateFor(plant);
    if (PlantCareEngine.isSameDay(next, today)) return 'Today';
    if (PlantCareEngine.isSameDay(next, today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    }
    return DateFormat('EEE d MMM').format(next);
  }

  void markWatered(GardenPlant plant, {bool notify = true}) {
    _applyWatered(plant);
    _refreshStreak();
    if (!notify) return;
    final next = nextWaterDateFor(plant);
    CustomSnackbar.success(
      title: 'Watered',
      message: plant.care.syncCalendar
          ? 'Next water ${DateFormat('EEE d MMM').format(next)} is on the Care calendar'
          : 'Next water ${DateFormat('EEE d MMM').format(next)}',
      actionLabel: 'Undo',
      onAction: () {
        final current = plantById(plant.id);
        if (current != null) undoWatered(current);
      },
    );
  }

  void markAllDueWatered() {
    final due = plants
        .where((plant) => PlantCareEngine.waterDueOn(plant, today))
        .toList();
    if (due.isEmpty) return;
    final snapshots = [...due];
    for (final plant in due) {
      _applyWatered(plant);
    }
    _refreshStreak();
    CustomSnackbar.success(
      title: 'Watered',
      message: due.length == 1
          ? 'Next water ${DateFormat('EEE d MMM').format(nextWaterDateFor(due.first))}'
          : '${due.length} plants watered',
      actionLabel: 'Undo',
      onAction: () {
        for (final plant in snapshots) {
          final current = plantById(plant.id);
          if (current != null) undoWatered(current);
        }
      },
    );
  }

  void _applyWatered(GardenPlant plant) {
    final interval = waterIntervalFor(plant);
    final next = today.add(Duration(days: interval));
    updatePlant(
      plant.copyWith(
        care: plant.care.copyWith(
          lastWateredAt: DateTime.now(),
          nextWaterOn: next,
        ),
      ),
    );
  }

  void undoWatered(GardenPlant plant) {
    updatePlant(
      plant.copyWith(
        care: plant.care.copyWith(
          nextWaterOn: today,
          clearLastWatered: true,
        ),
      ),
    );
    _undoTodayStreak();
  }

  String lastWateredLabel(GardenPlant plant) {
    final last = plant.care.lastWateredAt;
    if (last == null) return 'Not set';
    final day = PlantCareEngine.dateOnly(last);
    if (PlantCareEngine.isSameDay(day, today)) return 'Today';
    if (PlantCareEngine.isSameDay(
      day,
      today.subtract(const Duration(days: 1)),
    )) {
      return 'Yesterday';
    }
    return DateFormat('EEE d MMM').format(day);
  }

  void setLastWateredDaysAgo(GardenPlant plant, int daysAgo) {
    if (daysAgo < 0) {
      updatePlant(
        plant.copyWith(
          care: plant.care.copyWith(
            nextWaterOn: today,
            clearLastWatered: true,
          ),
        ),
      );
      return;
    }
    final last = today.subtract(Duration(days: daysAgo));
    final next = last.add(Duration(days: waterIntervalFor(plant)));
    updatePlant(
      plant.copyWith(
        care: plant.care.copyWith(
          lastWateredAt: last,
          nextWaterOn: next,
        ),
      ),
    );
  }

  void snoozeWater(GardenPlant plant, int days) {
    final next = today.add(Duration(days: days));
    updatePlant(
      plant.copyWith(
        care: plant.care.copyWith(nextWaterOn: next),
      ),
    );
    CustomSnackbar.info(
      title: 'Snoozed',
      message: 'Water ${plant.name} ${DateFormat('EEE d MMM').format(next)}',
    );
  }

  void setCalendarSync(GardenPlant plant, bool enabled) {
    updatePlant(
      plant.copyWith(
        care: plant.care.copyWith(syncCalendar: enabled),
      ),
    );
    if (!enabled) return;
    final next = nextWaterDateFor(plant);
    CustomSnackbar.success(
      title: 'On Care calendar',
      message:
          'Next water for ${plant.name}: ${DateFormat('EEE d MMM').format(next)} at ${plant.care.waterTime}',
    );
  }

  void applyLightReading(GardenPlant plant, String lightLevel) {
    final next = plant.copyWith(
      care: plant.care.copyWith(lightLevel: lightLevel),
    );
    updatePlant(next);
    _recomputeNextWater(next);
  }

  void _recomputeNextWater(GardenPlant plant) {
    final last = plant.care.lastWateredAt;
    if (last == null) return;
    final next = PlantCareEngine.dateOnly(last).add(
      Duration(days: waterIntervalFor(plant)),
    );
    updatePlant(
      plant.copyWith(
        care: plant.care.copyWith(nextWaterOn: next),
      ),
    );
  }

  void openWaterMeter({String? plantId}) {
    NavigationHelper.to(
      () => WaterMeterView(plantId: plantId),
    );
  }

  Future<void> openLightMeter({String? plantId}) async {
    if (Get.isRegistered<PlantScanController>()) {
      await Get.find<PlantScanController>().releaseCamera();
    }
    await NavigationHelper.to(
      () => LightMeterView(plantId: plantId),
    );
    if (!Get.isRegistered<MainNavigationController>()) return;
    if (Get.find<MainNavigationController>().selectedIndex.value != 2) return;
    if (Get.isRegistered<PlantScanController>()) {
      Get.find<PlantScanController>().startCamera();
    }
  }

  void selectMonthYear(DateTime date) {
    final year = date.year;
    final month = date.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    var day = selectedTaskDate.value.day.clamp(1, daysInMonth);
    if (today.year == year && today.month == month) {
      day = today.day;
    }
    selectedTaskDate.value = DateTime(year, month, day);
  }

  void openAddPlantSheet(
    BuildContext context, {
    String groupId = GardenGroup.generalId,
  }) {
    showAddPlantSheet(
      context,
      onTakePhoto: openIdentify,
      onChooseGallery: () =>
          pickPlantImage(ImageSource.gallery, groupId: groupId),
    );
  }

  Future<void> pickPlantImage(
    ImageSource source, {
    String groupId = GardenGroup.generalId,
  }) async {
    final path = await _capturePhoto(source);
    if (path == null) return;
    await _identifyThenSave(path, groupId: groupId);
  }

  Future<String?> _changePhotoFromEditor() {
    return _capturePhoto(ImageSource.camera);
  }

  Future<String?> _capturePhoto(ImageSource source) async {
    if (source == ImageSource.camera) {
      return NavigationHelper.to<String>(
        () => const AddPlantCameraView(),
        fullscreenDialog: true,
      );
    }
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (file == null) return null;
    return NavigationHelper.to<String>(
      () => PlantPhotoReviewView(imagePath: file.path),
      fullscreenDialog: true,
    );
  }

  Future<void> _identifyThenSave(
    String path, {
    String groupId = GardenGroup.generalId,
  }) async {
    final result = await IdentifyFlow.runSingle(imagePath: path);
    if (result == null) return;
    final plantId = await NavigationHelper.to<String>(
      () => IdentifyResultView(
        result: result.copyWith(imagePath: path),
        groupId: groupId,
      ),
    );
    if (plantId == null || plantId.isEmpty) return;
  }

  Future<String?> cropPlantImage(String path) async {
    final context = _sheetContext;
    if (context == null || !context.mounted) return path;
    return showPlantCropSheet(context, path);
  }

  String _fallbackPlantName() => LocalPlantIdentifyRepository.unnamedPlant;

  String _groupTitle(String groupId) {
    return groups
        .firstWhere(
          (group) => group.id == groupId,
          orElse: () => const GardenGroup(
            id: GardenGroup.generalId,
            title: 'General',
          ),
        )
        .title;
  }

  GardenPlant addPickedPlant(
    String path, {
    String? name,
    String scientificName = '',
    String groupId = GardenGroup.generalId,
    GardenCareSchedule? care,
    bool notify = true,
  }) {
    final resolvedName =
        (name != null && name.trim().isNotEmpty) ? name.trim() : _fallbackPlantName();

    final plant = GardenPlant(
      id: 'plant-${DateTime.now().millisecondsSinceEpoch}',
      name: resolvedName,
      imagePath: path,
      scientificName: scientificName,
      groupId: groupId,
      care: (care ?? const GardenCareSchedule()).copyWith(nextWaterOn: today),
    );
    plants.insert(0, plant);
    wishlist.removeWhere(
      (item) =>
          item.imagePath == path ||
          item.name.toLowerCase() == resolvedName.toLowerCase(),
    );
    _undoTodayStreak();
    if (notify) {
      CustomSnackbar.success(
        title: 'Added to garden',
        message: '$resolvedName added to ${_groupTitle(groupId)}',
      );
    }
    return plant;
  }

  Future<GardenPlant> addPickedPlantFromScan({
    required String path,
    String? name,
    String scientificName = '',
    String groupId = GardenGroup.generalId,
    GardenCareSchedule? care,
  }) async {
    final stored = await persistPhotoIfNeeded(path);
    return addPickedPlant(
      stored,
      name: name,
      scientificName: scientificName,
      groupId: groupId,
      care: care,
      notify: false,
    );
  }

  Future<void> addToWishlist({
    required String imagePath,
    required String name,
    String scientificName = '',
    bool notify = true,
  }) async {
    final resolvedName =
        name.trim().isEmpty ? _fallbackPlantName() : name.trim();
    final stored = await persistPhotoIfNeeded(imagePath);
    if (isInGarden(stored)) {
      CustomSnackbar.info(title: 'Already in garden', message: resolvedName);
      return;
    }
    if (isOnWishlist(stored)) {
      CustomSnackbar.info(title: 'On wishlist', message: resolvedName);
      return;
    }
    wishlist.insert(
      0,
      GardenWishlistItem(
        id: 'wish-${DateTime.now().millisecondsSinceEpoch}',
        name: resolvedName,
        scientificName: scientificName,
        imagePath: stored,
        dateLabel: 'Today',
      ),
    );
    if (notify) {
      CustomSnackbar.success(
        title: 'Saved to wishlist',
        message: resolvedName,
      );
    }
  }

  void removeWishlistItem(GardenWishlistItem item) {
    final index = wishlist.indexWhere((entry) => entry.id == item.id);
    if (index < 0) return;
    final removed = wishlist.removeAt(index);
    CustomSnackbar.info(
      title: 'Removed from wishlist',
      message: removed.name,
      actionLabel: 'Undo',
      onAction: () {
        final insertAt = index.clamp(0, wishlist.length);
        if (wishlist.any((entry) => entry.id == removed.id)) return;
        wishlist.insert(insertAt, removed);
      },
    );
  }

  Future<void> saveWishlistToGarden(GardenWishlistItem item) async {
    if (isInGarden(item.imagePath)) {
      CustomSnackbar.info(title: 'Already in garden', message: item.name);
      return;
    }
    final saved = await saveCapturedPlant(
      item.imagePath,
      name: item.name,
      scientificName: item.scientificName,
    );
    if (saved) {
      wishlist.removeWhere((entry) => entry.id == item.id);
    }
  }

  void addSnapToWishlist(GardenSnap snap) {
    addToWishlist(
      imagePath: snap.imagePath,
      name: snap.name,
      scientificName: snap.scientificName,
    );
  }

  Future<void> addDiaryPhoto(GardenPlant plant) async {
    final captured = await _capturePhoto(ImageSource.camera);
    if (captured == null) return;
    final path = captured.startsWith('assets/')
        ? captured
        : await PlantImageStore.persistCopy(captured);
    final context = _sheetContext;
    if (context == null || !context.mounted) return;
    final note = await showDiaryNoteSheet(context);
    if (note == null) return;
    diary.insert(
      0,
      GardenDiaryEntry(
        id: 'diary-${DateTime.now().millisecondsSinceEpoch}',
        plantId: plant.id,
        imagePath: path,
        createdAt: DateTime.now(),
        note: note.trim(),
      ),
    );
  }

  void deleteDiaryEntry(GardenDiaryEntry entry) {
    final index = diary.indexWhere((item) => item.id == entry.id);
    if (index < 0) return;
    final removed = diary.removeAt(index);
    CustomSnackbar.info(
      title: 'Photo removed',
      message: DateFormat('d MMM').format(removed.createdAt),
      actionLabel: 'Undo',
      onAction: () {
        final insertAt = index.clamp(0, diary.length);
        if (diary.any((item) => item.id == removed.id)) return;
        diary.insert(insertAt, removed);
      },
    );
  }

  Future<void> openPlantEditor(BuildContext context, GardenPlant plant) async {
    final draft = await showPlantEditorSheet(
      context,
      imagePath: plant.imagePath,
      isAssetImage: plant.isAssetImage,
      initialName: plant.name,
      isNew: false,
      onPickPhoto: _changePhotoFromEditor,
      onCrop: cropPlantImage,
    );
    if (draft == null) return;
    if (draft.deleted) {
      deletePlant(plant);
      return;
    }
    updatePlant(
      plant.copyWith(
        name: draft.name,
        imagePath: draft.imagePath,
      ),
    );
  }

  void updatePlant(GardenPlant plant) {
    final index = plants.indexWhere((item) => item.id == plant.id);
    if (index < 0) return;
    plants[index] = plant;
    plants.refresh();
  }

  void updateCare(GardenPlant plant, GardenCareSchedule care) {
    final next = plant.copyWith(care: care);
    updatePlant(next);
    _recomputeNextWater(next);
  }

  Future<bool> confirmDeletePlant(GardenPlant plant) async {
    final context = _sheetContext;
    if (context == null) return false;
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text('Remove ${plant.name}?'),
          content: const Text('This plant will leave your garden.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
    if (ok != true) return false;
    deletePlant(plant);
    return true;
  }

  void deletePlant(GardenPlant plant) {
    final index = plants.indexWhere((item) => item.id == plant.id);
    if (index < 0) return;

    final removed = plants.removeAt(index);
    diary.removeWhere((entry) => entry.plantId == removed.id);
    if (plants.length < 2) selectedGroupId.value = null;
    CustomSnackbar.info(
      title: 'Plant deleted',
      message: removed.name,
      actionLabel: 'Undo',
      onAction: () {
        final insertAt = index.clamp(0, plants.length);
        if (plants.any((item) => item.id == removed.id)) return;
        plants.insert(insertAt, removed);
      },
    );
  }

  void openPlantFinder() {
    NavigationHelper.toNamed(RouteNames.plantFinder);
  }

  void openCare() {
    homeTab.value = 1;
  }

  void openSnapHistory() {
    homeTab.value = 2;
    snapCollectionTab.value = 0;
  }

  void openWishlistCollection() {
    homeTab.value = 2;
    snapCollectionTab.value = 1;
  }

  void selectHomeTab(int index) {
    homeTab.value = index;
  }

  /// Copies camera/temp photos into app documents so garden data survives restarts.
  Future<String> persistPhotoIfNeeded(String path) async {
    if (path.startsWith('assets/')) return path;
    if (path.replaceAll('\\', '/').contains('/ai_plant_images/')) {
      return path;
    }
    try {
      return await PlantImageStore.persistCopy(path);
    } catch (_) {
      return path;
    }
  }

  void navigateToGardenTab() {
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>().onTabTapped(
      MainNavigationController.gardenIndex,
    );
  }

  void completeGardenSave(String plantId, {String? groupId}) {
    selectHomeTab(0);
    if (groupId != null && groupId.isNotEmpty) {
      selectedGroupId.value = groupId;
    }
    navigateToGardenTab();
    final plant = plantById(plantId);
    CustomSnackbar.success(
      title: 'Added to garden',
      message: plant == null
          ? 'Saved'
          : '${plant.name} added to ${_groupTitle(plant.groupId)}',
    );
  }

  void completeWishlistSave(String name) {
    openWishlistCollection();
    navigateToGardenTab();
    CustomSnackbar.success(
      title: 'Saved to wishlist',
      message: name,
    );
  }

  Future<String> recordIdentifySnap(
    String path, {
    String name = '',
    String scientificName = '',
  }) async {
    final stored = await persistPhotoIfNeeded(path);
    addIdentifySnap(
      stored,
      name: name,
      scientificName: scientificName,
    );
    return stored;
  }

  void openNewGroupSheet(BuildContext context) {
    showNewGroupSheet(context, onSave: addGroup);
  }

  void openGroupEditor(BuildContext context, GardenGroup group) {
    showNewGroupSheet(
      context,
      title: 'Edit Group',
      confirmLabel: 'Save',
      initialName: group.title,
      canDelete: group.id != GardenGroup.generalId,
      onSave: (name) => renameGroup(group.id, name),
      onDelete: () => deleteGroup(group),
    );
  }

  int plantCountFor(String groupId) =>
      plants.where((plant) => plant.groupId == groupId).length;

  GardenPlant? firstPlantFor(String groupId) {
    for (final plant in plants) {
      if (plant.groupId == groupId) return plant;
    }
    return null;
  }

  GardenPlant? lastPlantFor(String groupId) {
    GardenPlant? found;
    for (final plant in plants) {
      if (plant.groupId == groupId) found = plant;
    }
    return found;
  }

  void openPlantDetail(GardenPlant plant) {
    NavigationHelper.to(
      () => GardenPlantDetailView(plantId: plant.id),
      transition: Transition.native,
    );
  }

  void openPlantMore(BuildContext context, GardenPlant plant) {
    showPlantMoreSheet(
      context,
      onEditName: () {
        Future<void>.delayed(const Duration(milliseconds: 220), () {
          if (!context.mounted) return;
          showNewGroupSheet(
            context,
            title: 'Edit Name',
            confirmLabel: 'Save',
            initialName: plant.name,
            onSave: (name) => updatePlant(plant.copyWith(name: name)),
          );
        });
      },
      onChangeGroup: () {
        Future<void>.delayed(const Duration(milliseconds: 220), () {
          if (!context.mounted) return;
          showChangeGroupSheet(
            context,
            groups: groups.toList(),
            selectedId: plant.groupId,
            onSelect: (id) => updatePlant(plant.copyWith(groupId: id)),
          );
        });
      },
      onAskBotanist: () {
        Future<void>.delayed(const Duration(milliseconds: 220), () {
          openBotanistChat(
            plantName: plant.name,
            imagePath: plant.imagePath,
            isAssetImage: plant.isAssetImage,
            plantId: plant.id,
          );
        });
      },
      onDelete: () => confirmDeletePlant(plant),
    );
  }

  Future<void> openCareTaskEditor(
    BuildContext context,
    GardenPlant plant,
    GardenCareKind kind,
  ) async {
    final draft = await showEditCareTaskSheet(
      context,
      plant: plant,
      kind: kind,
    );
    if (draft == null || draft.deleted) return;
    final next = plant.copyWith(care: _careFromDraft(plant.care, kind, draft));
    updatePlant(next);
    if (kind == GardenCareKind.water) _recomputeNextWater(next);
  }

  GardenCareSchedule _careFromDraft(
    GardenCareSchedule care,
    GardenCareKind kind,
    CareTaskDraft draft,
  ) {
    final number = int.tryParse(draft.repeatLabel.split(' ').first) ?? 7;
    final next = care.copyWith(
      autoReminders: draft.autoReminders,
      waterTime: draft.time,
    );
    return switch (kind) {
      GardenCareKind.water => next.copyWith(waterDays: number),
      GardenCareKind.mist => next.copyWith(mistDays: number),
      GardenCareKind.fertilizer => next.copyWith(fertilizerMonths: number),
      GardenCareKind.rotate => next.copyWith(rotateMonths: number),
      GardenCareKind.cut => next.copyWith(cutMonths: number),
    };
  }

  void addGroup(String title) {
    final name = title.trim();
    if (name.isEmpty) return;
    if (groups.any((group) => group.title.toLowerCase() == name.toLowerCase())) {
      CustomSnackbar.info(title: 'Group exists', message: name);
      return;
    }
    groups.add(
      GardenGroup(
        id: 'group-${DateTime.now().millisecondsSinceEpoch}',
        title: name,
      ),
    );
    CustomSnackbar.success(title: 'Group created', message: name);
  }

  void renameGroup(String groupId, String title) {
    final name = title.trim();
    if (name.isEmpty) return;
    if (groups.any(
      (group) =>
          group.id != groupId && group.title.toLowerCase() == name.toLowerCase(),
    )) {
      CustomSnackbar.info(title: 'Group exists', message: name);
      return;
    }
    final index = groups.indexWhere((group) => group.id == groupId);
    if (index < 0) return;
    groups[index] = groups[index].copyWith(title: name);
    groups.refresh();
  }

  void deleteGroup(GardenGroup group) {
    if (group.id == GardenGroup.generalId) return;

    for (var i = 0; i < plants.length; i++) {
      if (plants[i].groupId == group.id) {
        plants[i] = plants[i].copyWith(groupId: GardenGroup.generalId);
      }
    }
    groups.removeWhere((item) => item.id == group.id);
    if (selectedGroupId.value == group.id) selectedGroupId.value = null;
    plants.refresh();
    CustomSnackbar.info(
      title: 'Group deleted',
      message: 'Plants moved to General',
    );
  }

  void openSeenIdentify(GardenSnap snap) {
    final result = PlantIdentifyResult.fromHistory(
      imagePath: snap.imagePath,
      commonName: snap.name,
      scientificName: snap.scientificName,
      sampleImageAsset: snap.isAssetImage ? snap.imagePath : null,
    );
    NavigationHelper.to(() => IdentifyResultView(result: result));
  }

  void openIdentify() {
    if (Get.key.currentState?.canPop() ?? false) {
      NavigationHelper.back();
    }
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>()
        .onTabTapped(MainNavigationController.scanIndex);
  }

  void deleteSnap(GardenSnap snap) {
    final index = snaps.indexWhere((item) => item.id == snap.id);
    if (index < 0) return;

    final removed = snaps.removeAt(index);
    CustomSnackbar.info(
      title: 'Snap deleted',
      message: removed.name,
      actionLabel: 'Undo',
      onAction: () {
        final insertAt = index.clamp(0, snaps.length);
        if (snaps.any((item) => item.id == removed.id)) return;
        snaps.insert(insertAt, removed);
      },
    );
  }

  void addIdentifySnap(
    String path, {
    String name = '',
    String scientificName = '',
  }) {
    final resolvedName =
        name.trim().isEmpty ? _fallbackPlantName() : name.trim();
    final existing = snaps.indexWhere((snap) => snap.imagePath == path);
    if (existing >= 0) {
      final current = snaps[existing];
      snaps[existing] = GardenSnap(
        id: current.id,
        name: resolvedName,
        scientificName: scientificName,
        imagePath: path,
        dateLabel: 'Today',
      );
      if (existing != 0) {
        final updated = snaps.removeAt(existing);
        snaps.insert(0, updated);
      }
      return;
    }
    snaps.insert(
      0,
      GardenSnap(
        id: 'snap-${DateTime.now().millisecondsSinceEpoch}',
        name: resolvedName,
        scientificName: scientificName,
        imagePath: path,
        dateLabel: 'Today',
      ),
    );
  }

  Future<bool> saveCapturedPlant(
    String path, {
    String? name,
    String scientificName = '',
    String groupId = GardenGroup.generalId,
  }) async {
    final fallback = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : _fallbackPlantName();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final cropped = await cropPlantImage(path);
    if (cropped == null) return false;
    final context = _sheetContext;
    if (context == null || !context.mounted) {
      addPickedPlant(
        cropped,
        name: fallback,
        scientificName: scientificName,
        groupId: groupId,
      );
      return true;
    }
    final draft = await showPlantEditorSheet(
      context,
      imagePath: cropped,
      isAssetImage: path.startsWith('assets/'),
      initialName: fallback,
      isNew: true,
      onPickPhoto: _changePhotoFromEditor,
      onCrop: cropPlantImage,
    );
    if (draft == null || draft.deleted) return false;
    addPickedPlant(
      draft.imagePath,
      name: draft.name,
      scientificName: scientificName,
      groupId: groupId,
    );
    return true;
  }

  Future<void> addSnapToGarden(GardenSnap snap) async {
    if (plants.any((plant) => plant.imagePath == snap.imagePath)) {
      CustomSnackbar.info(
        title: 'Already in garden',
        message: snap.name,
      );
      return;
    }
    await saveCapturedPlant(
      snap.imagePath,
      name: snap.name,
      scientificName: snap.scientificName,
    );
  }
}

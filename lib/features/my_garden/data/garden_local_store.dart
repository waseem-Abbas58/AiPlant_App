import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/my_garden_model.dart';

/// Local garden snapshot. Swap later for a cloud garden API.
class GardenLocalStore {
  GardenLocalStore._();

  static const _key = 'garden_local_v1'; 

  static Future<GardenLocalSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return GardenLocalSnapshot.fromJson(map);  
    } catch (_) {
      return null; 
    }
  }

  static Future<void> save(GardenLocalSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance(); 
    await prefs.setString(_key, jsonEncode(snapshot.toJson()));  
  }
}

class GardenLocalSnapshot {
  const GardenLocalSnapshot({
    required this.plants,
    required this.groups,
    required this.snaps,
    required this.wishlist,
    required this.diary,
    required this.completedKeys,
    required this.careStreak,
    this.lastStreakDay,
  });

  final List<GardenPlant> plants;
  final List<GardenGroup> groups;
  final List<GardenSnap> snaps;
  final List<GardenWishlistItem> wishlist;
  final List<GardenDiaryEntry> diary;
  final Set<String> completedKeys;
  final int careStreak;
  final DateTime? lastStreakDay;

  Map<String, dynamic> toJson() => {
        'plants': plants.map((e) => e.toJson()).toList(),
        'groups': groups.map((e) => e.toJson()).toList(),
        'snaps': snaps.map((e) => e.toJson()).toList(),  
        'wishlist': wishlist.map((e) => e.toJson()).toList(),
        'diary': diary.map((e) => e.toJson()).toList(),  
        'completedKeys': completedKeys.toList(),
        'careStreak': careStreak,
        'lastStreakDay': lastStreakDay?.toIso8601String(),
      };

  factory GardenLocalSnapshot.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) {
      final raw = json[key];
      if (raw is! List) return <T>[];
      return raw
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList();
    }

    final groups = list('groups', GardenGroup.fromJson);
    if (!groups.any((g) => g.id == GardenGroup.generalId)) {
      groups.insert(0, GardenGroup.general);
    }

    return GardenLocalSnapshot(
      plants: list('plants', GardenPlant.fromJson)
          .where(_imageOk)
          .toList(),
      groups: groups,
      snaps: list('snaps', GardenSnap.fromJson).where(_snapOk).toList(),
      wishlist:
          list('wishlist', GardenWishlistItem.fromJson).where(_wishOk).toList(),
      diary: list('diary', GardenDiaryEntry.fromJson).where(_diaryOk).toList(),
      completedKeys: {
        for (final key in (json['completedKeys'] as List? ?? const []))
          if (key is String && key.isNotEmpty) key,
      },
      careStreak: (json['careStreak'] as num?)?.toInt() ?? 0,
      lastStreakDay: _date(json['lastStreakDay']),
    );
  }

  static DateTime? _date(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static bool _imageOk(GardenPlant plant) {
    if (plant.isAssetImage) return true;
    return File(plant.imagePath).existsSync();
  }

  static bool _snapOk(GardenSnap snap) {
    if (snap.isAssetImage) return true;
    return File(snap.imagePath).existsSync();
  }

  static bool _wishOk(GardenWishlistItem item) {
    if (item.isAssetImage) return true;
    return File(item.imagePath).existsSync();
  }

  static bool _diaryOk(GardenDiaryEntry entry) {
    if (entry.isAssetImage) return true;
    return File(entry.imagePath).existsSync();
  }
}

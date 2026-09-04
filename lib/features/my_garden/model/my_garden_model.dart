class GardenSnap {
  const GardenSnap({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.imagePath,
    required this.dateLabel,
  });

  final String id;
  final String name;
  final String scientificName;
  final String imagePath;
  final String dateLabel;

  bool get isAssetImage => imagePath.startsWith('assets/');

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scientificName': scientificName,
        'imagePath': imagePath,
        'dateLabel': dateLabel,
      };

  factory GardenSnap.fromJson(Map<String, dynamic> json) {
    return GardenSnap(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      dateLabel: json['dateLabel'] as String? ?? '',
    );
  }
}

class GardenWishlistItem {
  const GardenWishlistItem({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.imagePath,
    required this.dateLabel,
  });

  final String id;
  final String name;
  final String scientificName;
  final String imagePath;
  final String dateLabel;

  bool get isAssetImage => imagePath.startsWith('assets/');

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scientificName': scientificName,
        'imagePath': imagePath,
        'dateLabel': dateLabel,
      };

  factory GardenWishlistItem.fromJson(Map<String, dynamic> json) {
    return GardenWishlistItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      dateLabel: json['dateLabel'] as String? ?? '',
    );
  }
}

class GardenDiaryEntry {
  const GardenDiaryEntry({
    required this.id,
    required this.plantId,
    required this.imagePath,
    required this.createdAt,
    this.note = '',
  });

  final String id;
  final String plantId;
  final String imagePath;
  final DateTime createdAt;
  final String note;

  bool get isAssetImage => imagePath.startsWith('assets/');

  Map<String, dynamic> toJson() => {
        'id': id,
        'plantId': plantId,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };

  factory GardenDiaryEntry.fromJson(Map<String, dynamic> json) {
    return GardenDiaryEntry(
      id: json['id'] as String? ?? '',
      plantId: json['plantId'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      note: json['note'] as String? ?? '',
    );
  }
}

class GardenGroup {
  const GardenGroup({
    required this.id,
    required this.title,
    this.coverImagePath,
  });

  final String id;
  final String title;
  final String? coverImagePath;

  static const generalId = 'general';
  static const general = GardenGroup(id: generalId, title: 'General');

  bool get coverIsAsset =>
      coverImagePath != null && coverImagePath!.startsWith('assets/');

  GardenGroup copyWith({
    String? id,
    String? title,
    String? coverImagePath,
    bool clearCover = false,
  }) {
    return GardenGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      coverImagePath:
          clearCover ? null : (coverImagePath ?? this.coverImagePath),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverImagePath': coverImagePath,
      };

  factory GardenGroup.fromJson(Map<String, dynamic> json) {
    return GardenGroup(
      id: json['id'] as String? ?? generalId,
      title: json['title'] as String? ?? 'General',
      coverImagePath: json['coverImagePath'] as String?,
    );
  }
}

class GardenCareSchedule {
  const GardenCareSchedule({
    this.waterDays = 7,
    this.mistDays = 3,
    this.fertilizerMonths = 2,
    this.rotateMonths = 1,
    this.cutMonths = 6,
    this.waterAmount = 'Moderate',
    this.location = 'Indoor',
    this.potSize = 'Medium',
    this.lightLevel = 'Medium',
    this.syncCalendar = false,
    this.autoReminders = false,
    this.waterTime = '9:00 AM',
    this.lastWateredAt,
    this.nextWaterOn,
  });

  static const waterAmounts = ['Light', 'Moderate', 'Generous'];
  static const locations = ['Indoor', 'Outdoor', 'Patio'];
  static const potSizes = ['Small', 'Medium', 'Large'];
  static const lightLevels = ['Low', 'Medium', 'Bright'];

  final int waterDays;
  final int mistDays;
  final int fertilizerMonths;
  final int rotateMonths;
  final int cutMonths;
  final String waterAmount;
  final String location;
  final String potSize;
  final String lightLevel;
  final bool syncCalendar;
  final bool autoReminders;
  final String waterTime;
  final DateTime? lastWateredAt;
  final DateTime? nextWaterOn;

  GardenCareSchedule copyWith({
    int? waterDays,
    int? mistDays,
    int? fertilizerMonths,
    int? rotateMonths,
    int? cutMonths,
    String? waterAmount,
    String? location,
    String? potSize,
    String? lightLevel,
    bool? syncCalendar,
    bool? autoReminders,
    String? waterTime,
    DateTime? lastWateredAt,
    DateTime? nextWaterOn,
    bool clearLastWatered = false,
    bool clearNextWater = false,
  }) {
    return GardenCareSchedule(
      waterDays: waterDays ?? this.waterDays,
      mistDays: mistDays ?? this.mistDays,
      fertilizerMonths: fertilizerMonths ?? this.fertilizerMonths,
      rotateMonths: rotateMonths ?? this.rotateMonths,
      cutMonths: cutMonths ?? this.cutMonths,
      waterAmount: waterAmount ?? this.waterAmount,
      location: location ?? this.location,
      potSize: potSize ?? this.potSize,
      lightLevel: lightLevel ?? this.lightLevel,
      syncCalendar: syncCalendar ?? this.syncCalendar,
      autoReminders: autoReminders ?? this.autoReminders,
      waterTime: waterTime ?? this.waterTime,
      lastWateredAt:
          clearLastWatered ? null : (lastWateredAt ?? this.lastWateredAt),
      nextWaterOn: clearNextWater ? null : (nextWaterOn ?? this.nextWaterOn),
    );
  }

  Map<String, dynamic> toJson() => {
        'waterDays': waterDays,
        'mistDays': mistDays,
        'fertilizerMonths': fertilizerMonths,
        'rotateMonths': rotateMonths,
        'cutMonths': cutMonths,
        'waterAmount': waterAmount,
        'location': location,
        'potSize': potSize,
        'lightLevel': lightLevel,
        'syncCalendar': syncCalendar,
        'autoReminders': autoReminders,
        'waterTime': waterTime,
        'lastWateredAt': lastWateredAt?.toIso8601String(),
        'nextWaterOn': nextWaterOn?.toIso8601String(),
      };

  factory GardenCareSchedule.fromJson(Map<String, dynamic> json) {
    DateTime? date(Object? value) {
      if (value is! String || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    return GardenCareSchedule(
      waterDays: (json['waterDays'] as num?)?.toInt() ?? 7,
      mistDays: (json['mistDays'] as num?)?.toInt() ?? 3,
      fertilizerMonths: (json['fertilizerMonths'] as num?)?.toInt() ?? 2,
      rotateMonths: (json['rotateMonths'] as num?)?.toInt() ?? 1,
      cutMonths: (json['cutMonths'] as num?)?.toInt() ?? 6,
      waterAmount: json['waterAmount'] as String? ?? 'Moderate',
      location: json['location'] as String? ?? 'Indoor',
      potSize: json['potSize'] as String? ?? 'Medium',
      lightLevel: json['lightLevel'] as String? ?? 'Medium',
      syncCalendar: json['syncCalendar'] as bool? ?? false,
      autoReminders: json['autoReminders'] as bool? ?? false,
      waterTime: json['waterTime'] as String? ?? '9:00 AM',
      lastWateredAt: date(json['lastWateredAt']),
      nextWaterOn: date(json['nextWaterOn']),
    );
  }
}

class GardenPlant {
  GardenPlant({
    required this.id,
    required this.name,
    required this.imagePath,
    this.status = '',
    this.scientificName = '',
    this.groupId = GardenGroup.generalId,
    this.notes = '',
    this.care = const GardenCareSchedule(),
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String imagePath;
  final String status;
  final String scientificName;
  final String groupId;
  final String notes;
  final GardenCareSchedule care;
  final DateTime createdAt;

  bool get isAssetImage => imagePath.startsWith('assets/');

  String get displayScientific {
    final value = scientificName.trim();
    if (value.isEmpty) return '';
    if (value.toLowerCase() == name.trim().toLowerCase()) return '';
    return value;
  }

  GardenPlant copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? status,
    String? scientificName,
    String? groupId,
    String? notes,
    GardenCareSchedule? care,
    DateTime? createdAt,
  }) {
    return GardenPlant(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      scientificName: scientificName ?? this.scientificName,
      groupId: groupId ?? this.groupId,
      notes: notes ?? this.notes,
      care: care ?? this.care,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imagePath': imagePath,
        'status': status,
        'scientificName': scientificName,
        'groupId': groupId,
        'notes': notes,
        'care': care.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory GardenPlant.fromJson(Map<String, dynamic> json) {
    final careRaw = json['care'];
    return GardenPlant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      status: json['status'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      groupId: json['groupId'] as String? ?? GardenGroup.generalId,
      notes: json['notes'] as String? ?? '',
      care: careRaw is Map
          ? GardenCareSchedule.fromJson(Map<String, dynamic>.from(careRaw))
          : const GardenCareSchedule(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class GardenTask {
  const GardenTask({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.imagePath,
    required this.title,
    required this.timeLabel,
    required this.date,
    this.kind = 'water',
    this.done = false,
  });

  final String id;
  final String plantId;
  final String plantName;
  final String imagePath;
  final String title;
  final String timeLabel;
  final DateTime date;
  final String kind;
  final bool done;

  bool get isAssetImage => imagePath.startsWith('assets/');

  GardenTask copyWith({
    String? id,
    String? plantId,
    String? plantName,
    String? imagePath,
    String? title,
    String? timeLabel,
    DateTime? date,
    String? kind,
    bool? done,
  }) {
    return GardenTask(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      timeLabel: timeLabel ?? this.timeLabel,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      done: done ?? this.done,
    );
  }
}

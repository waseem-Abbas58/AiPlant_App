import '../model/my_garden_model.dart';

enum PlantWaterStatus { fresh, due, dry, ok }

/// Local care math. Swap later for an API that returns the next water date.
class PlantCareEngine {
  PlantCareEngine._();

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int intervalDays(GardenCareSchedule care, {DateTime? now}) {
    var days = care.waterDays;
    days += switch (care.location) {
      'Outdoor' => -1,
      'Patio' => 0,
      _ => 1,
    };
    days += switch (care.potSize) {
      'Small' => -1,
      'Large' => 1,
      _ => 0,
    };
    days += switch (care.lightLevel) {
      'Low' => 2,
      'Bright' => -1,
      _ => 0,
    };
    days += switch (care.waterAmount) {
      'Light' => 1,
      'Generous' => -1,
      _ => 0,
    };
    final month = (now ?? DateTime.now()).month;
    if (month == 12 || month <= 2) days += 2;
    if (month >= 6 && month <= 8) days -= 1;
    return days.clamp(3, 21);
  }

  static DateTime nextWaterDate(GardenPlant plant, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    if (plant.care.nextWaterOn != null) {
      return dateOnly(plant.care.nextWaterOn!);
    }
    final last = plant.care.lastWateredAt;
    if (last != null) {
      return dateOnly(last).add(Duration(days: intervalDays(plant.care, now: today)));
    }
    return today;
  }

  static bool waterDueOn(GardenPlant plant, DateTime day, {DateTime? now}) {
    final d = dateOnly(day);
    final today = dateOnly(now ?? DateTime.now());
    final next = nextWaterDate(plant, now: today);
    if (isSameDay(d, next)) return true;
    if (isSameDay(d, today) && next.isBefore(today)) return true;
    return false;
  }

  /// 1 = just watered, 0 = due or overdue. Local estimate until an API lands.
  static double moistureLevel(GardenPlant plant, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final interval = intervalDays(plant.care, now: today);
    final last = plant.care.lastWateredAt;
    if (last == null) {
      final next = nextWaterDate(plant, now: today);
      return next.isAfter(today) ? 0.5 : 0;
    }
    final elapsed = today.difference(dateOnly(last)).inDays;
    if (elapsed <= 0) return 1;
    return (1 - elapsed / interval).clamp(0.0, 1.0);
  }

  static PlantWaterStatus waterStatus(GardenPlant plant, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final last = plant.care.lastWateredAt;
    if (last != null && isSameDay(dateOnly(last), today)) {
      return PlantWaterStatus.fresh;
    }
    final next = nextWaterDate(plant, now: today);
    if (!next.isAfter(today)) return PlantWaterStatus.due;
    if (moistureLevel(plant, now: now) <= 0.28) return PlantWaterStatus.dry;
    return PlantWaterStatus.ok;
  }

  static List<GardenPlant> rankedForWater(
    List<GardenPlant> plants, {
    DateTime? now,
  }) {
    final ranked = [...plants]..sort((a, b) {
        final byDate =
            nextWaterDate(a, now: now).compareTo(nextWaterDate(b, now: now));
        if (byDate != 0) return byDate;
        return moistureLevel(a, now: now).compareTo(moistureLevel(b, now: now));
      });
    return ranked;
  }

  static GardenPlant? mostUrgent(List<GardenPlant> plants, {DateTime? now}) {
    final ranked = rankedForWater(plants, now: now);
    return ranked.isEmpty ? null : ranked.first;
  }

  static String waterWhy(GardenPlant plant) {
    final care = plant.care;
    return '${care.location} · ${care.potSize.toLowerCase()} pot · ${care.waterAmount.toLowerCase()} water';
  }

  static int daysUntilWater(GardenPlant plant, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final next = nextWaterDate(plant, now: today);
    final days = next.difference(today).inDays;
    return days < 0 ? 0 : days;
  }

  static String daysLeftLabel(GardenPlant plant, {DateTime? now}) {
    if (waterStatus(plant, now: now) == PlantWaterStatus.due) {
      return 'Due now';
    }
    final days = daysUntilWater(plant, now: now);
    if (days == 0) return 'Due today';
    if (days == 1) return '1 day left';
    return '$days days left';
  }

  static int moisturePercent(GardenPlant plant, {DateTime? now}) =>
      (moistureLevel(plant, now: now) * 100).round();

  /// Local pour size until an API returns a species volume.
  static int waterAmountMl(GardenCareSchedule care) {
    final base = switch (care.potSize) {
      'Small' => 120,
      'Large' => 350,
      _ => 220,
    };
    return switch (care.waterAmount) {
      'Light' => (base * 0.7).round(),
      'Generous' => (base * 1.4).round(),
      _ => base,
    };
  }

  /// Local species defaults until an API returns a care plan.
  static GardenCareSchedule sampleCareFor(String commonName) {
    return switch (commonName) {
      'Snake Plant' => const GardenCareSchedule(
          waterDays: 14,
          waterAmount: 'Light',
          potSize: 'Medium',
          location: 'Indoor',
          lightLevel: 'Low',
        ),
      'Fiddle Leaf Fig' => const GardenCareSchedule(
          waterDays: 7,
          waterAmount: 'Moderate',
          potSize: 'Large',
          location: 'Indoor',
          lightLevel: 'Bright',
        ),
      'Rubber Plant' => const GardenCareSchedule(
          waterDays: 7,
          waterAmount: 'Moderate',
          potSize: 'Large',
          location: 'Indoor',
          lightLevel: 'Bright',
        ),
      'Corn Plant' => const GardenCareSchedule(
          waterDays: 10,
          waterAmount: 'Moderate',
          potSize: 'Medium',
          location: 'Indoor',
          lightLevel: 'Medium',
        ),
      'Olive' => const GardenCareSchedule(
          waterDays: 10,
          waterAmount: 'Light',
          potSize: 'Medium',
          location: 'Outdoor',
          lightLevel: 'Bright',
        ),
      'Peace Lily' => const GardenCareSchedule(
          waterDays: 5,
          waterAmount: 'Generous',
          potSize: 'Medium',
          location: 'Indoor',
          lightLevel: 'Low',
        ),
      'Monstera' => const GardenCareSchedule(
          waterDays: 7,
          waterAmount: 'Moderate',
          potSize: 'Medium',
          location: 'Indoor',
          lightLevel: 'Medium',
        ),
      "Devil's Ivy" => const GardenCareSchedule(
          waterDays: 7,
          waterAmount: 'Moderate',
          potSize: 'Medium',
          location: 'Indoor',
          lightLevel: 'Medium',
        ),
      'Aloe Vera' => const GardenCareSchedule(
          waterDays: 14,
          waterAmount: 'Light',
          potSize: 'Small',
          location: 'Indoor',
          lightLevel: 'Bright',
        ),
      'Orchid' => const GardenCareSchedule(
          waterDays: 7,
          waterAmount: 'Light',
          potSize: 'Small',
          location: 'Indoor',
          lightLevel: 'Medium',
        ),
      _ => const GardenCareSchedule(),
    };
  }

  static String waterHighlight(GardenCareSchedule care) =>
      'Every ${intervalDays(care)} days · ${waterAmountLabel(care)}';

  static String waterAmountLabel(GardenCareSchedule care) {
    final ml = waterAmountMl(care);
    final cups = ml / 240;
    final cup = switch (cups) {
      < 0.4 => '⅓ cup',
      < 0.6 => '½ cup',
      < 0.85 => '¾ cup',
      < 1.15 => '1 cup',
      < 1.4 => '1¼ cups',
      < 1.8 => '1½ cups',
      _ => '2 cups',
    };
    return '$ml ml · $cup';
  }

  static String lightLabel(double luminance) {
    if (luminance < 40) return 'Low';
    if (luminance > 140) return 'Bright';
    return 'Medium';
  }

  static String lightHint(double luminance) {
    if (luminance < 40) return 'Too dark';
    if (luminance > 140) return 'Very bright';
    return 'Good light';
  }
}

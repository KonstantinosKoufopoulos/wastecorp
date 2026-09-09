import 'package:hive_flutter/hive_flutter.dart';

/// Local persistence via Hive. Ads/IAP stubs live elsewhere later — not in tutorial.
class StorageService {
  StorageService._();

  static const boxName = 'waste_corp';
  static const keyTutorialStep = 'tutorial_step';
  static const keyCash = 'cash';
  static const keyReputation = 'reputation';
  static const keyHasWorker = 'has_worker';
  static const keyLinesOpen = 'lines_open';

  static Box<dynamic>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(boxName);
  }

  static Box<dynamic> get box {
    final b = _box;
    if (b == null) {
      throw StateError('StorageService.init() must be called first');
    }
    return b;
  }

  static int getTutorialStep() =>
      box.get(keyTutorialStep, defaultValue: 0) as int;

  static Future<void> setTutorialStep(int step) =>
      box.put(keyTutorialStep, step);

  static int getCash() => box.get(keyCash, defaultValue: 0) as int;

  static Future<void> setCash(int value) => box.put(keyCash, value);

  static int getReputation() =>
      box.get(keyReputation, defaultValue: 0) as int;

  static Future<void> setReputation(int value) =>
      box.put(keyReputation, value);

  static bool getHasWorker() =>
      box.get(keyHasWorker, defaultValue: false) as bool;

  static Future<void> setHasWorker(bool value) =>
      box.put(keyHasWorker, value);

  static bool getLinesOpen() =>
      box.get(keyLinesOpen, defaultValue: false) as bool;

  static Future<void> setLinesOpen(bool value) =>
      box.put(keyLinesOpen, value);

  static Future<void> clearAll() => box.clear();
}

import 'package:hive_flutter/hive_flutter.dart';

class SaveGameService {
  static const _boxName = 'doom_save';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<void> save(Map<String, dynamic> state) async {
    final box = Hive.box(_boxName);
    await box.put('save', state);
  }

  static Map<String, dynamic>? load() {
    final box = Hive.box(_boxName);
    final value = box.get('save');
    if (value == null) return null;
    return Map<String, dynamic>.from(value as Map);
  }

  static Future<void> clear() async {
    final box = Hive.box(_boxName);
    await box.delete('save');
  }
}

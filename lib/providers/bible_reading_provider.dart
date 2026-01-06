import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/bible_reading.dart';
import '../services/database_helper.dart';

class BibleReadingProvider extends ChangeNotifier {
  List<BibleReading> _readings = [];
  bool _isLoading = false;

  List<BibleReading> get readings => _readings;
  bool get isLoading => _isLoading;

  Future<void> loadAllReadings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query('bible_readings', orderBy: 'month, day');
      _readings = maps.map((map) => BibleReading.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading readings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<BibleReading?> getReadingByDate(int month, int day) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'bible_readings',
        where: 'month = ? AND day = ?',
        whereArgs: [month, day],
      );

      if (maps.isNotEmpty) {
        return BibleReading.fromMap(maps.first);
      }
    } catch (e) {
      debugPrint('Error getting reading: $e');
    }
    return null;
  }

  Future<void> insertReading(BibleReading reading) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        'bible_readings',
        reading.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await loadAllReadings();
    } catch (e) {
      debugPrint('Error inserting reading: $e');
    }
  }

  Future<void> updateReading(BibleReading reading) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'bible_readings',
        reading.toMap(),
        where: 'month = ? AND day = ?',
        whereArgs: [reading.month, reading.day],
      );
      await loadAllReadings();
    } catch (e) {
      debugPrint('Error updating reading: $e');
    }
  }

  Future<void> deleteAllReadings() async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('bible_readings');
      await loadAllReadings();
    } catch (e) {
      debugPrint('Error deleting readings: $e');
    }
  }
}

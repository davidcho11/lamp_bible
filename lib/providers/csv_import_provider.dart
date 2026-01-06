import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../models/bible_reading.dart';
import '../services/database_helper.dart';

class CsvImportProvider extends ChangeNotifier {
  bool _isImporting = false;
  String? _lastError;
  int _importedCount = 0;

  bool get isImporting => _isImporting;
  String? get lastError => _lastError;
  int get importedCount => _importedCount;

  Future<bool> importReadingsFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return false;

      final file = File(result.files.single.path!);
      return await importReadingsFromCsv(file);
    } catch (e) {
      _lastError = '파일 선택 실패: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> importReadingsFromCsv(File file) async {
    _isImporting = true;
    _lastError = null;
    _importedCount = 0;
    notifyListeners();

    try {
      final input = await file.readAsString();
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(input);

      if (rows.isEmpty) {
        throw Exception('CSV 파일이 비어있습니다');
      }

      // 헤더 확인
      final headers =
          rows.first.map((e) => e.toString().toLowerCase()).toList();
      if (!headers.contains('month') ||
          !headers.contains('day') ||
          !headers.contains('youtube_url')) {
        throw Exception(
            'CSV 형식이 올바르지 않습니다. month, day, youtube_url 컬럼이 필요합니다.');
      }

      final db = await DatabaseHelper.instance.database;

      // 트랜잭션으로 일괄 처리
      await db.transaction((txn) async {
        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.length < 3) continue;

          final reading = BibleReading(
            month: int.parse(row[0].toString()),
            day: int.parse(row[1].toString()),
            youtubeUrl: row[2].toString(),
            title: row.length > 3 ? row[3].toString() : '',
            chapterInfo: row.length > 4 ? row[4].toString() : null,
            isSpecial: row.length > 5 ? row[5].toString() == '1' : false,
          );

          await txn.insert(
            'bible_readings',
            reading.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          _importedCount++;
        }
      });

      _isImporting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'CSV 가져오기 실패: $e';
      _isImporting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> importBooksFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return false;

      final file = File(result.files.single.path!);
      return await importBooksFromCsv(file);
    } catch (e) {
      _lastError = '파일 선택 실패: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> importBooksFromCsv(File file) async {
    _isImporting = true;
    _lastError = null;
    _importedCount = 0;
    notifyListeners();

    try {
      final input = await file.readAsString();
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(input);

      if (rows.isEmpty) {
        throw Exception('CSV 파일이 비어있습니다');
      }

      final db = await DatabaseHelper.instance.database;

      await db.transaction((txn) async {
        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.length < 6) continue;

          final book = BibleBook(
            bookNumber: int.parse(row[0].toString()),
            testament: row[1].toString(),
            koreanName: row[2].toString(),
            englishName: row[3].toString(),
            youtubeUrl: row[4].toString(),
            author: row.length > 5 ? row[5].toString() : null,
            chaptersCount: row.length > 6 ? int.parse(row[6].toString()) : 0,
            summary: row.length > 7 ? row[7].toString() : null,
          );

          await txn.insert(
            'bible_books',
            book.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          _importedCount++;
        }
      });

      _isImporting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'CSV 가져오기 실패: $e';
      _isImporting = false;
      notifyListeners();
      return false;
    }
  }
}

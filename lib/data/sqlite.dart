import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/data/mock_db.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/data/svm30_datamodel.dart';

/// Base class that will be extended by implementations,
/// such as an SQLite based database, or a Storj DCS based database.
/// Implementations should most likely be singletons.
abstract class DatabaseManager {
  /// Get all database entries for SPS30.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop});

  /// Get all database entries for SCD30.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop});

  /// Get all database entries for SVM30.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop});
}

/// Singleton SQLite Databse Manager, implementing the common functions from [DatabaseManager].
/// This class just provides convenient functiosn for common database operations.
class SQLiteDatabaseManager extends DatabaseManager {
  static final SQLiteDatabaseManager _singleton =
      SQLiteDatabaseManager._internal();

  factory SQLiteDatabaseManager() {
    return _singleton;
  }

  SQLiteDatabaseManager._internal() {
    if (Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    } else if (Platform.isWindows && kDebugMode) {
      print('runining on Windows in debug mode, using local db');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dbPath = 'C:/Users/langstvi/OneDrive - Arcada/Documents/sensor_data.db';
    } else {
      print('Using mock DB');
      databaseFactory = databaseFactoryMock;
      //setMockDatabaseFactory(databaseFactoryMock);
    }
  }

  String dbPath = '/home/pi/IoT-Microservice/app/oracle/sensor_data.db';

  Database? _db;

  Future<Database?> get openedDatabaseFuture async {
    _db ??= await openDatabase(dbPath, readOnly: true);
    return _db;
  }

  // TODO: close the database on exit
  void closeDatabase() async => (await openedDatabaseFuture)!.close();

  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) async {
    final List<Map<String, dynamic>> maps;

    // If no date limitations are provided, we fetch all entries.
    if (start == null && stop == null) {
      maps = await (await openedDatabaseFuture)!.query('sps30_output');
    } else {
      // The question marks are filled in with values from whereArgs
      var where = '';
      if (start != null) where += 'datetime >= ?';
      if (start != null && stop != null) where += ' AND ';
      if (stop != null) where += 'datetime <= ?';

      var whereArgs = <String>[];
      // We use UTC in the database
      if (start != null)
        whereArgs.add(start.toUtc().toIso8601String().split('.')[0] + 'Z');
      if (stop != null)
        whereArgs.add(stop.toUtc().toIso8601String().split('.')[0] + 'Z');

      maps = await (await openedDatabaseFuture)!
          .query('sps30_output', where: where, whereArgs: whereArgs);
    }

    var returnList = List.generate(maps.length, (i) {
      return SPS30SensorDataEntry.createFromDB(
        maps[i]['datetime']!,
        maps[i]['d1']!,
        maps[i]['d2']!,
        maps[i]['d3']!,
        maps[i]['d4']!,
        maps[i]['d5']!,
        maps[i]['d6']!,
        maps[i]['d7']!,
        maps[i]['d8']!,
        maps[i]['d9']!,
        maps[i]['d10']!,
      );
    });
    return returnList;
  }

  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    final List<Map<String, dynamic>> maps;

    // If no date limitations are provided, we fetch all entries.
    if (start == null && stop == null) {
      maps = await (await openedDatabaseFuture)!.query('scd30_output');
    } else {
      // The question marks are filled in with values from whereArgs
      var where = '';
      if (start != null) where += 'datetime >= ?';
      if (start != null && stop != null) where += ' AND ';
      if (stop != null) where += 'datetime <= ?';

      var whereArgs = <String>[];
      // We use UTC in the database
      if (start != null)
        whereArgs.add(start.toUtc().toIso8601String().split('.')[0] + 'Z');
      if (stop != null)
        whereArgs.add(stop.toUtc().toIso8601String().split('.')[0] + 'Z');

      maps = await (await openedDatabaseFuture)!
          .query('scd30_output', where: where, whereArgs: whereArgs);
    }

    var returnList = List.generate(maps.length, (i) {
      return SCD30SensorDataEntry.createFromDB(
        maps[i]['datetime']!,
        maps[i]['d1']!,
        maps[i]['d2']!,
        maps[i]['d3']!,
      );
    });
    return returnList;
  }

  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) async {
    final List<Map<String, dynamic>> maps;

    // If no date limitations are provided, we fetch all entries.
    if (start == null && stop == null) {
      maps = await (await openedDatabaseFuture)!.query('svm30_output');
    } else {
      // The question marks are filled in with values from whereArgs
      var where = '';
      if (start != null) where += 'datetime >= ?';
      if (start != null && stop != null) where += ' AND ';
      if (stop != null) where += 'datetime <= ?';

      var whereArgs = <String>[];
      // We use UTC in the database
      if (start != null)
        whereArgs.add(start.toUtc().toIso8601String().split('.')[0] + 'Z');
      if (stop != null)
        whereArgs.add(stop.toUtc().toIso8601String().split('.')[0] + 'Z');

      maps = await (await openedDatabaseFuture)!
          .query('svm30_output', where: where, whereArgs: whereArgs);
    }

    var returnList = List.generate(maps.length, (i) {
      return SVM30SensorDataEntry.createFromDB(
        maps[i]['datetime']!,
        maps[i]['co2']!,
        maps[i]['tvoc']!,
      );
    });
    return returnList;
  }
}

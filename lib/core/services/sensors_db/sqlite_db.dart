import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/svm30_datamodel.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:universal_platform/universal_platform.dart';

/// Singleton SQLite Databse Manager, implementing the common functions from [DatabaseManager].
/// This class just provides convenient functions for common database operations.
class SQLiteDatabaseManager extends DatabaseManager {
  SQLiteDatabaseManager() {
    // Use different db path if debugging
    if (kDebugMode || kProfileMode) {
      if (UniversalPlatform.isWindows) {
        open.overrideFor(OperatingSystem.windows, _openDllOnWindows);
        print(
            'running in ${kDebugMode ? 'debug' : 'profile'} mode on Windows, using different db path, and loading shared library for sqlite3.');
        dbPath = 'C:/Users/langstvi/OneDrive - Arcada/Documents/sensor_data.db';
      } else {
        print('Running on in debug mode but not on windows...');
      }
    }
  }

  DynamicLibrary _openDllOnWindows() {
    final library = File(
        'C:/Users/langstvi/OneDrive - Arcada/Documents/sqlite-dll-win64-x64-3360000/sqlite3.dll');
    return DynamicLibrary.open(library.path);
  }

  String dbPath =
      '/home/pi/git-repos/IoT-Microservice/app/oracle/sensor_data.db';

  Database get openedDatabase => sqlite3.open(dbPath, mode: OpenMode.readOnly);

  void closeDatabase() => openedDatabase.dispose();

  ResultSet _getDBEntries(String tableName, DateTime? start, DateTime? stop) {
    final ResultSet maps;

    // If no date limitations are provided, we fetch all entries.
    if (start == null && stop == null) {
      maps = openedDatabase.select('SELECT * FROM $tableName');
    } else {
      // The question marks are filled in with values from whereArgs
      var sql = 'SELECT * FROM $tableName WHERE ';
      if (start != null) sql += 'datetime >= ?';
      if (start != null && stop != null) sql += ' AND ';
      if (stop != null) sql += 'datetime <= ?';

      var whereArgs = <String>[];
      // We use UTC in the database
      if (start != null) whereArgs.add(convertDateTimeToString(start));
      if (stop != null) whereArgs.add(convertDateTimeToString(stop));

      maps = openedDatabase.select(sql, whereArgs);
    }

    closeDatabase();

    return maps;
  }

  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) {
    var maps = _getDBEntries('sps30_output', start, stop);

    var iterable = maps.map((Row row) => SPS30SensorDataEntry.createFromDB(
          row['datetime']!,
          row['d1']!,
          row['d2']!,
          row['d3']!,
          row['d4']!,
          row['d5']!,
          row['d6']!,
          row['d7']!,
          row['d8']!,
          row['d9']!,
          row['d10']!,
        ));
    return Future.value(iterable.toList());
  }

  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) {
    var maps = _getDBEntries('scd30_output', start, stop);

    var iterable = maps.map((Row row) => SCD30SensorDataEntry.createFromDB(
          row['datetime']!,
          row['d1']!,
          row['d2']!,
          row['d3']!,
        ));
    return Future.value(iterable.toList());
  }

  Future<List<SCD41SensorDataEntry>> getSCD41Entries(
      {DateTime? start, DateTime? stop}) {
    var maps = _getDBEntries('scd41_output', start, stop);

    var iterable = maps.map((Row row) => SCD41SensorDataEntry.createFromDB(
          row['datetime']!,
          row['d1']!,
          row['d2']!,
          row['d3']!,
        ));
    return Future.value(iterable.toList());
  }

  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) {
    var maps = _getDBEntries('svm30_output', start, stop);

    var iterable = maps.map((Row row) => SVM30SensorDataEntry.createFromDB(
          row['datetime']!,
          row['co2']!,
          row['tvoc']!,
        ));
    return Future.value(iterable.toList());
  }
}

String convertDateTimeToString(DateTime datetime) =>
    datetime.toUtc().toIso8601String().split('.')[0] + 'Z';

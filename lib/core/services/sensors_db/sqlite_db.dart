import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/svm30_datamodel.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'package:universal_platform/universal_platform.dart';

/// Singleton SQLite Databse Manager, implementing the common functions from [DatabaseManager].
/// This class just provides convenient functiosn for common database operations.
class SQLiteDatabaseManager extends DatabaseManager {
  static final SQLiteDatabaseManager _singleton =
      SQLiteDatabaseManager._internal();

  factory SQLiteDatabaseManager() {
    return _singleton;
  }

  SQLiteDatabaseManager._internal() {
    if (UniversalPlatform.isDesktop) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;

      // Use different db path if debugging
      if (kDebugMode || kProfileMode) {
        print(
            'running in ${kDebugMode ? 'debug' : 'profile'} mode, using local db');
        dbPath = 'C:/Users/langstvi/OneDrive - Arcada/Documents/sensor_data.db';
      }
    } else {
      throw Exception('Running on a platform that does not support SQLite ...');
    }
  }

  String dbPath = '/home/pi/IoT-Microservice/app/oracle/sensor_data.db';

  Future<Database> get openedDatabase {
    return openDatabase(dbPath, readOnly: true, singleInstance: true);
  }

  Future<void> closeDatabase() async => (await openedDatabase).close();

  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) async {
    final List<Map<String, dynamic>> maps;

    // If no date limitations are provided, we fetch all entries.
    if (start == null && stop == null) {
      maps = await (await openedDatabase).query('sps30_output');
    } else {
      // The question marks are filled in with values from whereArgs
      var where = '';
      if (start != null) where += 'datetime >= ?';
      if (start != null && stop != null) where += ' AND ';
      if (stop != null) where += 'datetime <= ?';

      var whereArgs = <String>[];
      // We use UTC in the database
      if (start != null) whereArgs.add(convertDateTimeToString(start));
      if (stop != null) whereArgs.add(convertDateTimeToString(stop));

      maps = await (await openedDatabase)
          .query('sps30_output', where: where, whereArgs: whereArgs);
    }

    await closeDatabase();

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
      maps = await (await openedDatabase).query('scd30_output');
    } else {
      // The question marks are filled in with values from whereArgs
      var where = '';
      if (start != null) where += 'datetime >= ?';
      if (start != null && stop != null) where += ' AND ';
      if (stop != null) where += 'datetime <= ?';

      var whereArgs = <String>[];
      // We use UTC in the database
      if (start != null) whereArgs.add(convertDateTimeToString(start));
      if (stop != null) whereArgs.add(convertDateTimeToString(stop));

      maps = await (await openedDatabase)
          .query('scd30_output', where: where, whereArgs: whereArgs);
    }

    await closeDatabase();

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

  Future<List<SCD41SensorDataEntry>> getSCD41Entries(
      {DateTime? start, DateTime? stop}) async {
    final List<Map<String, dynamic>> maps;

    // If no date limitations are provided, we fetch all entries.
    if (start == null && stop == null) {
      maps = await (await openedDatabase).query('scd41_output');
    } else {
      // The question marks are filled in with values from whereArgs
      var where = '';
      if (start != null) where += 'datetime >= ?';
      if (start != null && stop != null) where += ' AND ';
      if (stop != null) where += 'datetime <= ?';

      var whereArgs = <String>[];
      // We use UTC in the database
      if (start != null) whereArgs.add(convertDateTimeToString(start));
      if (stop != null) whereArgs.add(convertDateTimeToString(stop));

      maps = await (await openedDatabase)
          .query('scd41_output', where: where, whereArgs: whereArgs);
    }

    await closeDatabase();

    var returnList = List.generate(maps.length, (i) {
      return SCD41SensorDataEntry.createFromDB(
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
      maps = await (await openedDatabase).query('svm30_output');
    } else {
      // The question marks are filled in with values from whereArgs
      var where = '';
      if (start != null) where += 'datetime >= ?';
      if (start != null && stop != null) where += ' AND ';
      if (stop != null) where += 'datetime <= ?';

      var whereArgs = <String>[];
      // We use UTC in the database
      if (start != null) whereArgs.add(convertDateTimeToString(start));
      if (stop != null) whereArgs.add(convertDateTimeToString(stop));

      maps = await (await openedDatabase)
          .query('svm30_output', where: where, whereArgs: whereArgs);
    }

    await closeDatabase();

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

String convertDateTimeToString(DateTime datetime) =>
    datetime.toUtc().toIso8601String().split('.')[0] + 'Z';

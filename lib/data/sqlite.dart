import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/data/constants.dart' show dbPath;
import 'package:flutter_iot_ui/data/mock_db.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/data/svm30_datamodel.dart';

Database db;

void initDBLib() {
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

Future<Database> openDatabaseIfNotOpen() async {
  if (db == null || db?.isOpen == false) {
    db = await openDatabase(dbPath, readOnly: true);
  }
  return db;
}

// TODO: close the database on exit
void closeDatabase() async => (await openDatabaseIfNotOpen()).close();

Future<List<SVM30SensorDataEntry>> getAllSVM30Entries() async {
  print('opening db...');
  var db = await openDatabaseIfNotOpen();
  print('IsOpen: ${db.isOpen}');
  final List<Map<String, dynamic>> maps = await db.query('svm30_output');

  var returnList = List.generate(maps.length, (i) {
    return SVM30SensorDataEntry.createFromDB(
      maps[i]['datetime'],
      maps[i]['co2'],
      maps[i]['tvoc'],
    );
  });
  return returnList;
}

Future<List<SVM30SensorDataEntry>> getSVM30EntriesBetweenDateTimes(
    DateTime start, DateTime stop) async {
  print('opening db...');
  var db = await openDatabaseIfNotOpen();
  print('IsOpen: ${db.isOpen}');
  final List<Map<String, dynamic>> maps = await db.query('svm30_output',
      // The question marks are filled in with values from whereArgs
      where: 'datetime >= ? AND datetime <= ?',
      whereArgs: [
        // We use UTC ni the database
        start.toUtc().toIso8601String().split('.')[0] + 'Z',
        stop.toUtc().toIso8601String().split('.')[0] + 'Z',
      ]);

  var returnList = List.generate(maps.length, (i) {
    return SVM30SensorDataEntry.createFromDB(
      maps[i]['datetime'],
      maps[i]['co2'],
      maps[i]['tvoc'],
    );
  });
  return returnList;
}

Future<List<SPS30SensorDataEntry>> getAllSPS30Entries() async {
  print('opening db...');
  var db = await openDatabaseIfNotOpen();
  print('IsOpen: ${db.isOpen}');
  final List<Map<String, dynamic>> maps = await db.query('sps30_output');

  var returnList = List.generate(maps.length, (i) {
    return SPS30SensorDataEntry.createFromDB(
      maps[i]['datetime'],
      maps[i]['d1'],
      maps[i]['d2'],
      maps[i]['d3'],
      maps[i]['d4'],
      maps[i]['d5'],
      maps[i]['d6'],
      maps[i]['d7'],
      maps[i]['d8'],
      maps[i]['d9'],
      maps[i]['d10'],
    );
  });
  return returnList;
}

Future<List<SCD30SensorDataEntry>> getAllSCD30Entries() async {
  print('opening db...');
  var db = await openDatabaseIfNotOpen();
  print('IsOpen: ${db.isOpen}');
  final List<Map<String, dynamic>> maps = await db.query('scd30_output');

  var returnList = List.generate(maps.length, (i) {
    return SCD30SensorDataEntry.createFromDB(
      maps[i]['datetime'],
      maps[i]['d1'],
      maps[i]['d2'],
      maps[i]['d3'],
    );
  });
  return returnList;
}

Future<List<SCD30SensorDataEntry>> getSCD30EntriesBetweenDateTimes(
    DateTime start, DateTime stop) async {
  print('opening db...');
  var db = await openDatabaseIfNotOpen();
  print('IsOpen: ${db.isOpen}');
  final List<Map<String, dynamic>> maps = await db.query('scd30_output',
      // The question marks are filled in with values from whereArgs
      where: 'datetime >= ? AND datetime <= ?',
      whereArgs: [
        // We use UTC ni the database
        start.toUtc().toIso8601String().split('.')[0] + 'Z',
        stop.toUtc().toIso8601String().split('.')[0] + 'Z',
      ]);

  var returnList = List.generate(maps.length, (i) {
    return SCD30SensorDataEntry.createFromDB(
      maps[i]['datetime'],
      maps[i]['d1'],
      maps[i]['d2'],
      maps[i]['d3'],
    );
  });
  return returnList;
}

Future<List<SPS30SensorDataEntry>> getSPS30EntriesBetweenDateTimes(
    DateTime start, DateTime stop) async {
  print('opening db...');
  var db = await openDatabaseIfNotOpen();
  print('IsOpen: ${db.isOpen}');
  final List<Map<String, dynamic>> maps = await db.query('sps30_output',
      // The question marks are filled in with values from whereArgs
      where: 'datetime >= ? AND datetime <= ?',
      whereArgs: [
        // We use UTC ni the database
        start.toUtc().toIso8601String().split('.')[0] + 'Z',
        stop.toUtc().toIso8601String().split('.')[0] + 'Z',
      ]);

  var returnList = List.generate(maps.length, (i) {
    return SPS30SensorDataEntry.createFromDB(
      maps[i]['datetime'],
      maps[i]['d1'],
      maps[i]['d2'],
      maps[i]['d3'],
      maps[i]['d4'],
      maps[i]['d5'],
      maps[i]['d6'],
      maps[i]['d7'],
      maps[i]['d8'],
      maps[i]['d9'],
      maps[i]['d10'],
    );
  });
  return returnList;
}

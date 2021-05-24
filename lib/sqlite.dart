import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void initDBLib() {
  if (Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  } else {
    print("not running on Linux, DB library not initialized");
  }
}

class SPS30DataModel {
  final DateTime timeStamp;
  final List<num> measurements;

  SPS30DataModel(this.timeStamp, this.measurements);

  SPS30DataModel.createFromDB(String dateString, String timeString, num d1,
      num d2, num d3, num d4, num d5, num d6, num d7, num d8, num d9, num d10)
      : this.timeStamp = DateTime.parse(dateString + timeString),
        this.measurements = [d1, d2, d3, d4, d5, d6, d7, d8, d9, 10];
}

Future<List<SPS30DataModel>> getAllEntries(String databasePath) async {
  print('opening db...');
  var db = await openDatabase(databasePath);
  print('IsOpen: ${db.isOpen}, path: ${db.path}');
  final List<Map<String, dynamic>> maps = await db.query('sensor_output');
  //return List.generate(maps.length, (i) {
  //return SPS30DataModel.createFromDB(maps[i]['date'], maps[i]['time'], maps[i]['name']);
  //});
  print(maps);

  // Placeholder
  //TODO: return valid data!
  return [SPS30DataModel(DateTime.now(), [])];
}

Future<SPS30DataModel> getEntriesFromDate(date) async {}

Future<SPS30DataModel> getEntriesDateRange(start, stop) async {}

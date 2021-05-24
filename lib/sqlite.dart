import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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

class SPS30SensorDataEntry {
  final DateTime timeStamp;
  final List<num> measurements;

  SPS30SensorDataEntry(this.timeStamp, this.measurements);

  SPS30SensorDataEntry.createFromDB(
    String dateString,
    String timeString,
    num d1,
    num d2,
    num d3,
    num d4,
    num d5,
    num d6,
    num d7,
    num d8,
    num d9,
    num d10,
  )   : this.timeStamp = DateTime.parse('$dateString $timeString'),
        this.measurements = [d1, d2, d3, d4, d5, d6, d7, d8, d9, 10];
}

// TODO: use typedef
// as in https://dart.dev/guides/language/language-tour#typedefs
// when support for a newer flutter engine is available in flutter-pi.
// This feature relies on dart 2.13 or higher.
class SensorDB {
  final List<SPS30SensorDataEntry> entryList;

  SensorDB(this.entryList);

  /* void addEntry(List<SPS30SensorDataEntry> input) {
    this.entryList.addAll(input);
  } */
}

Future<SensorDB> getAllEntries(String databasePath) async {
  print('opening db...');
  var db = await openDatabase(databasePath);
  print('IsOpen: ${db.isOpen}');
  final List<Map<String, dynamic>> maps = await db.query('sensor_output');
  var returnList = List.generate(maps.length, (i) {
    return SPS30SensorDataEntry.createFromDB(
      maps[i]['date'],
      maps[i]['time'],
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
  return SensorDB(returnList);
}

Future<SPS30SensorDataEntry> getEntriesFromDate(date) async {}

Future<SPS30SensorDataEntry> getEntriesDateRange(start, stop) async {}

import 'dart:io';
import 'package:flutter_iot_ui/data/mock_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_iot_ui/data/sps30/sps30_datamodel.dart';

void initDBLib() {
  if (Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  } else {
    print('not running on Linux, using mock DB');
    databaseFactory = databaseFactoryMock;
    //setMockDatabaseFactory(databaseFactoryMock);
  }
}

Future<SensorDB> getAllEntries(String databasePath) async {
  print('opening db...');
  var db = await openDatabase(databasePath, readOnly: true);
  print('IsOpen: ${db.isOpen}');
  final List<Map<String, dynamic>> maps = await db.query('sensor_output');
  await db.close();

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

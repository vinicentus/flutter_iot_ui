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
    print('not running on Linux, DB library not initialized');
  }
}

class SPS30SensorDataEntry {
  final DateTime timeStamp;
  final List<num> _measurements;

  /// Mass Concentration PM1.0 (µg/m³)
  get massConcentrationPM1_0 => this._measurements[0];

  ///Mass Concentration PM2.5 (µg/m³)
  get massConcentrationPM2_5 => this._measurements[1];

  ///Mass Concentration PM4.0 (µg/m³)
  get massConcentrationPM4_0 => this._measurements[2];

  ///Mass Concentration PM10 (µg/m³)
  get massConcentrationPM10 => this._measurements[3];

  ///Number Concentration PM0.5 (#/cm³)
  get numberConcentrationPM0_5 => this._measurements[4];

  ///Number Concentration PM1.0 (#/cm³)
  get numberConcentrationPM1_0 => this._measurements[5];

  ///Number Concentration PM2.5 (#/cm³)
  get numberConcentrationPM2_5 => this._measurements[6];

  ///Number Concentration PM4.0 (#/cm³)
  get numberConcentrationPM4_0 => this._measurements[7];

  ///Number Concentration PM10 (#/cm³)
  get numberConcentrationPM10 => this._measurements[8];

  ///Typical Particle Size (µm)
  get typicalParticleSize => this._measurements[9];

  SPS30SensorDataEntry(this.timeStamp, this._measurements);

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
        this._measurements = [d1, d2, d3, d4, d5, d6, d7, d8, d9, 10];
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

import 'dart:async';
import 'dart:math';
import 'package:flutter_iot_ui/data/database_manager.dart';
import 'package:flutter_iot_ui/data/svm30_datamodel.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';

// Note to self: Don't touch unless absolutely necessary!
// I'm by no means proud of the following code, but it works for now...

class MockDbManager extends DatabaseManager {
  var rnd = Random();

  List<Map<String, Object>> _data = [];

  List<Map<String, Object>> _freshData() {
    var prevDateTime = DateTime.parse((_data.isEmpty
        ? DateTime.now().toIso8601String()
        : _data.elementAt(_data.length - 1)['datetime'] as String));
    var nextDateTime = prevDateTime.add(Duration(minutes: 5));
    _data.add({
      'datetime': nextDateTime.toIso8601String().split('.').first,
      'd1': rnd.nextDouble() * 50,
      'd2': rnd.nextDouble() * 50,
      'd3': rnd.nextDouble() * 50,
      'd4': rnd.nextDouble() * 50,
      'd5': rnd.nextDouble() * 50,
      'd6': rnd.nextDouble() * 50,
      'd7': rnd.nextDouble() * 50,
      'd8': rnd.nextDouble() * 50,
      'd9': rnd.nextDouble() * 50,
      'd10': rnd.nextDouble() * 50,
    });
    return _data;
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) {
    return Future.value(_freshData()
        .map((entry) => SCD30SensorDataEntry.createFromDB(
              entry['datetime'] as String,
              entry['d1'] as double,
              entry['d2'] as double,
              entry['d3'] as double,
            ))
        .toList());
  }

  @override
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) {
    return Future.value(_freshData()
        .map((entry) => SPS30SensorDataEntry.createFromDB(
              entry['datetime'] as String,
              entry['d1'] as double,
              entry['d2'] as double,
              entry['d3'] as double,
              entry['d4'] as double,
              entry['d5'] as double,
              entry['d6'] as double,
              entry['d7'] as double,
              entry['d8'] as double,
              entry['d9'] as double,
              entry['d10'] as double,
            ))
        .toList());
  }

  @override
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) {
    return Future.value(_freshData()
        .map((entry) => SVM30SensorDataEntry.createFromDB(
              entry['datetime'] as String,
              entry['d1'] as double,
              entry['d2'] as double,
            ))
        .toList());
  }
}

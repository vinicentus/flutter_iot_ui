import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/data/constants.dart' show dbPath;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_iot_ui/visual/general_graph_page.dart';

class SCD30Page extends StatefulWidget {
  final String title = 'SCD30 Sensor Data';

  @override
  _SCD30PageState createState() => _SCD30PageState();
}

class _SCD30PageState extends State<SCD30Page> {
  Stream<List<SCD30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSCD30EntriesBetweenDateTimes(dbPath, yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSCD30EntriesBetweenDateTimes(dbPath, yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        seriesListStream: dbUpdates().map((event) => [
              charts.Series<SCD30SensorDataEntry, DateTime>(
                  id: 'Carbon Dioxide (ppm)',
                  domainFn: (SCD30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SCD30SensorDataEntry value, _) =>
                      value.carbonDioxide,
                  data: event),
              charts.Series<SCD30SensorDataEntry, DateTime>(
                  id: 'Temperature (°C)',
                  domainFn: (SCD30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SCD30SensorDataEntry value, _) =>
                      value.temperature,
                  data: event),
              charts.Series<SCD30SensorDataEntry, DateTime>(
                  id: 'Humidity (%RH)',
                  domainFn: (SCD30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SCD30SensorDataEntry value, _) => value.humidity,
                  data: event),
            ]));
  }
}

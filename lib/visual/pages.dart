import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/visual/general_graph_page.dart';
import 'package:fl_chart/fl_chart.dart';

class CarbonDioxidePage extends StatefulWidget {
  static const String route = '/CarbonDioxidePage';
  final String title = 'Carbon Dioxide (ppm)';

  @override
  _CarbonDioxidePageState createState() => _CarbonDioxidePageState();
}

class _CarbonDioxidePageState extends State<CarbonDioxidePage> {
  //TODO: don't have many separate dbUpdates functions for the same type of data
  Stream<List<SCD30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSCD30EntriesBetweenDateTimes(yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSCD30EntriesBetweenDateTimes(yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: CarbonDioxidePage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) {
          return [
            // TODO: id: 'Carbon Dioxide'
            LineChartBarData(
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.carbonDioxide))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries.first],
              dotData: FlDotData(show: false),
            ),
          ];
        }));
  }
}

class TemperaturePage extends StatefulWidget {
  static const String route = '/TemperaturePage';
  final String title = 'Temperature (°C)';

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  Stream<List<SCD30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSCD30EntriesBetweenDateTimes(yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSCD30EntriesBetweenDateTimes(yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: TemperaturePage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) {
          return [
            // id: 'Temperature',
            LineChartBarData(
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.temperature))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries.first],
              dotData: FlDotData(show: false),
            ),
          ];
        }));
  }
}

class HumidityPage extends StatefulWidget {
  static const String route = '/HumidityPage';
  final String title = 'Humidity (%RH)';

  @override
  _HumidityPageState createState() => _HumidityPageState();
}

class _HumidityPageState extends State<HumidityPage> {
  Stream<List<SCD30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSCD30EntriesBetweenDateTimes(yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSCD30EntriesBetweenDateTimes(yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: HumidityPage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) {
          return [
            // id: 'Humidity'
            LineChartBarData(
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.humidity))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries.first],
              dotData: FlDotData(show: false),
            ),
          ];
        }));
  }
}

class MassConcentrationPage extends StatefulWidget {
  static const String route = '/MassConcentrationPage';
  final String title = 'Mass Concentration (µg/m³)';

  @override
  _MassConcentrationPageState createState() => _MassConcentrationPageState();
}

class _MassConcentrationPageState extends State<MassConcentrationPage> {
  Stream<List<SPS30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSPS30EntriesBetweenDateTimes(yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSPS30EntriesBetweenDateTimes(yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: MassConcentrationPage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) {
          return [
            LineChartBarData(
              // id: '0.3-1.0μm:',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.massConcentrationPM1_0))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries.first],
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              // id: '1.0-2.5μm:',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.massConcentrationPM2_5Subtracted))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries[1]],
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              // id: '2.5-4.0μm:',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.massConcentrationPM4_0Subtracted))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries[2]],
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              // id: '4.0-10.0μm:',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.massConcentrationPM10Subtracted))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries[3]],
              dotData: FlDotData(show: false),
            ),
          ];
        }));
  }
}

class NumberConcentrationPage extends StatefulWidget {
  static const String route = '/NumberConcentrationPage';
  final String title = 'Number concentration (#/cm³)';

  @override
  _NumberConcentrationPageState createState() =>
      _NumberConcentrationPageState();
}

class _NumberConcentrationPageState extends State<NumberConcentrationPage> {
  Stream<List<SPS30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSPS30EntriesBetweenDateTimes(yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSPS30EntriesBetweenDateTimes(yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: NumberConcentrationPage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) {
          return [
            LineChartBarData(
              // id: '0.3-0.5μm:',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.numberConcentrationPM0_5))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries.first],
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              // id: '0.5-1.0μm:',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.numberConcentrationPM1_0Subtracted))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries[1]],
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              // id: '1.0-2.5μm:',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.numberConcentrationPM2_5Subtracted))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries[2]],
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              // id: '2.5-4.0μm:',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.numberConcentrationPM4_0Subtracted))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries[3]],
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              // id: '4.0-10.0μm: ',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.numberConcentrationPM10Subtracted))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries[4]],
              dotData: FlDotData(show: false),
            ),
          ];
        }));
  }
}

class TypicalParticleSizePage extends StatefulWidget {
  static const String route = '/TypicalParticleSizePage';
  final String title = 'Typical Particle Size (µm)';

  @override
  _TypicalParticleSizePageState createState() =>
      _TypicalParticleSizePageState();
}

class _TypicalParticleSizePageState extends State<TypicalParticleSizePage> {
  Stream<List<SPS30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSPS30EntriesBetweenDateTimes(yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSPS30EntriesBetweenDateTimes(yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: TypicalParticleSizePage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) {
          return [
            LineChartBarData(
              // id: 'Typical Particle Size',
              spots: event
                  .map((e) => FlSpot(
                      e.timeStamp.millisecondsSinceEpoch.toDouble(),
                      e.typicalParticleSize))
                  .toList(),
              isCurved: false,
              colors: [Colors.primaries.first],
              dotData: FlDotData(show: false),
            ),
          ];
        }));
  }
}

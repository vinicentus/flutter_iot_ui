import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/data/constants.dart' show dbPath;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_iot_ui/visual/general_graph_page.dart';

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
        route: CarbonDioxidePage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) => [
              charts.Series<SCD30SensorDataEntry, DateTime>(
                  id: 'Carbon Dioxide',
                  domainFn: (SCD30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SCD30SensorDataEntry value, _) =>
                      value.carbonDioxide,
                  data: event),
            ]));
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
        route: TemperaturePage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) => [
              charts.Series<SCD30SensorDataEntry, DateTime>(
                  id: 'Temperature',
                  domainFn: (SCD30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SCD30SensorDataEntry value, _) =>
                      value.temperature,
                  data: event),
            ]));
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
        route: HumidityPage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) => [
              charts.Series<SCD30SensorDataEntry, DateTime>(
                  id: 'Humidity',
                  domainFn: (SCD30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SCD30SensorDataEntry value, _) => value.humidity,
                  data: event),
            ]));
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
    var db = await getSPS30EntriesBetweenDateTimes(dbPath, yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSPS30EntriesBetweenDateTimes(dbPath, yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: MassConcentrationPage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) => [
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'PM1.0',
                  colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.massConcentrationPM1_0,
                  data: event),
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'PM2.5',
                  colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.massConcentrationPM2_5,
                  data: event),
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'PM4.0',
                  colorFn: (_, __) =>
                      charts.MaterialPalette.yellow.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.massConcentrationPM4_0,
                  data: event),
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'PM10',
                  colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.massConcentrationPM10,
                  data: event),
            ]));
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
    var db = await getSPS30EntriesBetweenDateTimes(dbPath, yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSPS30EntriesBetweenDateTimes(dbPath, yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: NumberConcentrationPage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) => [
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'PM0.5',
                  colorFn: (_, __) =>
                      charts.MaterialPalette.purple.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.numberConcentrationPM0_5,
                  data: event),
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'PM1.0',
                  colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.numberConcentrationPM1_0,
                  data: event),
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'PM2.5',
                  colorFn: (_, __) =>
                      charts.MaterialPalette.deepOrange.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.numberConcentrationPM2_5,
                  data: event),
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'PM4.0',
                  colorFn: (_, __) => charts.MaterialPalette.lime.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.numberConcentrationPM4_0,
                  data: event),
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'PM10',
                  colorFn: (_, __) =>
                      charts.MaterialPalette.indigo.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.numberConcentrationPM10,
                  data: event),
            ]));
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
    var db = await getSPS30EntriesBetweenDateTimes(dbPath, yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSPS30EntriesBetweenDateTimes(dbPath, yesterday, today));
      yield db;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: TypicalParticleSizePage.route,
        title: this.widget.title,
        seriesListStream: dbUpdates().map((event) => [
              charts.Series<SPS30SensorDataEntry, DateTime>(
                  id: 'Typical Particle Size',
                  colorFn: (_, __) => charts.MaterialPalette.pink.shadeDefault,
                  domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
                  measureFn: (SPS30SensorDataEntry value, _) =>
                      value.typicalParticleSize,
                  data: event),
            ]));
  }
}

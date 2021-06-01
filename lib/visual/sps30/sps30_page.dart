import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/sps30/sps30_datamodel.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/data/constants.dart' show dbPath;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_iot_ui/visual/checkbox_widget.dart';

class SPS30Page extends StatefulWidget {
  final String title = 'SPS30 Sensor Data';

  @override
  _SPS30PageState createState() => _SPS30PageState();
}

class _SPS30PageState extends State<SPS30Page> {
  bool _showMassConcentrationPM1_0 = true;
  bool _showMassConcentrationPM2_5 = true;
  bool _showMassConcentrationPM4_0 = true;
  bool _showMassConcentrationPM10 = true;
  bool _showNumberConcentrationPM0_5 = true;
  bool _showNumberConcentrationPM1_0 = true;
  bool _showNumberConcentrationPM2_5 = true;
  bool _showNumberConcentrationPM4_0 = true;
  bool _showNumberConcentrationPM10 = true;
  bool _showtypicalParticleSize = true;

  // TODO: move to separate data provider (maybe usin provider or bloc)
  List<SPS30SensorDataEntry> _dataList = [];

  bool _continue = true;

  Stream<List<SPS30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSPS30EntriesBetweenDateTimes(dbPath, yesterday, today);
    yield db;

    while (_continue) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSPS30EntriesBetweenDateTimes(dbPath, yesterday, today));
      yield db;
    }
  }

  @override
  void initState() {
    super.initState();
    dbUpdates().listen((data) {
      setState(() {
        _dataList = data;
      });
    });
  }

  @override
  void dispose() {
    // This stops the stream
    // could have laso used a StreamController
    _continue = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [AppbarTrailingInfo()],
      ),
      drawer: NavDrawer(),
      body: Center(
        child: this._dataList.isNotEmpty
            ? Column(
                children: [
                  Flexible(
                    child: charts.TimeSeriesChart(
                      [
                        if (_showMassConcentrationPM1_0)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Mass Concentration PM1.0 (µg/m³)',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.blue.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.massConcentrationPM1_0,
                              data: _dataList),
                        if (_showMassConcentrationPM2_5)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Mass Concentration PM2.5 (µg/m³)',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.red.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.massConcentrationPM2_5,
                              data: _dataList),
                        if (_showMassConcentrationPM4_0)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Mass Concentration PM4.0 (µg/m³)',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.yellow.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.massConcentrationPM4_0,
                              data: _dataList),
                        if (_showMassConcentrationPM10)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Mass Concentration PM10 (µg/m³)',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.green.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.massConcentrationPM10,
                              data: _dataList),
                        if (_showNumberConcentrationPM0_5)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Number Concentration PM0.5 (#/cm³)',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.purple.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.numberConcentrationPM0_5,
                              data: _dataList),
                        if (_showNumberConcentrationPM1_0)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Number Concentration PM1.0 (#/cm³)',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.cyan.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.numberConcentrationPM1_0,
                              data: _dataList),
                        if (_showNumberConcentrationPM2_5)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Number Concentration PM2.5 (#/cm³)',
                              colorFn: (_, __) => charts
                                  .MaterialPalette.deepOrange.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.numberConcentrationPM2_5,
                              data: _dataList),
                        if (_showNumberConcentrationPM4_0)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Number Concentration PM4.0 (#/cm³)',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.lime.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.numberConcentrationPM4_0,
                              data: _dataList),
                        if (_showNumberConcentrationPM10)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Number Concentration PM10 (#/cm³)',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.indigo.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.numberConcentrationPM10,
                              data: _dataList),
                        if (_showtypicalParticleSize)
                          charts.Series<SPS30SensorDataEntry, DateTime>(
                              id: 'Typical Particle Size (µm)',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.pink.shadeDefault,
                              domainFn: (SPS30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SPS30SensorDataEntry value, _) =>
                                  value.typicalParticleSize,
                              data: _dataList),
                      ],
                      animate: true,
                      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
                      // should create the same type of [DateTime] as the data provided. If none
                      // specified, the default creates local date time.
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                    ),
                  ),
                  Wrap(
                    children: [
                      CheckboxWidget(
                        text: 'Mass Concentration PM1.0 (µg/m³)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.blue.shadeDefault),
                        value: _showMassConcentrationPM1_0,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showMassConcentrationPM1_0 = value;
                          });
                        },
                      ),
                      CheckboxWidget(
                        text: 'Mass Concentration PM2.5 (µg/m³)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.red.shadeDefault),
                        value: _showMassConcentrationPM2_5,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showMassConcentrationPM2_5 = value;
                          });
                        },
                      ),
                      CheckboxWidget(
                        text: 'Mass Concentration PM4.0 (µg/m³)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.yellow.shadeDefault),
                        value: _showMassConcentrationPM4_0,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showMassConcentrationPM4_0 = value;
                          });
                        },
                      ),
                      CheckboxWidget(
                        text: 'Mass Concentration PM10 (µg/m³)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.green.shadeDefault),
                        value: _showMassConcentrationPM10,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showMassConcentrationPM10 = value;
                          });
                        },
                      ),
                      CheckboxWidget(
                        text: 'Number Concentration PM0.5 (#/cm³)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.purple.shadeDefault),
                        value: _showNumberConcentrationPM0_5,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showNumberConcentrationPM0_5 = value;
                          });
                        },
                      ),
                      CheckboxWidget(
                        text: 'Number Concentration PM1.0 (#/cm³)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.cyan.shadeDefault),
                        value: _showNumberConcentrationPM1_0,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showNumberConcentrationPM1_0 = value;
                          });
                        },
                      ),
                      CheckboxWidget(
                        text: 'Number Concentration PM2.5 (#/cm³)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.deepOrange.shadeDefault),
                        value: _showNumberConcentrationPM2_5,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showNumberConcentrationPM2_5 = value;
                          });
                        },
                      ),
                      CheckboxWidget(
                        text: 'Number Concentration PM4.0 (#/cm³)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.lime.shadeDefault),
                        value: _showNumberConcentrationPM4_0,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showNumberConcentrationPM4_0 = value;
                          });
                        },
                      ),
                      CheckboxWidget(
                        text: 'Number Concentration PM10 (#/cm³)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.indigo.shadeDefault),
                        value: _showNumberConcentrationPM10,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showNumberConcentrationPM10 = value;
                          });
                        },
                      ),
                      CheckboxWidget(
                        text: 'Typical Particle Size (µm)',
                        color: charts.ColorUtil.toDartColor(
                            charts.MaterialPalette.pink.shadeDefault),
                        value: _showtypicalParticleSize,
                        callbackFunction: (bool value) {
                          setState(() {
                            _showtypicalParticleSize = value;
                          });
                        },
                      ),
                    ],
                  )
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}

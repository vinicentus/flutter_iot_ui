import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/scd30/scd30_datamodel.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/data/constants.dart' show dbPath;
import 'package:charts_flutter/flutter.dart' as charts;

class SCD30Page extends StatefulWidget {
  final String title = 'SCD30 Sensor Data';

  @override
  _SCD30PageState createState() => _SCD30PageState();
}

class _SCD30PageState extends State<SCD30Page> {
  bool _showCarbonDioxide = true;
  bool _showTemperature = true;
  bool _showHumidity = true;

  // TODO: move to separate data provider (maybe usin provider or bloc)
  List<SCD30SensorDataEntry> _dataList = [];

  bool _continue = true;

  // TODO: don't fetch the whole database every time...
  Stream<List<SCD30SensorDataEntry>> dbUpdates() async* {
    // Init
    var db = await getAllSCD30Entries(dbPath);
    yield db;

    while (_continue) {
      db = await Future.delayed(
          Duration(seconds: 5), () => getAllSCD30Entries(dbPath));
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
      ),
      drawer: NavDrawer(),
      body: Center(
        child: this._dataList.isNotEmpty
            ? Column(
                children: [
                  Flexible(
                    child: charts.TimeSeriesChart(
                      [
                        if (_showCarbonDioxide)
                          charts.Series<SCD30SensorDataEntry, DateTime>(
                              id: 'Carbon Dioxide',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.blue.shadeDefault,
                              domainFn: (SCD30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SCD30SensorDataEntry value, _) =>
                                  value.carbonDioxide,
                              data: _dataList),
                        if (_showTemperature)
                          charts.Series<SCD30SensorDataEntry, DateTime>(
                              id: 'Temperature',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.green.shadeDefault,
                              domainFn: (SCD30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SCD30SensorDataEntry value, _) =>
                                  value.temperature,
                              data: _dataList),
                        if (_showHumidity)
                          charts.Series<SCD30SensorDataEntry, DateTime>(
                              id: 'Humidity',
                              colorFn: (_, __) =>
                                  charts.MaterialPalette.purple.shadeDefault,
                              domainFn: (SCD30SensorDataEntry value, _) =>
                                  value.timeStamp,
                              measureFn: (SCD30SensorDataEntry value, _) =>
                                  value.humidity,
                              data: _dataList),
                      ],
                      animate: true,
                      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
                      // should create the same type of [DateTime] as the data provided. If none
                      // specified, the default creates local date time.
                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(children: [
                        Checkbox(
                          activeColor: Colors.blue,
                          value: _showCarbonDioxide,
                          onChanged: (bool value) {
                            setState(() {
                              _showCarbonDioxide = value;
                            });
                          },
                        ),
                        Text('Carbon Dioxide'),
                      ]),
                      Row(children: [
                        Checkbox(
                          activeColor: Colors.green,
                          value: _showTemperature,
                          onChanged: (bool value) {
                            setState(() {
                              _showTemperature = value;
                            });
                          },
                        ),
                        Text('Temperature'),
                      ]),
                      Row(children: [
                        Checkbox(
                          activeColor: Colors.purple,
                          value: _showHumidity,
                          onChanged: (bool value) {
                            setState(() {
                              _showHumidity = value;
                            });
                          },
                        ),
                        Text('Humidity'),
                      ]),
                    ],
                  )
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}

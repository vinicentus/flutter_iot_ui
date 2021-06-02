import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/scd30/scd30_datamodel.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/data/constants.dart' show dbPath;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_iot_ui/visual/checkbox_widget.dart';

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

  Stream<List<SCD30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSCD30EntriesBetweenDateTimes(dbPath, yesterday, today);
    yield db;

    while (_continue) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSCD30EntriesBetweenDateTimes(dbPath, yesterday, today));
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
            ? Column(children: [
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
                                charts.MaterialPalette.red.shadeDefault,
                            domainFn: (SCD30SensorDataEntry value, _) =>
                                value.timeStamp,
                            measureFn: (SCD30SensorDataEntry value, _) =>
                                value.temperature,
                            data: _dataList),
                      if (_showHumidity)
                        charts.Series<SCD30SensorDataEntry, DateTime>(
                            id: 'Humidity',
                            colorFn: (_, __) =>
                                charts.MaterialPalette.yellow.shadeDefault,
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
                Wrap(children: [
                  CheckboxWidget(
                    text: 'Canrbon Dioxide (ppm)',
                    color: charts.ColorUtil.toDartColor(
                        charts.MaterialPalette.blue.shadeDefault),
                    value: _showCarbonDioxide,
                    callbackFunction: (bool value) {
                      setState(() {
                        _showCarbonDioxide = value;
                      });
                    },
                  ),
                  CheckboxWidget(
                    text: 'Temperature (°C)',
                    color: charts.ColorUtil.toDartColor(
                        charts.MaterialPalette.red.shadeDefault),
                    value: _showTemperature,
                    callbackFunction: (bool value) {
                      setState(() {
                        _showTemperature = value;
                      });
                    },
                  ),
                  CheckboxWidget(
                    text: 'Humidity (%RH)',
                    color: charts.ColorUtil.toDartColor(
                        charts.MaterialPalette.yellow.shadeDefault),
                    value: _showHumidity,
                    callbackFunction: (bool value) {
                      setState(() {
                        _showHumidity = value;
                      });
                    },
                  ),
                ]),
              ])
            : CircularProgressIndicator(),
      ),
    );
  }
}

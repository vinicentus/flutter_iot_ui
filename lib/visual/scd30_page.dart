import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
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
      body: StreamBuilder(
        stream: dbUpdates(),
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
            return charts.TimeSeriesChart(
              [
                charts.Series<SCD30SensorDataEntry, DateTime>(
                    id: 'Carbon Dioxide (ppm)',
                    colorFn: (_, __) =>
                        charts.MaterialPalette.blue.shadeDefault,
                    domainFn: (SCD30SensorDataEntry value, _) =>
                        value.timeStamp,
                    measureFn: (SCD30SensorDataEntry value, _) =>
                        value.carbonDioxide,
                    data: snapshot.data),
                charts.Series<SCD30SensorDataEntry, DateTime>(
                    id: 'Temperature (°C)',
                    colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
                    domainFn: (SCD30SensorDataEntry value, _) =>
                        value.timeStamp,
                    measureFn: (SCD30SensorDataEntry value, _) =>
                        value.temperature,
                    data: snapshot.data),
                charts.Series<SCD30SensorDataEntry, DateTime>(
                    id: 'Humidity (%RH)',
                    colorFn: (_, __) =>
                        charts.MaterialPalette.yellow.shadeDefault,
                    domainFn: (SCD30SensorDataEntry value, _) =>
                        value.timeStamp,
                    measureFn: (SCD30SensorDataEntry value, _) =>
                        value.humidity,
                    data: snapshot.data),
              ],
              animate: true,
              // Optionally pass in a [DateTimeFactory] used by the chart. The factory
              // should create the same type of [DateTime] as the data provided. If none
              // specified, the default creates local date time.
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              behaviors: [
                charts.SeriesLegend(
                  // Positions for "start" and "end" will be left and right respectively
                  // for widgets with a build context that has directionality ltr.
                  // For rtl, "start" and "end" will be right and left respectively.
                  // Since this example has directionality of ltr, the legend is
                  // positioned on the right side of the chart.
                  position: charts.BehaviorPosition.bottom,
                  // By default, if the position of the chart is on the left or right of
                  // the chart, [horizontalFirst] is set to false. This means that the
                  // legend entries will grow as new rows first instead of a new column.
                  horizontalFirst: true,
                  showMeasures: true,
                  // TODO: change to last
                  // Using last doesn't work when we hide one of the lines
                  legendDefaultMeasure: charts.LegendDefaultMeasure.none,
                  measureFormatter: (num value) {
                    // Despite some initial confusion, it turns out that this actually rounds the numbers
                    return value == null || value.isNaN
                        ? '-'
                        : value.toStringAsFixed(1);
                  },
                ),
                // charts.InitialSelection(
                //   selectedDataConfig: [
                //     charts.SeriesDatumConfig<DateTime>(
                //         'Carbon Dioxide (ppm)',
                //         _dataList?.last?.timeStamp),
                //     charts.SeriesDatumConfig<DateTime>(
                //         'Temperature (°C)', _dataList?.last?.timeStamp),
                //     charts.SeriesDatumConfig<DateTime>(
                //         'Humidity (%RH)', _dataList?.last?.timeStamp)
                //   ],
                // ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error.'));
          } else {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                Text('No data (yet).')
              ]),
            );
          }
        },
      ),
    );
  }
}

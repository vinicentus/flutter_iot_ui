import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/svm30_datamodel.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/data/constants.dart' show dbPath;
import 'package:charts_flutter/flutter.dart' as charts;

class SVM30Page extends StatefulWidget {
  static const String route = '/SVM30Page';
  final String title = 'SVM30 Sensor Data';

  @override
  _SVM30PageState createState() => _SVM30PageState();
}

class _SVM30PageState extends State<SVM30Page> {
  Stream<List<SVM30SensorDataEntry>> dbUpdates() async* {
    // Init
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var db = await getSVM30EntriesBetweenDateTimes(dbPath, yesterday, today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(Duration(days: 1));
      db = await Future.delayed(Duration(seconds: 5),
          () => getSVM30EntriesBetweenDateTimes(dbPath, yesterday, today));
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
      drawer: NavDrawer(SVM30Page.route),
      body: StreamBuilder(
        stream: dbUpdates(),
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
            return charts.TimeSeriesChart(
              [
                charts.Series<SVM30SensorDataEntry, DateTime>(
                    id: 'Carbon Dioxide equivalent (ppm)',
                    colorFn: (_, __) =>
                        charts.MaterialPalette.blue.shadeDefault,
                    domainFn: (SVM30SensorDataEntry value, _) =>
                        value.timeStamp,
                    measureFn: (SVM30SensorDataEntry value, _) =>
                        value.carbonDioxide,
                    data: snapshot.data),
                charts.Series<SVM30SensorDataEntry, DateTime>(
                    id: 'Total Volatile Organic Compounds (ppb)',
                    colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
                    domainFn: (SVM30SensorDataEntry value, _) =>
                        value.timeStamp,
                    measureFn: (SVM30SensorDataEntry value, _) =>
                        value.totalVolatileOrganicCompounds,
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
                  // Using last doesn't work when we hide one of the lines (in charts_flutter 0.10.0)
                  legendDefaultMeasure: charts.LegendDefaultMeasure.lastValue,
                  measureFormatter: (num value) {
                    // Despite some initial confusion, it turns out that this actually rounds the numbers
                    return value == null || value.isNaN
                        ? '-'
                        : value.toStringAsFixed(1);
                  },
                ),
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

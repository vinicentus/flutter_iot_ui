import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/settings_constants.dart';
import 'package:flutter_iot_ui/data/svm30_datamodel.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:flutter_iot_ui/visual/pages.dart';

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
    var yesterday = today.subtract(defaultTimeWindow);
    var db =
        await globalDBManager.getSVM30Entries(start: yesterday, stop: today);
    yield db;

    while (this.mounted) {
      today = DateTime.now();
      yesterday = today.subtract(defaultTimeWindow);
      db = await Future.delayed(
          Duration(seconds: numberOfSecondsBetweenGraphRefresh),
          () => globalDBManager.getSVM30Entries(start: yesterday, stop: today));
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
        stream: dbUpdates().map((List<SVM30SensorDataEntry> event) {
          // The chart library throws if it receives a LineChartBarData without any FlSpots.
          // We need to return an empty list without any "empty" LineChartBarData objects instead.
          return (event.isNotEmpty)
              ? [
                  LineChartBarData(
                    //id: 'Carbon Dioxide equivalent (ppm)',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              e.carbonDioxide))
                          .toList(),
                      useMovingAverage,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries.first],
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    //id: 'Total Volatile Organic Compounds (ppb)',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              e.totalVolatileOrganicCompounds))
                          .toList(),
                      useMovingAverage,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries[5]],
                    dotData: FlDotData(show: false),
                  ),
                ]
              : <LineChartBarData>[];
        }),
        builder: (context, AsyncSnapshot<List<LineChartBarData>> snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> spotList) => spotList
                          .map((e) => LineTooltipItem('${e.y} x',
                              Theme.of(context).textTheme.bodyText1!))
                          .toList(),
                    )),
                gridData: FlGridData(
                  show: true,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    margin: 10,
                    // An hour in milliseconds
                    interval: 3.6e6,
                    getTitles: (value) =>
                        DateTime.fromMillisecondsSinceEpoch(value.toInt())
                            .hour
                            .toString(),
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    // We show all the units of the different lines here.
                    getTitles: (value) {
                      var rounded = value.toStringAsFixed(2);
                      return 'CO2eq: $rounded ppm / VOC: $rounded ppb';
                    },
                    interval: 50,
                    margin: 10,
                    reservedSize: 50,
                  ),
                  topTitles: SideTitles(showTitles: false),
                  rightTitles: SideTitles(showTitles: false),
                ),
                borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(),
                      left: BorderSide(),
                    )),
                lineBarsData: snapshot.data,
              ),
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

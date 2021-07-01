import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GeneralGraphPage extends StatefulWidget {
  final String title = 'SCD30 Sensor Data';
  final Stream<List<charts.Series<dynamic, DateTime>>> seriesListStream;

  GeneralGraphPage({Key key, @required this.seriesListStream})
      : super(key: key);

  @override
  _GeneralGraphPageState createState() => _GeneralGraphPageState();
}

class _GeneralGraphPageState extends State<GeneralGraphPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [AppbarTrailingInfo()],
      ),
      drawer: NavDrawer(),
      body: StreamBuilder(
        stream: widget.seriesListStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
            return charts.TimeSeriesChart(
              snapshot.data,
              animate: true,
              behaviors: [
                charts.SeriesLegend(
                  position: charts.BehaviorPosition.bottom,
                  horizontalFirst: true,
                  desiredMaxColumns: 2,
                  showMeasures: true,
                  // Using last doesn't work when we hide one of the lines
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
                Text('No data to show (yet).')
              ]),
            );
          }
        },
      ),
    );
  }
}

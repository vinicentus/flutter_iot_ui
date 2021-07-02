import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GeneralGraphPage extends StatelessWidget {
  final String title;
  final Stream<List<charts.Series<dynamic, DateTime>>> seriesListStream;
  final String route;

  GeneralGraphPage({
    Key key,
    @required this.title,
    @required this.seriesListStream,
    @required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
        actions: [AppbarTrailingInfo()],
      ),
      drawer: NavDrawer(this.route),
      body: StreamBuilder(
        stream: this.seriesListStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
            return charts.TimeSeriesChart(
              snapshot.data,
              animate: true,
              behaviors: [
                charts.SeriesLegend(
                  position: charts.BehaviorPosition.bottom,
                  horizontalFirst: true,
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

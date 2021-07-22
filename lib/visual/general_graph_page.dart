import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:fl_chart/fl_chart.dart';

class GeneralGraphPage extends StatelessWidget {
  final String title;
  final Stream<List<LineChartBarData>> seriesListStream;
  final String route;

  // TODO. add more params for unit etc
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
            return LineChart(data(snapshot.data, context));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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

  LineChartData data(
      List<LineChartBarData> seriesListStream, BuildContext context) {
    return LineChartData(
      lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> spotList) => spotList
                .map((e) => LineTooltipItem(
                    '${e.y} x', Theme.of(context).textTheme.bodyText1))
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
          // TODO:
          getTitles: (value) =>
              DateTime.fromMillisecondsSinceEpoch(value.toInt())
                  .hour
                  .toString(),
        ),
        leftTitles: SideTitles(
          showTitles: true,
          // TODO:
          // The x here represents a placeholder for a unit
          getTitles: (value) => '${value.toStringAsFixed(2)} x',
          // interval: 1,
          margin: 10,
          reservedSize: 50,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(),
            left: BorderSide(),
          )),
      // TODO:
      // minX: 0,
      // maxX: 14,
      // maxY: 6,
      // minY: 0,
      lineBarsData: seriesListStream,
    );
  }
}

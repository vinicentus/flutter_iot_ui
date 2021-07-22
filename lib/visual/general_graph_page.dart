import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:fl_chart/fl_chart.dart';

class GeneralGraphPage extends StatelessWidget {
  final String title;
  final Stream<List<LineChartBarData>> seriesListStream;
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
            return LineChart(sampleData2(snapshot.data));
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

  LineChartData sampleData2(List<LineChartBarData> seriesListStream) {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
      ),
      gridData: FlGridData(
        show: true,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          margin: 10,
          // TODO:
          getTitles: (value) {
            return DateTime.fromMillisecondsSinceEpoch(value.toInt())
                .toIso8601String();
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          // TODO:
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1m';
              case 2:
                return '2m';
              case 3:
                return '3m';
              case 4:
                return '5m';
              case 5:
                return '6m';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
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

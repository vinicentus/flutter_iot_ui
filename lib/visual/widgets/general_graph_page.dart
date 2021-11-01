import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/visual/widgets/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
import 'package:fl_chart/fl_chart.dart';

class GeneralGraphPage extends StatelessWidget {
  final String title;
  final Stream<List<LineChartBarData>> seriesListStream;
  final String route;
  final String unit;

  // TODO. add more params for unit etc
  GeneralGraphPage({
    Key? key,
    required this.title,
    required this.seriesListStream,
    required this.route,
    required this.unit,
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
        builder: (context, AsyncSnapshot<List<LineChartBarData>> snapshot) {
          // We already check if it has data (a non-null value).
          // That means we can use the !. operator throughout safely,
          // since we know (unlike the dart compiler) that the value won't ever be null.
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return LineChart(data(snapshot.data!, context));
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
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            showOnTopOfTheChartBoxArea: true,
            getTooltipItems: (List<LineBarSpot> spotList) => spotList
                .map((e) => LineTooltipItem(
                    '${e.y.toStringAsFixed(2)} ${this.unit}',
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
          // TODO: show decimal values if the value range is small enough
          getTitles: (value) => '${value.toStringAsFixed(0)} ${this.unit}',
          // interval: 1,
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
      // TODO:
      // minX: 0,
      // maxX: 14,
      // maxY: 6,
      // minY: 0,
      lineBarsData: seriesListStream,
    );
  }
}
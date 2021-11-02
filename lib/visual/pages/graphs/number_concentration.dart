import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/util/db_updates_stream.dart';
import 'package:flutter_iot_ui/core/util/moving_average.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/visual/widgets/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/widgets/checkbox_widget.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
import 'package:provider/provider.dart';

// This has to be a StatefulWidget since we have to be able to tick the checkboxes
class NumberConcentrationPage extends StatefulWidget {
  static const String route = '/NumberConcentrationPage';
  final String title = 'Number concentration (#/cm³)';
  final String unit = '#/cm³';

  @override
  _NumberConcentrationPageState createState() =>
      _NumberConcentrationPageState();
}

class _NumberConcentrationPageState extends State<NumberConcentrationPage> {
  List<bool> _checkboxesToShow = List.filled(5, true);

  @override
  Widget build(BuildContext context) {
    var model = context.read<GraphSettingsModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.title),
        actions: [AppbarTrailingInfo()],
      ),
      drawer: NavDrawer(NumberConcentrationPage.route),
      body: StreamBuilder(
        stream: dbUpdatesOfType<SPS30SensorDataEntry>(
                refreshDuration: model.graphRefreshTime,
                graphTimeWindow: model.graphTimeWindow)
            .map((event) {
          return (event.isNotEmpty)
              ? [
                  LineChartBarData(
                    // id: '0.3-0.5μm:',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              // No need to subtract values here
                              e.numberConcentrationPM0_5))
                          .toList(),
                      model.useMovingAverage,
                      model.movingAverageSamples,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries.first],
                    dotData: FlDotData(show: false),
                    show: _checkboxesToShow[0],
                  ),
                  LineChartBarData(
                    // id: '0.5-1.0μm:',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              // Check if we should use subtracted values
                              model.subtractParticleSizes
                                  ? e.numberConcentrationPM1_0Subtracted
                                  : e.numberConcentrationPM1_0))
                          .toList(),
                      model.useMovingAverage,
                      model.movingAverageSamples,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries[1]],
                    dotData: FlDotData(show: false),
                    show: _checkboxesToShow[1],
                  ),
                  LineChartBarData(
                    // id: '1.0-2.5μm:',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              // Check if we should use subtracted values
                              model.subtractParticleSizes
                                  ? e.numberConcentrationPM2_5Subtracted
                                  : e.numberConcentrationPM2_5))
                          .toList(),
                      model.useMovingAverage,
                      model.movingAverageSamples,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries[2]],
                    dotData: FlDotData(show: false),
                    show: _checkboxesToShow[2],
                  ),
                  LineChartBarData(
                    // id: '2.5-4.0μm:',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              // Check if we should use subtracted values
                              model.subtractParticleSizes
                                  ? e.numberConcentrationPM4_0Subtracted
                                  : e.numberConcentrationPM4_0))
                          .toList(),
                      model.useMovingAverage,
                      model.movingAverageSamples,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries[3]],
                    dotData: FlDotData(show: false),
                    show: _checkboxesToShow[3],
                  ),
                  LineChartBarData(
                    // id: '4.0-10.0μm: ',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              // Check if we should use subtracted values
                              model.subtractParticleSizes
                                  ? e.numberConcentrationPM10Subtracted
                                  : e.numberConcentrationPM10))
                          .toList(),
                      model.useMovingAverage,
                      model.movingAverageSamples,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries[4]],
                    dotData: FlDotData(show: false),
                    show: _checkboxesToShow[4],
                  ),
                ]
              : <LineChartBarData>[];
        }),
        builder: (context, AsyncSnapshot<List<LineChartBarData>> snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              children: [
                Expanded(
                  child: LineChart(data(snapshot.data!, context)),
                ),
                Wrap(children: [
                  CheckboxWidget(
                    text: '0.3-0.5μm',
                    color: Colors.primaries.first,
                    value: _checkboxesToShow[0],
                    callbackFunction: (bool value) {
                      setState(() {
                        _checkboxesToShow[0] = value;
                      });
                    },
                  ),
                  CheckboxWidget(
                    text: '0.5-1.0μm',
                    color: Colors.primaries[1],
                    value: _checkboxesToShow[1],
                    callbackFunction: (bool value) {
                      setState(() {
                        _checkboxesToShow[1] = value;
                      });
                    },
                  ),
                  CheckboxWidget(
                    text: '1.0-2.5μm',
                    color: Colors.primaries[2],
                    value: _checkboxesToShow[2],
                    callbackFunction: (bool value) {
                      setState(() {
                        _checkboxesToShow[2] = value;
                      });
                    },
                  ),
                  CheckboxWidget(
                    text: '2.5-4.0μm',
                    color: Colors.primaries[3],
                    value: _checkboxesToShow[3],
                    callbackFunction: (bool value) {
                      setState(() {
                        _checkboxesToShow[3] = value;
                      });
                    },
                  ),
                  CheckboxWidget(
                    text: '4.0-10.0μm',
                    color: Colors.primaries[3],
                    value: _checkboxesToShow[3],
                    callbackFunction: (bool value) {
                      setState(() {
                        _checkboxesToShow[3] = value;
                      });
                    },
                  ),
                ]),
              ],
            );
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
                    '${e.y.toStringAsFixed(2)} ${this.widget.unit}',
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
          getTitles: (value) =>
              '${value.toStringAsFixed(0)} ${this.widget.unit}',
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
      lineBarsData: (seriesListStream.isNotEmpty) ? seriesListStream : [],
    );
  }
}

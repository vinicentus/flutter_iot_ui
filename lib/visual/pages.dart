import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:flutter_iot_ui/data/settings_constants.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/checkbox_widget.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:flutter_iot_ui/visual/general_graph_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moving_average/moving_average.dart';

Stream<List<SCD30SensorDataEntry>> dbUpdatesSCD30() async* {
  // Init
  var today = DateTime.now();
  var yesterday = today.subtract(Duration(days: 1));
  // Just creating an instance of this singleton class will initialize it and the database.
  var db = await globalDBManager.getSCD30Entries(start: yesterday, stop: today);
  yield db;

  // This stream will be automatically cancelled by dart when no longer needed.
  // Furhtermore this loop will automatically stop running when the stream is canceled.
  while (true) {
    today = DateTime.now();
    yesterday = today.subtract(Duration(days: 1));
    db = await Future.delayed(
        Duration(seconds: numberOfSecondsBetweenGraphRefresh),
        () => globalDBManager.getSCD30Entries(start: yesterday, stop: today));
    yield db;
  }
}

Stream<List<SPS30SensorDataEntry>> dbUpdatesSPS30() async* {
  // Init
  var today = DateTime.now();
  var yesterday = today.subtract(Duration(days: 1));
  var db = await globalDBManager.getSPS30Entries(start: yesterday, stop: today);
  yield db;

  // This stream will be automatically cancelled by dart when no longer needed.
  // Furhtermore this loop will automatically stop running when the stream is canceled.
  while (true) {
    today = DateTime.now();
    yesterday = today.subtract(Duration(days: 1));
    db = await Future.delayed(
        Duration(seconds: numberOfSecondsBetweenGraphRefresh),
        () => globalDBManager.getSPS30Entries(start: yesterday, stop: today));
    yield db;
  }
}

List<FlSpot> transformIntoMovingAverage(
    List<FlSpot> flspotList, bool transform) {
  // Don't do anything with the data unless instructed to
  if (!transform) {
    return flspotList;
  }

  var simpleMovingAverage = MovingAverage<FlSpot>(
    // The window size is the number of samples per average sample returned
    // (not specified in units of time).
    // We currently get samples roughly every minute, so a value of 5
    // would mean that the averages are calculated over 5 minute periods.
    windowSize: numberOfSamplesPerMovingAverageWindow,
    getValue: (FlSpot spot) => spot.y,
    add: (List<FlSpot> data, num value) {
      var middleTimestamp = data[data.length ~/ 2].x;
      // We know the y coordinate will be a double, since we only return doubles in getValue
      return FlSpot(middleTimestamp, (value as double));
    },
  );

  return simpleMovingAverage(flspotList);
}

class CarbonDioxidePage extends StatelessWidget {
  static const String route = '/CarbonDioxidePage';
  final String title = 'Carbon Dioxide (ppm)';

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: CarbonDioxidePage.route,
        title: this.title,
        unit: 'ppm',
        seriesListStream: dbUpdatesSCD30().map((event) {
          return (event.isNotEmpty)
              ? [
                  // TODO: id: 'Carbon Dioxide'
                  LineChartBarData(
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
                ]
              : <LineChartBarData>[];
        }));
  }
}

class TemperaturePage extends StatelessWidget {
  static const String route = '/TemperaturePage';
  final String title = 'Temperature (°C)';

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: TemperaturePage.route,
        title: this.title,
        unit: '°C',
        seriesListStream: dbUpdatesSCD30().map((event) {
          return (event.isNotEmpty)
              ? [
                  // id: 'Temperature',
                  LineChartBarData(
                    spots: transformIntoMovingAverage(
                        event
                            .map((e) => FlSpot(
                                e.timeStamp.millisecondsSinceEpoch.toDouble(),
                                e.temperature))
                            .toList(),
                        useMovingAverage),
                    isCurved: false,
                    colors: [Colors.primaries.first],
                    dotData: FlDotData(show: false),
                  ),
                ]
              : <LineChartBarData>[];
        }));
  }
}

class HumidityPage extends StatelessWidget {
  static const String route = '/HumidityPage';
  final String title = 'Humidity (%RH)';

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: HumidityPage.route,
        title: this.title,
        unit: '%RH',
        seriesListStream: dbUpdatesSCD30().map((event) {
          return (event.isNotEmpty)
              ? [
                  // id: 'Humidity'
                  LineChartBarData(
                    spots: transformIntoMovingAverage(
                        event
                            .map((e) => FlSpot(
                                e.timeStamp.millisecondsSinceEpoch.toDouble(),
                                e.humidity))
                            .toList(),
                        useMovingAverage),
                    isCurved: false,
                    colors: [Colors.primaries.first],
                    dotData: FlDotData(show: false),
                  ),
                ]
              : <LineChartBarData>[];
        }));
  }
}

// This has to be a StatefulWidget since we need to be able to tick the checkboxes
class MassConcentrationPage extends StatefulWidget {
  final String title = 'Mass Concentration (µg/m³)';
  static const String route = '/MassConcentrationPage';
  final String unit = 'µg/m³';

  @override
  _MassConcentrationPageState createState() => _MassConcentrationPageState();
}

class _MassConcentrationPageState extends State<MassConcentrationPage> {
  List<bool> _checkboxesToShow = List.filled(4, true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.title),
        actions: [AppbarTrailingInfo()],
      ),
      drawer: NavDrawer(MassConcentrationPage.route),
      body: StreamBuilder(
        stream: dbUpdatesSPS30().map((event) {
          return (event.isNotEmpty)
              ? [
                  LineChartBarData(
                    // id: '0.3-1.0μm:',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              // No need to subtract values here
                              e.massConcentrationPM1_0))
                          .toList(),
                      useMovingAverage,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries.first],
                    dotData: FlDotData(show: false),
                    show: _checkboxesToShow[0],
                  ),
                  LineChartBarData(
                    // id: '1.0-2.5μm:',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              // Check if we should use subtracted values
                              subtractParticleSizes
                                  ? e.massConcentrationPM2_5Subtracted
                                  : e.massConcentrationPM2_5))
                          .toList(),
                      useMovingAverage,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries[1]],
                    dotData: FlDotData(show: false),
                    show: _checkboxesToShow[1],
                  ),
                  LineChartBarData(
                    // id: '2.5-4.0μm:',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              // Check if we should use subtracted values
                              subtractParticleSizes
                                  ? e.massConcentrationPM4_0Subtracted
                                  : e.massConcentrationPM4_0))
                          .toList(),
                      useMovingAverage,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries[2]],
                    dotData: FlDotData(show: false),
                    show: _checkboxesToShow[2],
                  ),
                  LineChartBarData(
                    // id: '4.0-10.0μm:',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              // Check if we should use subtracted values
                              subtractParticleSizes
                                  ? e.massConcentrationPM10Subtracted
                                  : e.massConcentrationPM10))
                          .toList(),
                      useMovingAverage,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries[3]],
                    dotData: FlDotData(show: false),
                    show: _checkboxesToShow[3],
                  ),
                ]
              : <LineChartBarData>[];
        }),
        builder: (context, AsyncSnapshot<List<LineChartBarData>> snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              children: [
                Expanded(
                  flex: 9,
                  child: LineChart(data(snapshot.data!, context)),
                ),
                Flexible(
                  flex: 1,
                  child: Wrap(children: [
                    CheckboxWidget(
                      text: '0.3-1.0µm',
                      color: Colors.primaries.first,
                      value: _checkboxesToShow[0],
                      callbackFunction: (bool value) {
                        setState(() {
                          _checkboxesToShow[0] = value;
                        });
                      },
                    ),
                    CheckboxWidget(
                      text: '1.0-2.5µm',
                      color: Colors.primaries[1],
                      value: _checkboxesToShow[1],
                      callbackFunction: (bool value) {
                        setState(() {
                          _checkboxesToShow[1] = value;
                        });
                      },
                    ),
                    CheckboxWidget(
                      text: '2.5-4.0µm',
                      color: Colors.primaries[2],
                      value: _checkboxesToShow[2],
                      callbackFunction: (bool value) {
                        setState(() {
                          _checkboxesToShow[2] = value;
                        });
                      },
                    ),
                    CheckboxWidget(
                      text: '4.0-10.0µm',
                      color: Colors.primaries[3],
                      value: _checkboxesToShow[3],
                      callbackFunction: (bool value) {
                        setState(() {
                          _checkboxesToShow[3] = value;
                        });
                      },
                    ),
                  ]),
                ),
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
          getTitles: (value) =>
              '${value.toStringAsFixed(0)} ${this.widget.unit}',
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
      lineBarsData: (seriesListStream.isNotEmpty) ? seriesListStream : [],
    );
  }
}

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
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.title),
        actions: [AppbarTrailingInfo()],
      ),
      drawer: NavDrawer(NumberConcentrationPage.route),
      body: StreamBuilder(
        stream: dbUpdatesSPS30().map((event) {
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
                      useMovingAverage,
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
                              subtractParticleSizes
                                  ? e.numberConcentrationPM1_0Subtracted
                                  : e.numberConcentrationPM1_0))
                          .toList(),
                      useMovingAverage,
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
                              subtractParticleSizes
                                  ? e.numberConcentrationPM2_5Subtracted
                                  : e.numberConcentrationPM2_5))
                          .toList(),
                      useMovingAverage,
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
                              subtractParticleSizes
                                  ? e.numberConcentrationPM4_0Subtracted
                                  : e.numberConcentrationPM4_0))
                          .toList(),
                      useMovingAverage,
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
                              subtractParticleSizes
                                  ? e.numberConcentrationPM10Subtracted
                                  : e.numberConcentrationPM10))
                          .toList(),
                      useMovingAverage,
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
                  flex: 9,
                  child: LineChart(data(snapshot.data!, context)),
                ),
                Flexible(
                  flex: 1,
                  child: Wrap(children: [
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
                ),
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
          getTitles: (value) =>
              '${value.toStringAsFixed(0)} ${this.widget.unit}',
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
      lineBarsData: (seriesListStream.isNotEmpty) ? seriesListStream : [],
    );
  }
}

class TypicalParticleSizePage extends StatelessWidget {
  static const String route = '/TypicalParticleSizePage';
  final String title = 'Typical Particle Size (µm)';

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage(
        route: TypicalParticleSizePage.route,
        title: this.title,
        unit: 'µm',
        seriesListStream: dbUpdatesSPS30().map((event) {
          return (event.isNotEmpty)
              ? [
                  LineChartBarData(
                    // id: 'Typical Particle Size',
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              e.typicalParticleSize))
                          .toList(),
                      useMovingAverage,
                    ),
                    isCurved: false,
                    colors: [Colors.primaries.first],
                    dotData: FlDotData(show: false),
                  ),
                ]
              : <LineChartBarData>[];
        }));
  }
}

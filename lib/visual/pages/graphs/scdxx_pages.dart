import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/scdxx_generic_datamodel.dart';
import 'package:flutter_iot_ui/core/util/db_updates_stream.dart';
import 'package:flutter_iot_ui/core/util/moving_average.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/general_graph_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class CarbonDioxidePage<T extends SCDXXSensorDataEntry>
    extends StatelessWidget {
  static const String route = '/CarbonDioxidePage';
  final String title = 'Carbon Dioxide (ppm)';

  @override
  Widget build(BuildContext context) {
    var model = context.read<GraphSettingsModel>();

    return GeneralGraphPage(
        route: CarbonDioxidePage.route,
        title: this.title,
        unit: 'ppm',
        seriesListStream: dbUpdatesOfType<T>(
                refreshDuration: model.graphRefreshTime,
                graphTimeWindow: model.graphTimeWindow)
            .map((event) {
          return (event.isNotEmpty)
              ? [
                  // id: 'Carbon Dioxide'
                  LineChartBarData(
                    spots: transformIntoMovingAverage(
                      event
                          .map((e) => FlSpot(
                              e.timeStamp.millisecondsSinceEpoch.toDouble(),
                              e.carbonDioxide.toDouble()))
                          .toList(),
                      model.useMovingAverage,
                      model.movingAverageSamples,
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

class TemperaturePage<T extends SCDXXSensorDataEntry> extends StatelessWidget {
  static const String route = '/TemperaturePage';
  final String title = 'Temperature (°C)';

  @override
  Widget build(BuildContext context) {
    var model = context.read<GraphSettingsModel>();

    return GeneralGraphPage(
        route: TemperaturePage.route,
        title: this.title,
        unit: '°C',
        seriesListStream: dbUpdatesOfType<T>(
                refreshDuration: model.graphRefreshTime,
                graphTimeWindow: model.graphTimeWindow)
            .map((event) {
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
                      model.useMovingAverage,
                      model.movingAverageSamples,
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

class HumidityPage<T extends SCDXXSensorDataEntry> extends StatelessWidget {
  static const String route = '/HumidityPage';
  final String title = 'Humidity (%RH)';

  @override
  Widget build(BuildContext context) {
    var model = context.read<GraphSettingsModel>();

    return GeneralGraphPage(
        route: HumidityPage.route,
        title: this.title,
        unit: '%RH',
        seriesListStream: dbUpdatesOfType<T>(
                refreshDuration: model.graphRefreshTime,
                graphTimeWindow: model.graphTimeWindow)
            .map((event) {
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
                      model.useMovingAverage,
                      model.movingAverageSamples,
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

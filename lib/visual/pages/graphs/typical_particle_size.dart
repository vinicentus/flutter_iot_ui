import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/util/db_updates_stream.dart';
import 'package:flutter_iot_ui/core/util/moving_average.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/general_graph_page.dart';
import 'package:provider/provider.dart';

class TypicalParticleSizePage extends StatelessWidget {
  static const String route = '/TypicalParticleSizePage';
  final String title = 'Typical Particle Size (µm)';

  @override
  Widget build(BuildContext context) {
    var model = context.read<GraphSettingsModel>();

    return GeneralGraphPage(
        route: TypicalParticleSizePage.route,
        title: this.title,
        unit: 'µm',
        seriesListStream: dbUpdatesOfType<SPS30SensorDataEntry>(
                refreshDuration: model.graphRefreshTime,
                graphTimeWindow: model.graphTimeWindow)
            .map((event) {
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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/general_graph_page.dart';

class TypicalParticleSizePage extends StatelessWidget {
  static const String route = '/TypicalParticleSizePage';
  final String title = 'Typical Particle Size (µm)';

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage<SPS30SensorDataEntry>(
      route: TypicalParticleSizePage.route,
      title: this.title,
      unit: 'µm',
      transformFunctions: [
        (e) => FlSpot(e.timeStamp.millisecondsSinceEpoch.toDouble(),
            e.typicalParticleSize)
      ],
    );
  }
}

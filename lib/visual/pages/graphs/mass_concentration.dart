// This has to be a StatefulWidget since we need to be able to tick the checkboxes
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/general_graph_page.dart';
import 'package:provider/provider.dart';

class MassConcentrationPage extends StatelessWidget {
  final String title = 'Mass Concentration (µg/m³)';
  static const String route = '/MassConcentrationPage';
  final String unit = 'µg/m³';

  @override
  Widget build(BuildContext context) {
    var model = context.read<GraphSettingsModel>();

    return GeneralGraphPage<SPS30SensorDataEntry>(
      title: title,
      route: route,
      unit: unit,
      transformFunctions: [
        (SPS30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            // No need to subtract values here
            e.massConcentrationPM1_0),
        (SPS30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            // Check if we should use subtracted values
            model.subtractParticleSizes
                ? e.massConcentrationPM2_5Subtracted
                : e.massConcentrationPM2_5),
        (SPS30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            // Check if we should use subtracted values
            model.subtractParticleSizes
                ? e.massConcentrationPM4_0Subtracted
                : e.massConcentrationPM4_0),
        (SPS30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            // Check if we should use subtracted values
            model.subtractParticleSizes
                ? e.massConcentrationPM10Subtracted
                : e.massConcentrationPM10),
      ],
      checkBoxNames: [
        '0.3-1.0µm',
        '1.0-2.5µm',
        '2.5-4.0µm',
        '4.0-10.0µm',
      ],
    );
  }
}

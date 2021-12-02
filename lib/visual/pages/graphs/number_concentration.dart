import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/util/sensor_location_enum.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/general_graph_page.dart';
import 'package:provider/provider.dart';

// This has to be a StatefulWidget since we have to be able to tick the checkboxes
class NumberConcentrationPage extends StatelessWidget {
  static const String route = '/NumberConcentrationPage';
  final String title = 'Number concentration (#/cm³)';
  final String unit = '#/cm³';

  @override
  Widget build(BuildContext context) {
    var model = context.read<GraphSettingsModel>();

    // Check route arguments to determine if this is supposed to be local or remote
    final sensorLocation = (ModalRoute.of(context)!.settings.arguments as List)
        .first as SensorLocation;

    return GeneralGraphPage<SPS30SensorDataEntry>(
      title: title,
      route: route,
      unit: unit,
      sensorLocation: sensorLocation,
      transformFunctions: [
        (SPS30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            // No need to subtract values here
            e.numberConcentrationPM0_5),
        (SPS30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            // Check if we should use subtracted values
            model.subtractParticleSizes
                ? e.numberConcentrationPM1_0Subtracted
                : e.numberConcentrationPM1_0),
        (SPS30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            // Check if we should use subtracted values
            model.subtractParticleSizes
                ? e.numberConcentrationPM2_5Subtracted
                : e.numberConcentrationPM2_5),
        (SPS30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            // Check if we should use subtracted values
            model.subtractParticleSizes
                ? e.numberConcentrationPM4_0Subtracted
                : e.numberConcentrationPM4_0),
        (SPS30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            // Check if we should use subtracted values
            model.subtractParticleSizes
                ? e.numberConcentrationPM10Subtracted
                : e.numberConcentrationPM10),
      ],
      checkBoxNames: [
        '0.3-0.5μm',
        '0.5-1.0μm',
        '1.0-2.5μm',
        '2.5-4.0μm',
        '4.0-10.0μm',
      ],
    );
  }
}

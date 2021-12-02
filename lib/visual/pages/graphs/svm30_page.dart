import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/svm30_datamodel.dart';
import 'package:flutter_iot_ui/core/util/sensor_location_enum.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/general_graph_page.dart';

class SVM30Page extends StatelessWidget {
  static const String route = '/SVM30Page';
  final String title = 'SVM30 Sensor Data';

  Widget build(BuildContext context) {
    // Check route arguments to determine if this is supposed to be local or remote
    final sensorLocation = (ModalRoute.of(context)!.settings.arguments as List)
        .first as SensorLocation;

    return GeneralGraphPage<SVM30SensorDataEntry>(
      title: title,
      route: route,
      unit: 'ppm (CO2eq) / ppb (VOC)',
      sensorLocation: sensorLocation,
      transformFunctions: [
        (SVM30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(), e.carbonDioxide),
        (SVM30SensorDataEntry e) => FlSpot(
            e.timeStamp.millisecondsSinceEpoch.toDouble(),
            e.totalVolatileOrganicCompounds),
      ],
      checkBoxNames: ['CO2eq', 'VOC'],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/scdxx_generic_datamodel.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/general_graph_page.dart';
import 'package:fl_chart/fl_chart.dart';

class CarbonDioxidePage<T extends SCDXXSensorDataEntry>
    extends StatelessWidget {
  static const String route = '/CarbonDioxidePage';
  final String title = 'Carbon Dioxide (ppm)';

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage<T>(
      route: CarbonDioxidePage.route,
      title: this.title,
      unit: 'ppm',
      transformFunctions: [
        (T e) => FlSpot(e.timeStamp.millisecondsSinceEpoch.toDouble(),
            e.carbonDioxide.toDouble())
      ],
    );
  }
}

class TemperaturePage<T extends SCDXXSensorDataEntry> extends StatelessWidget {
  static const String route = '/TemperaturePage';
  final String title = 'Temperature (°C)';

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage<T>(
      route: TemperaturePage.route,
      title: this.title,
      unit: '°C',
      transformFunctions: [
        (T e) =>
            FlSpot(e.timeStamp.millisecondsSinceEpoch.toDouble(), e.temperature)
      ],
    );
  }
}

class HumidityPage<T extends SCDXXSensorDataEntry> extends StatelessWidget {
  static const String route = '/HumidityPage';
  final String title = 'Humidity (%RH)';

  @override
  Widget build(BuildContext context) {
    return GeneralGraphPage<T>(
      route: HumidityPage.route,
      title: this.title,
      unit: '%RH',
      transformFunctions: [
        (T e) =>
            FlSpot(e.timeStamp.millisecondsSinceEpoch.toDouble(), e.humidity)
      ],
    );
  }
}

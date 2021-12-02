import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/general_graph_page.dart';
import 'package:fl_chart/fl_chart.dart';

class CarbonDioxidePage extends StatelessWidget {
  static const String route = '/CarbonDioxidePage';
  final String title = 'Carbon Dioxide (ppm)';

  @override
  Widget build(BuildContext context) {
    var routeArguments = ModalRoute.of(context)!.settings.arguments as List;
    var type = routeArguments[1];

    if (type == 'scd41') {
      return GeneralGraphPage<SCD41SensorDataEntry>(
        route: CarbonDioxidePage.route,
        title: this.title,
        unit: 'ppm',
        transformFunctions: [
          (SCD41SensorDataEntry e) => FlSpot(
              e.timeStamp.millisecondsSinceEpoch.toDouble(),
              e.carbonDioxide.toDouble())
        ],
      );
    } else if (type == 'scd30') {
      return GeneralGraphPage<SCD30SensorDataEntry>(
        route: CarbonDioxidePage.route,
        title: this.title,
        unit: 'ppm',
        transformFunctions: [
          (SCD30SensorDataEntry e) => FlSpot(
              e.timeStamp.millisecondsSinceEpoch.toDouble(),
              e.carbonDioxide.toDouble())
        ],
      );
    } else {
      throw Exception(['Unknown type', type]);
    }
  }
}

class TemperaturePage extends StatelessWidget {
  static const String route = '/TemperaturePage';
  final String title = 'Temperature (°C)';

  @override
  Widget build(BuildContext context) {
    var routeArguments = ModalRoute.of(context)!.settings.arguments as List;
    var type = routeArguments[1];

    if (type == 'scd41') {
      return GeneralGraphPage<SCD41SensorDataEntry>(
        route: TemperaturePage.route,
        title: this.title,
        unit: '°C',
        transformFunctions: [
          (SCD41SensorDataEntry e) => FlSpot(
              e.timeStamp.millisecondsSinceEpoch.toDouble(), e.temperature)
        ],
      );
    } else if (type == 'scd30') {
      return GeneralGraphPage<SCD30SensorDataEntry>(
        route: TemperaturePage.route,
        title: this.title,
        unit: '°C',
        transformFunctions: [
          (SCD30SensorDataEntry e) => FlSpot(
              e.timeStamp.millisecondsSinceEpoch.toDouble(), e.temperature)
        ],
      );
    } else {
      throw Exception(['Unknown type', type]);
    }
  }
}

class HumidityPage extends StatelessWidget {
  static const String route = '/HumidityPage';
  final String title = 'Humidity (%RH)';

  @override
  Widget build(BuildContext context) {
    var routeArguments = ModalRoute.of(context)!.settings.arguments as List;
    var type = routeArguments[1];

    if (type == 'scd41') {
      return GeneralGraphPage<SCD41SensorDataEntry>(
        route: HumidityPage.route,
        title: this.title,
        unit: '%RH',
        transformFunctions: [
          (SCD41SensorDataEntry e) =>
              FlSpot(e.timeStamp.millisecondsSinceEpoch.toDouble(), e.humidity)
        ],
      );
    }
    if (type == 'scd30') {
      return GeneralGraphPage<SCD30SensorDataEntry>(
        route: HumidityPage.route,
        title: this.title,
        unit: '%RH',
        transformFunctions: [
          (SCD30SensorDataEntry e) =>
              FlSpot(e.timeStamp.millisecondsSinceEpoch.toDouble(), e.humidity)
        ],
      );
    } else {
      print(type);
      throw Exception(['Unknown type', type]);
    }
  }
}

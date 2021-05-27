import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/scd30/scd30_datamodel.dart';

class SCD30DataChart extends StatelessWidget {
  final List<charts.Series<SCD30SensorDataEntry, DateTime>> seriesList;
  final bool animate;

  SCD30DataChart(List<SCD30SensorDataEntry> sensorDB, {this.animate = true})
      : this.seriesList = [
          new charts.Series<SCD30SensorDataEntry, DateTime>(
              id: 'Number Concentration PM10 [#/cm³]',
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (SCD30SensorDataEntry value, _) => value.timeStamp,
              measureFn: (SCD30SensorDataEntry value, _) => value.temperature,
              data: sensorDB),
        ];

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }
}

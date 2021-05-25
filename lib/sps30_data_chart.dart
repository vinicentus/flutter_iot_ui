import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/sqlite.dart';

class SPS30DataChart extends StatelessWidget {
  final List<charts.Series<SPS30SensorDataEntry, DateTime>> seriesList;
  final bool animate;

  SPS30DataChart(SensorDB sensorDB, {this.animate = true})
      : this.seriesList = [
          new charts.Series<SPS30SensorDataEntry, DateTime>(
              id: 'Number Concentration PM10 [#/cm³]',
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (SPS30SensorDataEntry value, _) => value.timeStamp,
              measureFn: (SPS30SensorDataEntry value, _) =>
                  value.numberConcentrationPM10,
              data: sensorDB.entryList),
        ];

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SPS30DataChart.withSampleData() {
    return new SPS30DataChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

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

  /// Create one series with sample hard coded data.
  static SensorDB _createSampleData() {
    final data = [
      new SPS30SensorDataEntry(
          new DateTime(2017, 9, 19), [5, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
      new SPS30SensorDataEntry(
          new DateTime(2017, 9, 26), [25, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
      new SPS30SensorDataEntry(
          new DateTime(2017, 10, 3), [100, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
      new SPS30SensorDataEntry(
          new DateTime(2017, 10, 10), [75, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
    ];

    return SensorDB(data);
  }
}

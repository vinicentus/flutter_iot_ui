import 'package:fl_chart/fl_chart.dart';
import 'package:moving_average/moving_average.dart';

List<FlSpot> transformIntoMovingAverage(
    List<FlSpot> flspotList, bool transform, int windowSize) {
  // Don't do anything with the data unless instructed to
  if (!transform) {
    return flspotList;
  }

  var simpleMovingAverage = MovingAverage<FlSpot>(
    // The window size is the number of samples per average sample returned
    // (not specified in units of time).
    // We currently get samples roughly every minute, so a value of 5
    // would mean that the averages are calculated over 5 minute periods.
    windowSize: windowSize,
    getValue: (FlSpot spot) => spot.y,
    add: (List<FlSpot> data, num value) {
      var middleTimestamp = data[data.length ~/ 2].x;
      // We know the y coordinate will be a double, since we only return doubles in getValue
      return FlSpot(middleTimestamp, (value as double));
    },
  );

  return simpleMovingAverage(flspotList);
}

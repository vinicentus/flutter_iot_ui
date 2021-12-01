import 'package:flutter_iot_ui/core/services/sensors_db/web_chunks_db.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('one hour', () {
    var now = DateTime.now();
    var oneHourAgo = now.subtract(Duration(hours: 1));
    var result =
        Web3ChunkDbManager().splitIntoSmallTimeIntervals(oneHourAgo, now);

    expect(result, [oneHourAgo, now]);
  });

  test('two hours', () {
    var now = DateTime.now();
    var twoHoursAgo = now.subtract(Duration(hours: 2));
    var result =
        Web3ChunkDbManager().splitIntoSmallTimeIntervals(twoHoursAgo, now);

    var oneHourAgo = now.subtract(Duration(hours: 1));

    expect(result, [twoHoursAgo, oneHourAgo, now]);
  });
  test('three hours, 15 minutes', () {
    var now = DateTime.now();
    var threeHoursAgo = now.subtract(Duration(hours: 3, minutes: 15));
    var result =
        Web3ChunkDbManager().splitIntoSmallTimeIntervals(threeHoursAgo, now);

    var twoHoursAgo = now.subtract(Duration(hours: 2, minutes: 15));
    var oneHourAgo = now.subtract(Duration(hours: 1, minutes: 15));
    var fifteenMinutesAgo = now.subtract(Duration(minutes: 15));

    expect(result,
        [threeHoursAgo, twoHoursAgo, oneHourAgo, fifteenMinutesAgo, now]);
  });
}

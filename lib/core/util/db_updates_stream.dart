import 'package:flutter_iot_ui/core/models/sensors/generic_datamodel.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'package:get_it/get_it.dart';

Stream<List<T>> dbUpdatesOfType<T extends GenericSensorDataEntry>(
    {required Duration refreshDuration,
    required Duration graphTimeWindow}) async* {
  var dbManager = GetIt.instance<DatabaseManager>();

  // Init
  var today = DateTime.now();
  var yesterday = today.subtract(graphTimeWindow);
  // Just creating an instance of this singleton class will initialize it and the database.
  var db = await dbManager.getEntriesOfType<T>(start: yesterday, stop: today);
  yield db;

  // This stream will be automatically cancelled by dart when no longer needed.
  // Furhtermore this loop will automatically stop running when the stream is canceled.
  while (true) {
    today = DateTime.now();
    yesterday = today.subtract(graphTimeWindow);
    db = await Future.delayed(refreshDuration,
        () => dbManager.getEntriesOfType<T>(start: yesterday, stop: today));
    yield db;
  }
}

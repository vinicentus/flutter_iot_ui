import 'package:flutter_iot_ui/core/models/sensors/generic_datamodel.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/sqlite_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/storj_web3_sqlite_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web_chunks_db.dart';
import 'package:flutter_iot_ui/core/util/sensor_location_enum.dart';
import 'package:get_it/get_it.dart';

Stream<List<T>> dbUpdatesOfType<T extends GenericSensorDataEntry>(
    {required Duration refreshDuration,
    required Duration graphTimeWindow,
    required SensorLocation sensorLocation,
    required bool usesStorj,
    required bool useEncryption}) async* {
  DatabaseManager dbManager;
  if (sensorLocation == SensorLocation.remote) {
    if (usesStorj) {
      dbManager = GetIt.instance<StorjSQLiteWeb3DbManager>();
      (dbManager as StorjSQLiteWeb3DbManager).useEncryption = useEncryption;
    } else {
      dbManager = GetIt.instance<Web3ChunkDbManager>();
      (dbManager as Web3ChunkDbManager).useEncryption = useEncryption;
    }
  } else {
    dbManager = GetIt.instance<SQLiteDatabaseManager>();
  }

  DateTime today;
  DateTime yesterday;

  // This stream will be automatically cancelled by dart when no longer needed.
  // Furhtermore this loop will automatically stop running when the stream is canceled.
  while (true) {
    today = DateTime.now();
    yesterday = today.subtract(graphTimeWindow);

    print('dbUpdates loop $today');

    // If this stream is canceled, the stream completes next time we land here
    // TODO: don't evaluate right hand before returning if stream is canceled
    yield await dbManager.getEntriesOfType<T>(start: yesterday, stop: today);
    await Future.delayed(refreshDuration);
  }
}

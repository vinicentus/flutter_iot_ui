import 'package:flutter_iot_ui/core/models/sensors/generic_datamodel.dart';
import 'package:flutter_iot_ui/core/services/selected_devices_model.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_db.dart';
import 'package:get_it/get_it.dart';

/// This fetches data for all the selected devices,
/// and, refreshes thad data every once in a while.
Stream<List<List<T>>>
    multipleDeviceDbUpdatesOfType<T extends GenericSensorDataEntry>(
        {required Duration refreshDuration,
        required Duration graphTimeWindow}) async* {
  final remoteDbManager = GetIt.instance<Web3Manager>();
  // final localDbManager = GetIt.instance<Web3Manager>();

  final devices = GetIt.instance<SelectedDevicesModel>();

  DateTime today;
  DateTime yesterday;

  // This stream will be automatically cancelled by dart when no longer needed.
  // Furhtermore this loop will automatically stop running when the stream is canceled.
  while (true) {
    today = DateTime.now();
    yesterday = today.subtract(graphTimeWindow);

    print('dbUpdates loop $today');

    var accumulator = <List<T>>[];
    for (final id in devices.selectedOracleIds) {
      // If this stream is canceled, the stream completes next time we land here
      // TODO: don't evaluate right hand before returning if stream is canceled
      accumulator.add(await remoteDbManager.getEntriesOfType<T>(
          deviceID: id, start: yesterday, stop: today));
    }
    // TODO: get data for local jsonIDs
    // if (devices.localOracleId != null) {
    //   accumulator.add(await localDbManager.getEntriesOfType<T>(
    //       deviceID: devices.localOracleId!, start: yesterday, stop: today));
    // }
    yield accumulator;

    await Future.delayed(refreshDuration);
  }
}

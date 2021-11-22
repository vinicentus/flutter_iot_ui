import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:flutter_iot_ui/core/models/sensors/generic_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/svm30_datamodel.dart';

/// Base class that will be extended by implementations,
/// such as an SQLite based database, or a Storj DCS based database.
/// Implementations should most likely be singletons.
abstract class DatabaseManager {
  /// Get all database entries for SPS30.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {required JsonId deviceID, DateTime? start, DateTime? stop});

  /// Get all database entries for SCD30.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {required JsonId deviceID, DateTime? start, DateTime? stop});

  /// Get all database entries for SCD41.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SCD41SensorDataEntry>> getSCD41Entries(
      {required JsonId deviceID, DateTime? start, DateTime? stop});

  /// Get all database entries for SVM30.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {required JsonId deviceID, DateTime? start, DateTime? stop});

  /// Get all database entries for any subtype of GenericSensorDataEntry.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<T>> getEntriesOfType<T extends GenericSensorDataEntry>(
      {required JsonId deviceID, DateTime? start, DateTime? stop}) {
    switch (T) {
      case SPS30SensorDataEntry:
        return getSPS30Entries(deviceID: deviceID, start: start, stop: stop)
            as Future<List<T>>;
      case SCD30SensorDataEntry:
        return getSCD30Entries(deviceID: deviceID, start: start, stop: stop)
            as Future<List<T>>;
      case SCD41SensorDataEntry:
        return getSCD41Entries(deviceID: deviceID, start: start, stop: stop)
            as Future<List<T>>;
      case SVM30SensorDataEntry:
        return getSVM30Entries(deviceID: deviceID, start: start, stop: stop)
            as Future<List<T>>;
      default:
        throw Exception(
            'Tried to get an unimplemented type of GenericSensorDataEntry.');
      // return getSCD30Entries(start: start, stop: stop);
    }
  }
}

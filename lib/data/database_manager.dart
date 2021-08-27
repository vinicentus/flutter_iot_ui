import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/data/svm30_datamodel.dart';

/// Base class that will be extended by implementations,
/// such as an SQLite based database, or a Storj DCS based database.
/// Implementations should most likely be singletons.
abstract class DatabaseManager {
  /// Get all database entries for SPS30.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop});

  /// Get all database entries for SCD30.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop});

  /// Get all database entries for SVM30.
  /// Optionally provide a [start] and [stop] time,
  /// to get only the entries between those timestamps.
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop});
}

import 'dart:io';

import 'package:flutter_iot_ui/core/models/sensors/svm30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/sqlite_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_mixin.dart';
import 'package:flutter_iot_ui/core/util/storj_keys.dart' as keystore;
import 'package:http/http.dart' as http;

// TODO: add task to make IoT device update data
class StorjSQLiteWeb3DbManager extends SQLiteDatabaseManager
    with SimpleWeb3DbManager {
  StorjSQLiteWeb3DbManager() {
    // super.dbPath = '/home/pi/git-repos/IoT-Microservice/app/oracle/temp.db';
    super.dbPath = 'C:/Users/langstvi/OneDrive - Arcada/Documents/temp.db';
  }

  // https://link.<region>.storjshare.io/raw/<access key>/<object path>
  String _generateAccessLink(
          String region, String accessKey, String objectPath) =>
      'https://link.$region.storjshare.io/raw/$accessKey/$objectPath';

  String get _accessLink => _generateAccessLink(
      'eu1', keystore.storjS3AccessKey, 'iot-microservice/temp.db');

  http.Client _httpClient = http.Client();

  Future<File> _fetchAndStoreDB() async {
    final stopwatch = Stopwatch()..start();
    var response = await _httpClient.get(Uri.parse(_accessLink));
    print('fetch executed in ${stopwatch.elapsed}');
    if (response.statusCode == 200) {
      var file = await File(super.dbPath).writeAsBytes(response.bodyBytes);

      print('write executed in ${stopwatch.elapsed}');
      stopwatch.stop();

      return file;
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data.');
    }
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    await geteEntries(tableName: 'scd30_output', taskReturnType: 'storj');
    await _fetchAndStoreDB();
    return super.getSCD30Entries(start: start, stop: stop);
  }

  @override
  Future<List<SCD41SensorDataEntry>> getSCD41Entries(
      {DateTime? start, DateTime? stop}) async {
    await geteEntries(tableName: 'scd41_output', taskReturnType: 'storj');
    await _fetchAndStoreDB();
    return super.getSCD41Entries(start: start, stop: stop);
  }

  @override
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) async {
    await geteEntries(tableName: 'sps30_output', taskReturnType: 'storj');
    await _fetchAndStoreDB();
    return super.getSPS30Entries(start: start, stop: stop);
  }

  @override
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) async {
    await geteEntries(tableName: 'svm30_output', taskReturnType: 'storj');
    await _fetchAndStoreDB();
    return super.getSVM30Entries(start: start, stop: stop);
  }
}

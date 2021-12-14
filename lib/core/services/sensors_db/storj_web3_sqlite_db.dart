import 'dart:io';

import 'package:flutter_iot_ui/core/models/sensors/svm30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/services/cryptography.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/sqlite_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_mixin.dart';
import 'package:flutter_iot_ui/core/util/storj_keys.dart' as keystore;
import 'package:get_it/get_it.dart';
import 'package:storj_dart/storj_dart.dart';
import 'package:storj_dart/convenience_lib.dart';

// TODO: add task to make IoT device update data
class StorjSQLiteWeb3DbManager extends SQLiteDatabaseManager
    with SimpleWeb3DbManager {
  StorjSQLiteWeb3DbManager() {
    // TODO: use sqlite3.openInMemory()
    // super.dbPath = '/home/pi/git-repos/IoT-Microservice/app/oracle/temp.db';
    super.dbPath = 'C:/Users/langstvi/OneDrive - Arcada/Documents/temp.db';

    // Initialize storj library
    loadDynamicLibrary(
        'C:/Users/langstvi/OneDrive - Arcada/Documents/libuplinkc.so');
  }

  EncryptorDecryptor decryptor = GetIt.instance<EncryptorDecryptor>();
  // TODO: move to settings page
  bool useEncryption = true;

  String? publickKey;

  Future<File> _fetchAndStoreDB() async {
    final stopwatch = Stopwatch()..start();

    var access = DartUplinkAccess.parseAccess(keystore.access);
    var project = DartUplinkProject.openProject(access);
    var fileBytes =
        await project.downloadBytesFuture('iot-microservice', 'temp.db');
    print('fetch executed in ${stopwatch.elapsed}');
    stopwatch.reset();

    var file = await File(super.dbPath).writeAsBytes(fileBytes);
    print('write executed in ${stopwatch.elapsed}');
    stopwatch.stop();

    return file;
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    await waitForTaskCompletion(
        tableName: 'scd30_output',
        taskReturnType: 'storj',
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    return super.getSCD30Entries(start: start, stop: stop);
  }

  @override
  Future<List<SCD41SensorDataEntry>> getSCD41Entries(
      {DateTime? start, DateTime? stop}) async {
    await waitForTaskCompletion(
        tableName: 'scd41_output',
        taskReturnType: 'storj',
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    return super.getSCD41Entries(start: start, stop: stop);
  }

  @override
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) async {
    await waitForTaskCompletion(
        tableName: 'sps30_output',
        taskReturnType: 'storj',
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    return super.getSPS30Entries(start: start, stop: stop);
  }

  @override
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) async {
    await waitForTaskCompletion(
        tableName: 'svm30_output',
        taskReturnType: 'storj',
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    return super.getSVM30Entries(start: start, stop: stop);
  }
}

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
import 'package:uplink_dart/uplink_dart.dart';
import 'package:uplink_dart/convenience_lib.dart';

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

    // This must be called after loadDynamicLibrary, and masterAccess needs to be marked late
    masterAccess = DartUplinkAccess.parseAccess(keystore.access);
  }

  late DartUplinkAccess masterAccess;

  EncryptorDecryptor encryptor = GetIt.instance<EncryptorDecryptor>();
  // TODO: move to settings page
  bool useEncryption = true;

  String? publickKey;

  String _generateAccess() {
    // var now = DateTime.now();
    // var future = now.add(Duration(minutes: 10));
    return masterAccess.share(
        DartUplinkPermission(
          allowUpload: true,
        ), //notBefore: now, notAfter: future),
        [
          DartUplinkUplinkSharePrefix('iot-microservice', 'temp.db')
        ]).serialize();
  }

  Future<File> _fetchAndStoreDB() async {
    final stopwatch = Stopwatch()..start();

    var project = DartUplinkProject.openProject(masterAccess);
    var fileBytes =
        await project.downloadBytesFuture('iot-microservice', 'temp.db');
    print('fetch executed in ${stopwatch.elapsed}');
    stopwatch.reset();

    var file = await File(super.dbPath).writeAsBytes(fileBytes);
    print('write executed in ${stopwatch.elapsed}');
    stopwatch.stop();

    return file;
  }

  String createStorjTaskString({
    required String possiblyEncryptedAccess,
    required bool isEncrypted,
    String? publicKey,
  }) {
    return convertToBase64({
      'possibly_encrypted_access': possiblyEncryptedAccess,
      'is_encrypted': isEncrypted,
      'public_key': publicKey, // whole pem file as string
      'task_return_type': 'storj'
    });
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    var access = _generateAccess();
    await waitForTaskCompletion(
        createStorjTaskString(
            possiblyEncryptedAccess: access, isEncrypted: false),
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    return super.getSCD30Entries(start: start, stop: stop);
  }

  @override
  Future<List<SCD41SensorDataEntry>> getSCD41Entries(
      {DateTime? start, DateTime? stop}) async {
    var access = _generateAccess();
    print(access);
    await waitForTaskCompletion(
        createStorjTaskString(
            possiblyEncryptedAccess: access, isEncrypted: false),
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    return super.getSCD41Entries(start: start, stop: stop);
  }

  @override
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) async {
    var access = _generateAccess();
    await waitForTaskCompletion(
        createStorjTaskString(
            possiblyEncryptedAccess: access, isEncrypted: false),
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    return super.getSPS30Entries(start: start, stop: stop);
  }

  @override
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) async {
    var access = _generateAccess();
    await waitForTaskCompletion(
        createStorjTaskString(
            possiblyEncryptedAccess: access, isEncrypted: false),
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    return super.getSVM30Entries(start: start, stop: stop);
  }
}

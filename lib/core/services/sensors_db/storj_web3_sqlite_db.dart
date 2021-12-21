import 'dart:io';

import 'package:flutter_iot_ui/core/models/sensors/svm30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/services/cryptography.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/sqlite_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_mixin.dart';
import 'package:flutter_iot_ui/core/util/paths.dart';
import 'package:flutter_iot_ui/core/util/storj_keys.dart' as keystore;
import 'package:get_it/get_it.dart';
import 'package:uplink_dart/uplink_dart.dart';
import 'package:uplink_dart/convenience_lib.dart';

// TODO: add task to make IoT device update data
class StorjSQLiteWeb3DbManager extends SQLiteDatabaseManager
    with SimpleWeb3DbManager {
  // Call super in order to choose correct db path
  StorjSQLiteWeb3DbManager() : super.withPath(tempDbPath) {
    // Initialize storj library
    loadDynamicLibrary(libuplinkcDllPath);

    // This must be called after loadDynamicLibrary, and masterAccess needs to be marked late
    masterAccess = DartUplinkAccess.parseAccess(keystore.access);
  }

  late DartUplinkAccess masterAccess;

  EncryptorDecryptor encryptor = GetIt.instance<EncryptorDecryptor>();
  bool useEncryption = true;

  // This is not the public key of the UI, but rather that of the IoT device
  String? publicKey;

  String _bucketName = 'iot-microservice';
  String _filePath = 'temp.db';

  /// Because the IoT device is not allowed to delete old databses,
  /// we have to delete is before requesting new data.
  /// If there exists an old database when the IoT device tries to upload,
  /// the task will fail, because the IoT device is not allowed
  /// to overwrite any data.
  ///
  /// Currently this has no way of knowing if there exist a file or not,
  /// it just blindly tries to delete it. This is OK if we know there is
  /// a file to delete.
  void _deleteOldDB() {
    var project = DartUplinkProject.openProject(masterAccess);
    project.deleteObject(_bucketName, _filePath);
    project.close();
  }

  String _generateAccess() {
    var now = DateTime.now();
    // Only allow the IoT Device to upload, only the next minute
    var future = now.add(Duration(minutes: 1));
    return masterAccess.share(
      DartUplinkPermission(allowUpload: true, notBefore: now, notAfter: future),
      [DartUplinkUplinkSharePrefix(_bucketName, _filePath)],
    ).serialize();
  }

  Future<File> _fetchAndStoreDB() async {
    final stopwatch = Stopwatch()..start();

    var project = DartUplinkProject.openProject(masterAccess);
    var fileBytes = await project.downloadBytesFuture(_bucketName, _filePath);
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

  String createRequestRsaTaskString() {
    return convertToBase64({'task_return_type': 'send_rsa_key'});
  }

  Future<String> _requestRsaPublicKey() async {
    if (publicKey == null) {
      return publicKey =
          await waitForTaskCompletion(createRequestRsaTaskString());
    } else {
      return publicKey!;
    }
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    var access = _generateAccess();
    if (useEncryption) {
      print(await _requestRsaPublicKey());
    }
    await waitForTaskCompletion(
        createStorjTaskString(
            possiblyEncryptedAccess: access, isEncrypted: false),
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    _deleteOldDB();
    return super.getSCD30Entries(start: start, stop: stop);
  }

  @override
  Future<List<SCD41SensorDataEntry>> getSCD41Entries(
      {DateTime? start, DateTime? stop}) async {
    var access = _generateAccess();
    if (useEncryption) {
      print(await _requestRsaPublicKey());
    }
    await waitForTaskCompletion(
        createStorjTaskString(
            possiblyEncryptedAccess: access, isEncrypted: false),
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    _deleteOldDB();
    return super.getSCD41Entries(start: start, stop: stop);
  }

  @override
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) async {
    var access = _generateAccess();
    if (useEncryption) {
      print(await _requestRsaPublicKey());
    }
    await waitForTaskCompletion(
        createStorjTaskString(
            possiblyEncryptedAccess: access, isEncrypted: false),
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    _deleteOldDB();
    return super.getSPS30Entries(start: start, stop: stop);
  }

  @override
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) async {
    var access = _generateAccess();
    if (useEncryption) {
      print(await _requestRsaPublicKey());
    }
    await waitForTaskCompletion(
        createStorjTaskString(
            possiblyEncryptedAccess: access, isEncrypted: false),
        timeout: Duration(seconds: 30));
    await _fetchAndStoreDB();
    _deleteOldDB();
    return super.getSVM30Entries(start: start, stop: stop);
  }
}

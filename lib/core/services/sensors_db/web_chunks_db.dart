import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/svm30_datamodel.dart';
import 'package:flutter_iot_ui/core/services/cryptography.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_mixin.dart';
import 'package:get_it/get_it.dart';

class Web3ChunkDbManager extends DatabaseManager with SimpleWeb3DbManager {
  EncryptorDecryptor decryptor = GetIt.instance<EncryptorDecryptor>();
  // TODO: move to settings page
  bool useEncryption = true;

  String? publickKey;

  /// Split interval into smaller chunks that are a maximum of 1 hour long
  @visibleForTesting
  List<DateTime> splitIntoSmallTimeIntervals(DateTime start, DateTime stop) {
    var hourDifference = stop.difference(start).inHours;
    if (hourDifference > 1) {
      var returnList = <DateTime>[];
      for (int i = 0; i <= hourDifference; i++) {
        returnList.add(start.add(Duration(hours: i)));
      }
      // We have now addedd all the one hour segments
      // Check if there are still shorter time intervals to be added
      if (returnList.last != stop) {
        returnList.add(stop);
      }
      return returnList;
    } else {
      return [start, stop];
    }
  }

  // TODO: don't wait for previous task to complete before submitting new one
  Stream<List> _getEntriesInChunksAsStream(
      {required String tableName, DateTime? start, DateTime? stop}) async* {
    // TODO: bad null check
    var timeChunkList = splitIntoSmallTimeIntervals(start!, stop!);

    var intervalCount = timeChunkList.length - 1;

    for (int i = 0; i < intervalCount; i++) {
      print('returning chunk ${i + 1}/$intervalCount');
      if (useEncryption) {
        print('Using encryption, including public RSA key in task...');
        publickKey = await decryptor.rsaPublicKeyBase64();

        var completedPartiallyDecodedTask =
            convertFromBase64(await waitForTaskCompletion(
          tableName: tableName,
          publicKey: publickKey,
          start: timeChunkList[i],
          stop: timeChunkList[i + 1],
        ));

        print('Decrypting the task result...');
        yield await decryptResult(completedPartiallyDecodedTask);
      } else {
        yield convertFromBase64(await waitForTaskCompletion(
          tableName: tableName,
          publicKey: null,
          start: timeChunkList[i],
          stop: timeChunkList[i + 1],
        )) as List;
      }
    }
  }

  Future<List> _getEntriesInChunks(
      {required String tableName, DateTime? start, DateTime? stop}) {
    return _getEntriesInChunksAsStream(
            tableName: tableName, start: start, stop: stop)
        .fold([], (previous, element) => previous..addAll(element));
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    List taskResult = await _getEntriesInChunks(
        tableName: 'scd30_output', start: start, stop: stop);

    // [2021-08-23T00:00:01Z, 406.9552001953125, 19.77590560913086, 61.5251579284668],
    var returnList = <SCD30SensorDataEntry>[];
    taskResult.forEach((element) {
      returnList.add(SCD30SensorDataEntry.createFromDB(
          element[0], element[1], element[2], element[3]));
    });
    return returnList;
  }

  @override
  Future<List<SCD41SensorDataEntry>> getSCD41Entries(
      {DateTime? start, DateTime? stop}) async {
    List taskResult = await _getEntriesInChunks(
        tableName: 'scd41_output', start: start, stop: stop);

    // [2021-08-23T00:00:01Z, 406.9552001953125, 19.77590560913086, 61.5251579284668],
    var returnList = <SCD41SensorDataEntry>[];
    taskResult.forEach((element) {
      returnList.add(SCD41SensorDataEntry.createFromDB(
          element[0], element[1], element[2], element[3]));
    });
    return returnList;
  }

  @override
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) async {
    List taskResult = await _getEntriesInChunks(
        tableName: 'sps30_output', start: start, stop: stop);

    var returnList = <SPS30SensorDataEntry>[];
    taskResult.forEach((element) {
      returnList.add(SPS30SensorDataEntry.createFromDB(
          element[0],
          element[1],
          element[2],
          element[3],
          element[4],
          element[5],
          element[6],
          element[7],
          element[8],
          element[9],
          element[10]));
    });
    return returnList;
  }

  @override
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) async {
    List taskResult = await _getEntriesInChunks(
        tableName: 'svm30_output', start: start, stop: stop);

    var returnList = <SVM30SensorDataEntry>[];
    taskResult.forEach((element) {
      returnList.add(SVM30SensorDataEntry.createFromDB(
          element[0], element[1], element[2]));
    });
    return returnList;
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/svm30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/sps30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:get_it/get_it.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'sqlite_db.dart' show convertDateTimeToString;

class Web3Manager extends DatabaseManager {
  // Use the globally exposed web3client, not a separate one.
  Web3 _web3Client = GetIt.instance<Web3>();

  String _createTaskString(
      {required String startTime,
      required String stopTime,
      String? publicKey,
      required String tableName}) {
    return convertToBase64({
      '_start_time': startTime,
      '_stop_time': stopTime,
      'public_key': publicKey,
      'tableName': tableName
    });
  }

  String convertToBase64(Map<String, dynamic> input) {
    // I'm honestly surprised and impressed by how neat this looks in pure dart!
    var jsonString = json.encode(input);
    var utf8List = utf8.encode(jsonString);
    return base64.encode(utf8List);
  }

  dynamic convertFromBase64(String base64Task) {
    var utf8List = base64.decode(base64Task);
    var jsonString = utf8.decode(utf8List);
    return json.decode(jsonString);
  }

  Future<List> _geteEntries(
      {required String tableName,
      String? publicKey,
      DateTime? start,
      DateTime? stop}) async {
    // TODO: don't load all contracts (also loaduser and loadoracle) every time
    await _web3Client.init();
    await _web3Client.loadUser();
    await _web3Client.loadOraclesForActiveUser();

    var taskAddress = await _web3Client.addTask(_createTaskString(
        // TODO: bad non-null assertions
        startTime: convertDateTimeToString(start!),
        stopTime: convertDateTimeToString(stop!),
        publicKey: publicKey, // TODO
        tableName: tableName));
    if (taskAddress is! EthereumAddress) {
      throw Exception('Got back invalid task address: $taskAddress');
    }

    // TODO: add timeout
    var event = _web3Client.taskManager
        .task_completedEvents()
        // 10 retries
        .take(10)
        .firstWhere((event) {
      // Check that it is the right task that was completed!
      return event.task == taskAddress;
    }, orElse: () {
      // TODO: add orelse that return custom error
      throw Exception('Failed to get back completed task');
    });

    var awaitedEvent = await event;

    // Example of valid task in list [2021-08-23T00:00:01Z, 406.9552001953125, 19.77590560913086, 61.5251579284668],
    // This breaks the while loop
    return convertFromBase64(awaitedEvent.data);
  }

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
      {required String tableName,
      String? publicKey,
      DateTime? start,
      DateTime? stop}) async* {
    // TODO: bad null check
    var timeChunkList = splitIntoSmallTimeIntervals(start!, stop!);

    var intervalCount = timeChunkList.length - 1;

    for (int i = 0; i < intervalCount; i++) {
      print('returning chunk ${i + 1}/$intervalCount');
      yield await _geteEntries(
        tableName: tableName,
        publicKey: publicKey,
        start: timeChunkList[i],
        stop: timeChunkList[i + 1],
      );
    }
  }

  Future<List> _getEntriesInChunks(
      {required String tableName,
      String? publicKey,
      DateTime? start,
      DateTime? stop}) {
    return _getEntriesInChunksAsStream(
            tableName: tableName,
            publicKey: publicKey,
            start: start,
            stop: stop)
        .fold([], (previous, element) => previous..addAll(element));
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    List taskResult = await _getEntriesInChunks(
        tableName: 'scd30_output', publicKey: null, start: start, stop: stop);

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
        tableName: 'scd41_output', publicKey: null, start: start, stop: stop);

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
        tableName: 'sps30_output', publicKey: null, start: start, stop: stop);

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
        tableName: 'svm30_output', publicKey: null, start: start, stop: stop);

    var returnList = <SVM30SensorDataEntry>[];
    taskResult.forEach((element) {
      returnList.add(SVM30SensorDataEntry.createFromDB(
          element[0], element[1], element[2]));
    });
    return returnList;
  }
}

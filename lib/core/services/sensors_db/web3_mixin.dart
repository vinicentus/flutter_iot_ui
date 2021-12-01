import 'dart:convert';

import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:get_it/get_it.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'sqlite_db.dart' show convertDateTimeToString;

mixin SimpleWeb3DbManager on DatabaseManager {
  // Use the globally exposed web3client, not a separate one.
  Web3 web3Client = GetIt.instance<Web3>();

  Future<List> geteEntries(
      {required String tableName,
      String? publicKey,
      DateTime? start,
      DateTime? stop,
      String? taskReturnType}) async {
    // TODO: don't load all contracts (also loaduser and loadoracle) every time
    await web3Client.loadUser();
    await web3Client.getOraclesForActiveUser();

    var taskAddress = await web3Client.addTask(createTaskString(
        // TODO: bad non-null assertions
        startTime: convertDateTimeToString(start!),
        stopTime: convertDateTimeToString(stop!),
        publicKey: publicKey, // TODO
        tableName: tableName));
    if (taskAddress is! EthereumAddress) {
      throw Exception('Got back invalid task address: $taskAddress');
    }

    var event = web3Client.taskManager
        .task_completedEvents()
        // Time out after 10 seconds
        .timeout(Duration(seconds: 10))
        .firstWhere((event) {
      // Check that it is the right task that was completed!
      return event.task == taskAddress;
    }, orElse: () {
      throw Exception('Could not find correct task in stream');
    });

    var awaitedEvent = await event;

    // Example of valid task in list [2021-08-23T00:00:01Z, 406.9552001953125, 19.77590560913086, 61.5251579284668],
    // This breaks the while loop
    return convertFromBase64(awaitedEvent.data);
  }

  static String createTaskString(
      {required String startTime,
      required String stopTime,
      String? publicKey,
      required String tableName,
      String taskReturnType = 'storj' // TODO
      }) {
    return convertToBase64({
      '_start_time': startTime,
      '_stop_time': stopTime,
      'public_key': publicKey,
      'tableName': tableName,
      'task_return_type': taskReturnType
    });
  }

  static String convertToBase64(Map<String, dynamic> input) {
    // I'm honestly surprised and impressed by how neat this looks in pure dart!
    var jsonString = json.encode(input);
    var utf8List = utf8.encode(jsonString);
    return base64.encode(utf8List);
  }

  static dynamic convertFromBase64(String base64Task) {
    var utf8List = base64.decode(base64Task);
    var jsonString = utf8.decode(utf8List);
    return json.decode(jsonString);
  }
}

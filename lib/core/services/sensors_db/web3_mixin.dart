import 'dart:convert';

import 'package:flutter_iot_ui/core/services/cryptography.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:get_it/get_it.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'sqlite_db.dart' show convertDateTimeToString;

mixin SimpleWeb3DbManager on DatabaseManager {
  // Use the globally exposed web3client, not a separate one.
  Web3 web3Client = GetIt.instance<Web3>();

  Future<String> waitForTaskCompletion(String taskString,
      {Duration timeout = const Duration(seconds: 10)}) async {
    // TODO: don't load all contracts (also loaduser and loadoracle) every time
    await web3Client.loadUser();
    await web3Client.getOraclesForActiveUser();

    var taskAddress = await web3Client.addTask(taskString);
    if (taskAddress is! EthereumAddress) {
      throw Exception('Got back invalid task address: $taskAddress');
    }

    var event = web3Client.taskManager
        .task_completedEvents()
        .timeout(timeout)
        .firstWhere((event) {
      // Check that it is the right task that was completed!
      return event.task == taskAddress;
    }, orElse: () {
      throw Exception('Could not find correct task in stream');
    });

    var awaitedEvent = await event;
    print('got back completed task');

    // Example of valid task in list [2021-08-23T00:00:01Z, 406.9552001953125, 19.77590560913086, 61.5251579284668],
    // This breaks the while loop
    return awaitedEvent.data;
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

  // TODO: check map types, should be Map<String, String>
  Future<List> decryptResult(Map<String, dynamic> jsonData) async {
    EncryptorDecryptor decryptor = GetIt.instance<EncryptorDecryptor>();

    var key = jsonData['key']!;
    var data = jsonData['data']!;

    var decrypted = await decryptor.decryptBoth(key, data);

    var decryptedJsonData = json.decode(decrypted);

    return decryptedJsonData;
  }
}

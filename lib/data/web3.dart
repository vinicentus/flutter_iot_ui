import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_iot_ui/data/svm30_datamodel.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_iot_ui/data/database_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'sqlite.dart' show convertDateTimeToString;

class Web3Manager extends DatabaseManager {
  static final Web3Manager _singleton = Web3Manager._internal();

  factory Web3Manager() {
    return _singleton;
  }

  Web3Manager._internal() {
    // TODO: use websockets
    httpClient = new Client();
  }

  Future<void> init() async {
    String jsonData = await rootBundle.loadString('resources/settings.json');
    Map settings = json.decode(jsonData);

    httpUrl = Uri(
        scheme: 'http',
        host: settings["gateway"]["host"],
        port: settings["gateway"]["port"]);

    _wsUrl = Uri(
        scheme: 'ws',
        host: settings["gateway"]["host"],
        port: settings["gateway"]["wsPort"]);

    ethClient = new Web3Client(
      httpUrl.toString(),
      httpClient,
      // Experimental websocket support
      socketConnector: () => WebSocketChannel.connect(_wsUrl).cast<String>(),
    );

    privateKey = EthPrivateKey.fromHex(settings['keys']['private']);
    // Verify that the public address corresponds to the private key
    // One we are sure of that, we can discard it,
    // since the public address is stored in _privateKey.address anyways
    if (EthereumAddress.fromHex(settings['keys']['public']) !=
        privateKey.address) {
      throw Exception('The private key did not match the public address!');
    }
    chainId = settings['chainId'];

    await _loadContracts();
  }

  late Uri httpUrl;
  late Uri _wsUrl;

  // TODO: check late keyword
  late Client httpClient;
  late Web3Client ethClient;

  late DeployedContract userManager;
  late DeployedContract oracleManager;
  late DeployedContract taskManager;
  late DeployedContract tokenManager;

  late ContractAbi user;
  late ContractAbi oracle;
  late ContractAbi task;

  late DeployedContract deployedUser;
  late Map<String, DeployedContract> deployedOracles;
  late DeployedContract deployedTask;

  /// This is the id of the currently selected device
  late String selectedOracleId;

  late EthPrivateKey privateKey;
  // This should also be the address of the user that created the user contract
  EthereumAddress get publicAddress => privateKey.address;
  late int chainId;

  // Gets the correct contract ABI and address from the json file containing info on all the deployed contracts
  DeployedContract _getDeployedContract(String contractName, String data) {
    var decoded = json.decode(data);
    var abi = json.encode(decoded[contractName]['abi']);
    var address = decoded[contractName]['address'];

    return DeployedContract(ContractAbi.fromJson(abi, contractName),
        EthereumAddress.fromHex(address));
  }

  ContractAbi _getContractABI(String contractName, String data) {
    var decoded = json.decode(data);
    var abi = json.encode(decoded[contractName]['abi']);

    return ContractAbi.fromJson(abi, contractName);
  }

  Future<void> _loadContracts() async {
    String jsonData = await rootBundle.loadString('resources/ABI.json');

    userManager = _getDeployedContract('usermanager', jsonData);
    oracleManager = _getDeployedContract('oraclemanager', jsonData);
    taskManager = _getDeployedContract('taskmanager', jsonData);
    tokenManager = _getDeployedContract('tokenmanager', jsonData);

    // We can't load these as deployed contracts yet,
    // since we don't know what address they have been deployed to
    // before querying info from the manager contracts...
    user = _getContractABI('user', jsonData);
    oracle = _getContractABI('oracle', jsonData);
    task = _getContractABI('task', jsonData);
  }

  Future<bool> checkUserExists() async {
    // Requires the address of the user that has been created...
    var returnList = await ethClient.call(
      contract: userManager,
      function: userManager.function('exists'),
      params: [publicAddress],
    );

    return returnList.first;
  }

  Future<DeployedContract> loadUser() async {
    bool exists = await checkUserExists();

    if (exists) {
      var result = await ethClient.call(
        contract: userManager,
        function: userManager.function('fetch'),
        params: [publicAddress],
      );
      // The returned value should be the address of the User contract
      var address = result.first;
      // We save the the deployed user contract, but also return it
      deployedUser = DeployedContract(user, address);
      return deployedUser;
    } else {
      throw Exception('The user you are trying to load does not exist.');
    }
  }

  // Creates a user registered to the ethereum address used for the transaction
  Future<void> createUser() async {
    bool exists = await checkUserExists();
    if (exists) {
      throw Exception('The user you are trying to create already exists!');
    } else {
      var result = await ethClient.sendTransaction(
          privateKey,
          Transaction.callContract(
            contract: userManager,
            function: userManager.function('create'),
            parameters: [],
          ),
          chainId: chainId);
    }
  }

  /// This needs to be called after loadUser, because it fetches the first oracle registered to the current user
  Future<Map<String, DeployedContract>> loadOracles() async {
    // Fetch all the oracles (devices) that are registered to our user
    var result = await ethClient.call(
      contract: oracleManager,
      function: oracleManager.function('fetch_collection'),
      params: [publicAddress],
    );
    var oracleIds = result.first;

    // This is the id String of the oracle (device).
    // We select the last availabe one as our main device that we will display data from.
    // That should be the last created oracle.
    // In the future, there might not be a single selected device
    selectedOracleId = oracleIds.last;

    deployedOracles = Map<String, DeployedContract>();

    for (String id in oracleIds) {
      var result = await ethClient.call(
        contract: oracleManager,
        function: oracleManager.function('fetch_oracle'),
        params: [id],
      );
      var address = result.first;
      deployedOracles[id] = DeployedContract(oracle, address);
    }

    return deployedOracles;
  }

  /// Adds a task and returns the address of that created task.
  /// This needs to be processed on-chain, and that takes a while.
  Future<EthereumAddress> _addTask(
      {required String startTime,
      required String stopTime,
      String? publicKey,
      required String tableName}) async {
    var taskCreatedEvent = taskManager.event('task_created');

    var theOneEvent = ethClient
        .events(FilterOptions.events(
            contract: taskManager, event: taskCreatedEvent))
        // TODO: don't use first, add retry possibility
        .first;

    // The result will be a transaction hash
    // We don't need to wait for this since we catch the result in the event listener and wait on that
    var txHash = ethClient.sendTransaction(
        privateKey,
        Transaction.callContract(
          contract: taskManager,
          function: taskManager.function('create'),
          parameters: [
            selectedOracleId,
            BigInt.from(2),
            BigInt.from(2),
            convertToBase64({
              '_start_time': startTime,
              '_stop_time': stopTime,
              'public_key': publicKey,
              'tableName': tableName
            }),
          ],
        ),
        chainId: chainId);

    var awaitedEvent = await theOneEvent;
    await txHash;

    if (awaitedEvent.transactionHash != await txHash) {
      throw Exception('Got the incorrect event');
    }

    var taskAddress = taskCreatedEvent
        .decodeResults(awaitedEvent.topics!, awaitedEvent.data!)
        .first;

    var result3 = await ethClient.call(
        contract: taskManager,
        function: taskManager.function('fetch_task'),
        params: [taskAddress]);
    return result3.first;
  }

  // Used to retire COMPLETED tasks
  retireTask() {}

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

  Future<List> geteGenericEntries(
      {required String tableName,
      String? publicKey,
      DateTime? start,
      DateTime? stop}) async {
    // TODO: don't load all contracts (also loaduser and loadoracle) every time
    await init();
    await loadUser();
    await loadOracles();

    var taskAddress = await _addTask(
        // TODO: bad non-null assertion
        startTime: convertDateTimeToString(start!),
        stopTime: convertDateTimeToString(stop!),
        publicKey: publicKey, // TODO
        tableName: tableName);
    if (taskAddress is! EthereumAddress) {
      throw Exception('Got back invalid task address: $taskAddress');
    }

    var taskCompletedEvent = taskManager.event('task_completed');

    var event = ethClient
        .events(FilterOptions.events(
            contract: taskManager, event: taskCompletedEvent))
        // 10 retries
        .take(10)
        .firstWhere((event) {
      // TODO: bad null check
      var decoded =
          taskCompletedEvent.decodeResults(event.topics!, event.data!);
      // Check that it is the right task that was completed!
      return (decoded.first as EthereumAddress) == taskAddress;
    }, orElse: () {
      // TODO: add orelse that return custom error
      throw Exception('Failed to get back completed task');
    });

    var awaitedEvent = await event;

    // TODO: bad null check
    var result = taskCompletedEvent.decodeResults(
        awaitedEvent.topics!, awaitedEvent.data!);

    List taskResult = convertFromBase64(result.last);

    // Example of valid task in list [2021-08-23T00:00:01Z, 406.9552001953125, 19.77590560913086, 61.5251579284668],
    // This breaks the while loop
    return taskResult;
  }

  /// Split interval into smaller chunks that are a maximum of 1 hour long
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
  Stream<List> _getMultipleGenericEntriesAsStream(
      {required String tableName,
      String? publicKey,
      DateTime? start,
      DateTime? stop}) async* {
    // TODO: bad null check
    var timeChunkList = splitIntoSmallTimeIntervals(start!, stop!);

    var intervalCount = timeChunkList.length - 1;

    for (int i = 0; i < intervalCount; i++) {
      print('returning chunk ${i + 1}/$intervalCount');
      yield await geteGenericEntries(
        tableName: tableName,
        publicKey: publicKey,
        start: timeChunkList[i],
        stop: timeChunkList[i + 1],
      );
    }
  }

  Future<List> _getMultipleGenericEntries(
      {required String tableName,
      String? publicKey,
      DateTime? start,
      DateTime? stop}) {
    return _getMultipleGenericEntriesAsStream(
            tableName: tableName,
            publicKey: publicKey,
            start: start,
            stop: stop)
        .fold([], (previous, element) => previous..addAll(element));
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    List taskResult = await _getMultipleGenericEntries(
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
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) async {
    List taskResult = await _getMultipleGenericEntries(
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
    List taskResult = await _getMultipleGenericEntries(
        tableName: 'svm30_output', publicKey: null, start: start, stop: stop);

    var returnList = <SVM30SensorDataEntry>[];
    taskResult.forEach((element) {
      returnList.add(SVM30SensorDataEntry.createFromDB(
          element[0], element[1], element[2]));
    });
    return returnList;
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_iot_ui/data/svm30_datamodel.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_iot_ui/data/database_manager.dart';
import 'sqlite.dart' show convertDateTimeToString;

class Web3Manager extends CachedDatabaseManager
    implements StreamedDatabaseManager {
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

    apiUrl =
        'http://${settings["gateway"]["host"]}:${settings["gateway"]["port"]}';

    ethClient = new Web3Client(apiUrl, httpClient);

    _privateKey = EthPrivateKey.fromHex(settings['keys']['private']);
    publicAddress = EthereumAddress.fromHex(settings['keys']['public']);
    chainId = settings['chainId'];
  }

  late String apiUrl;

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
  late DeployedContract deployedOracle;
  late DeployedContract deployedTask;

  late String _oracleDeviceID;

  late EthPrivateKey _privateKey;
  // This should be the address of the user that created the user contract
  late EthereumAddress publicAddress;
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

  _loadContracts() async {
    String jsonData = await rootBundle.loadString('resources/latest.json');

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
      var result = await ethClient.call(
        contract: userManager,
        function: userManager.function('create'),
        params: [],
      );
    }
  }

  /// This needs to be called after loadUser, because it fetches the first oracle registered to the current user
  Future<DeployedContract> _loadOracle() async {
    // Fetch all the oracles (devices) that are registered to our user
    var result = await ethClient.call(
      contract: oracleManager,
      function: oracleManager.function('fetch_collection'),
      params: [publicAddress],
    );

    // This is the id String of the oracle (device)
    _oracleDeviceID = result.first.first;

    var result2 = await ethClient.call(
      contract: oracleManager,
      function: oracleManager.function('fetch_oracle'),
      params: [_oracleDeviceID],
    );

    deployedOracle = DeployedContract(oracle, result2.first);

    return deployedOracle;
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
        _privateKey,
        Transaction.callContract(
          contract: taskManager,
          function: taskManager.function('create'),
          parameters: [
            _oracleDeviceID,
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
    await _loadContracts();
    await loadUser();
    await _loadOracle();

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
  // TODO: add tests:
  List<DateTime> splitIntoSmallTimeIntervals(DateTime start, DateTime stop) {
    var hourDifference = stop.difference(start).inHours;
    if (hourDifference >= 1) {
      var returnList = <DateTime>[];
      for (int i = 0; i <= hourDifference; i++) {
        returnList.add(start.add(Duration(hours: i)));
      }
      returnList.add(stop);
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

    for (int i = 0; i < timeChunkList.length - 1; i++) {
      print('returning chunk $i');
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

  // Lazy init achieved with late keyword
  // TODO: actively manage what is tored here
  late Set<SCD30SensorDataEntry> _cachedSCD30 = Set<SCD30SensorDataEntry>();
  late Set<SPS30SensorDataEntry> _cachedSPS30 = Set<SPS30SensorDataEntry>();
  late Set<SVM30SensorDataEntry> _cachedSVM30 = Set<SVM30SensorDataEntry>();

  @override
  Set<SCD30SensorDataEntry> get cachedSCD30Entries => _cachedSCD30;

  @override
  Set<SPS30SensorDataEntry> get cachedSPS30Entries => _cachedSPS30;

  @override
  Set<SVM30SensorDataEntry> get cachedSVM30Entries => _cachedSVM30;

  @override
  Future<List<SCD30SensorDataEntry>> getCachedSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    var entries = await getSCD30Entries();
    _cachedSCD30.addAll(entries);
    return entries;
  }

  @override
  Future<List<SPS30SensorDataEntry>> getCachedSPS30Entries(
      {DateTime? start, DateTime? stop}) async {
    var entries = await getSPS30Entries();
    _cachedSPS30.addAll(entries);
    return entries;
  }

  @override
  Future<List<SVM30SensorDataEntry>> getCachedSVM30Entries(
      {DateTime? start, DateTime? stop}) async {
    var entries = await getSVM30Entries();
    _cachedSVM30.addAll(entries);
    return entries;
  }

  @override
  Stream<List<SCD30SensorDataEntry>> getStreamedSCD30Entries(
      {DateTime? start, DateTime? stop}) {
    Stream<List> taskResultStream = _getMultipleGenericEntriesAsStream(
        tableName: 'scd30_output', publicKey: null, start: start, stop: stop);

    return taskResultStream.map((list) {
      // Convert list of list to list of SCD30SensorDataEntry
      return list
          .map((element) => SCD30SensorDataEntry.createFromDB(
              element[0], element[1], element[2], element[3]))
          .toList();
    });
  }

  @override
  Stream<List<SPS30SensorDataEntry>> getStreamedSPS30Entries(
      {DateTime? start, DateTime? stop}) {
    Stream<List> taskResultStream = _getMultipleGenericEntriesAsStream(
        tableName: 'sps30_output', publicKey: null, start: start, stop: stop);

    return taskResultStream.map((list) {
      // Convert list of list to list of SPS30SensorDataEntry
      return list
          .map((element) => SPS30SensorDataEntry.createFromDB(
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
              element[10]))
          .toList();
    });
  }

  @override
  Stream<List<SVM30SensorDataEntry>> getStreamedSVM30Entries(
      {DateTime? start, DateTime? stop}) {
    Stream<List> taskResultStream = _getMultipleGenericEntriesAsStream(
        tableName: 'svm30_output', publicKey: null, start: start, stop: stop);

    return taskResultStream.map((list) {
      // Convert list of list to list of SVM30SensorDataEntry
      return list
          .map((element) => SVM30SensorDataEntry.createFromDB(
              element[0], element[1], element[2]))
          .toList();
    });
  }
}

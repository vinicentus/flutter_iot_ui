import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_iot_ui/data/svm30_datamodel.dart';
import 'package:flutter_iot_ui/data/sps30_datamodel.dart';
import 'package:flutter_iot_ui/data/scd30_datamodel.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_iot_ui/data/database_manager.dart';

class Web3Manager extends DatabaseManager {
  static final Web3Manager _singleton = Web3Manager._internal();

  factory Web3Manager() {
    return _singleton;
  }

  Web3Manager._internal() {
    // TODO: use websockets
    httpClient = new Client();
    ethClient = new Web3Client(apiUrl, httpClient);
  }

  // TODO: load from config file
  // var apiUrl = 'http://${settings["gateway"]["host"]}:${settings["gateway"]["port"]}';
  var apiUrl = "http://localhost:8545";

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

  // This should be the address of the user that created the user contract
  // This is nullable
  EthereumAddress? _userAddress;
  String? _oracleDeviceID;

  // This is a temporary test key! ( TODO: load from file )
  var _privateKey =
      '0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1';

  // TODO: remove
  getBalance() async {
    var credentials = await ethClient.credentialsFromPrivateKey(_privateKey);

    EtherAmount balance = await ethClient.getBalance(credentials.address);
    print(balance.getValueInUnit(EtherUnit.ether));
  }

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

  loadContracts() async {
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

  Future<DeployedContract> loadUser(EthereumAddress userAddress) async {
    _userAddress = userAddress;

    // Requires the address of the user that has been created...
    var returnList = await ethClient.call(
      contract: userManager,
      function: userManager.function('exists'),
      params: [_userAddress],
    );
    bool exists = returnList.first;

    if (exists) {
      var result = await ethClient.call(
        contract: userManager,
        function: userManager.function('fetch'),
        // TODO: remove hardcoded param
        params: [_userAddress],
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

  /// This needs to be called after loadUser, because it fetches the first oracle registered to the current user
  Future<DeployedContract> loadOracle() async {
    // Fetch all the oracles (devices) that are registered to our user
    var result = await ethClient.call(
      contract: oracleManager,
      function: oracleManager.function('fetch_collection'),
      params: [_userAddress],
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
  Future<EthereumAddress> addTask() async {
    Credentials creds = await ethClient.credentialsFromPrivateKey(_privateKey);

    // The result will be a transaction hash
    var result1 = await ethClient.sendTransaction(
        creds,
        Transaction.callContract(
          contract: taskManager,
          function: taskManager.function('create'),
          parameters: [
            // TODO: use function parameter to define these
            _oracleDeviceID,
            BigInt.from(2),
            BigInt.from(2),
            convertToBase64({
              '_start_time': '2021-08-23T00:00:00+00:00',
              '_stop_time': '2021-08-23T01:00:00+00:00',
              'public_key': null,
              'tableName': 'scd30_output'
            }),
          ],
        ));

    // This receipt doesn't seem useful, since the events emitted don't include the address of the created task
    // One has to manually check the list of tasks on the contract after adding one, and hoping that they get the correct address
    // One gets the correct task contract address as long as there is only one client adding tasks for a specific user,
    // One can then simply get the latest task created by that user.
    // If this isn't the case, it might get more complicated...
    // var receipt = await ethClient.getTransactionReceipt(result1);
    // print(receipt);

    // var result2 = await ethClient
    //     .call(contract: taskManager, function: taskManager.function('pending'),
    //         // This apparently gets the first value in the list
    //         params: [userAddress, BigInt.from(0)]);
    // print(result2);

    var result3 = await ethClient.call(
        contract: taskManager,
        function: taskManager.function('fetch_lists'),
        params: [_userAddress]);
    List pendingList = result3.first;
    // List completedList = result3.last;

    // This should be the latest, not yet completed task contract
    return pendingList.last;
  }

  Future<Map<EthereumAddress, String>> fetchCompletedTasks() async {
    var result = await ethClient.call(
        contract: taskManager,
        function: taskManager.function('fetch_lists'),
        params: [_userAddress]);
    // List pendingList = result.first;
    List completedList = result.last;

    var mapped = <EthereumAddress, String>{};
    completedList.forEach((element) {
      var list = element as List;
      mapped[list.first] = list.last;
    });
    return mapped;
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

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop, int numberOfRetrySeconds = 10}) async {
    // TODO: remove hardcoded param
    var address = EthereumAddress.fromHex(
        '0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0',
        enforceEip55: true);
    // TODO: don't load user and oracle every time
    await loadUser(address);
    await loadOracle();
    print('adding task:');
    var taskAddress = await addTask();
    if (taskAddress is! EthereumAddress) {
      throw Exception('Got back invalid task address: $taskAddress');
    }

    var completedTasks = await fetchCompletedTasks();

    //TODO: listen for events here instead
    var retries = 0;
    while (!completedTasks.containsKey(taskAddress) &&
        retries < numberOfRetrySeconds) {
      // TODO: don't sleep, instead just reschedule the future
      sleep(Duration(seconds: 1));
      retries += 1;
      completedTasks = await fetchCompletedTasks();
    }

    // Check if completed now
    if (!completedTasks.containsKey(taskAddress)) {
      throw Exception('Failed to get back completed task after 10 tries');
    }

    // We have already asserted that the taskAddress is an EthereumAddress so we can safely use it here
    // The exclamation mark here is important!
    // It tells dart to convert the String? to a String
    List taskResult = convertFromBase64(completedTasks[taskAddress]!);

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
    // TODO: implement getSPS30Entries
    throw UnimplementedError();
  }

  @override
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) async {
    // TODO: implement getSVM30Entries
    throw UnimplementedError();
  }
}

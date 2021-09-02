import 'dart:convert';
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
    // TODO: Initialize
    httpClient = new Client();
    ethClient = new Web3Client(apiUrl, httpClient);
  }

  // TODO: use websockets
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
  // TODO: remove hardcoded param
  late EthereumAddress userAddress = EthereumAddress.fromHex(
      '0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0',
      enforceEip55: true);
  late String oracleDeviceID;

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
    print(address);

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
    // Requires the address of the user that has been created...
    var returnList = await ethClient.call(
      contract: userManager,
      function: userManager.function('exists'),
      params: [userAddress],
    );
    bool exists = returnList.first;

    if (exists) {
      var result = await ethClient.call(
        contract: userManager,
        function: userManager.function('fetch'),
        // TODO: remove hardcoded param
        params: [userAddress],
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
      params: [userAddress],
    );

    // This is the id String of the oracle (device)
    oracleDeviceID = result.first.first;

    var result2 = await ethClient.call(
      contract: oracleManager,
      function: oracleManager.function('fetch_oracle'),
      params: [oracleDeviceID],
    );

    deployedOracle = DeployedContract(oracle, result2.first);

    return deployedOracle;
  }

  // Map<String, dynamic> taskMap
  Future<dynamic> addTask() async {
    Credentials creds = await ethClient.credentialsFromPrivateKey(_privateKey);

    var result1 = ethClient.sendTransaction(
        creds,
        Transaction.callContract(
          contract: taskManager,
          function: taskManager.function('create'),
          parameters: [
            // TODO: use function parameter to define these
            oracleDeviceID,
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

    return result1;
  }

  String convertToBase64(Map<String, dynamic> input) {
    // I'm honestly surprised and impressed by how neat this looks in pure dart!
    var jsonString = json.encode(input);
    var utf8List = utf8.encode(jsonString);
    return base64.encode(utf8List);
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) async {
    await loadUser(userAddress);
    await loadOracle();
    await addTask();

    // TODO: implement getSCD30Entries
    throw UnimplementedError();
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

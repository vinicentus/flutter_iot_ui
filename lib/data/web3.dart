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

  var userManager;
  var oracleManager;
  var taskManager;
  var tokenManager;

  var user;
  var oracle;
  var task;

  // This is a temporary test key! ( TODO: remove )
  var _privateKey =
      '0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1';

  getBalance() async {
    var credentials = await ethClient.credentialsFromPrivateKey(_privateKey);

    EtherAmount balance = await ethClient.getBalance(credentials.address);
    print(balance.getValueInUnit(EtherUnit.ether));
  }

  // Gets the correct contract ABI from the json file containg all the ABis
  String _chooseContract(String contractName, String data) {
    var decoded = json.decode(data);
    return json.encode(decoded[contractName]['abi']);
  }

  loadContracts() async {
    String jsonData = await rootBundle.loadString('resources/latest.json');

    // TODO: check how to get the correct address where each contract is delpyed
    userManager = ContractAbi.fromJson(
        _chooseContract('usermanager', jsonData), 'usermanager');
    oracleManager = ContractAbi.fromJson(
        _chooseContract('oraclemanager', jsonData), 'oraclemanager');
    taskManager = ContractAbi.fromJson(
        _chooseContract('taskmanager', jsonData), 'taskmanager');
    tokenManager = ContractAbi.fromJson(
        _chooseContract('tokenmanager', jsonData), 'tokenmanager');

    user = ContractAbi.fromJson(_chooseContract('user', jsonData), 'user');
    oracle =
        ContractAbi.fromJson(_chooseContract('oracle', jsonData), 'oracle');
    task = ContractAbi.fromJson(_chooseContract('task', jsonData), 'task');
  }

  @override
  Future<List<SCD30SensorDataEntry>> getSCD30Entries(
      {DateTime? start, DateTime? stop}) {
    // TODO: implement getSCD30Entries
    throw UnimplementedError();
  }

  @override
  Future<List<SPS30SensorDataEntry>> getSPS30Entries(
      {DateTime? start, DateTime? stop}) {
    // TODO: implement getSPS30Entries
    throw UnimplementedError();
  }

  @override
  Future<List<SVM30SensorDataEntry>> getSVM30Entries(
      {DateTime? start, DateTime? stop}) {
    // TODO: implement getSVM30Entries
    throw UnimplementedError();
  }
}

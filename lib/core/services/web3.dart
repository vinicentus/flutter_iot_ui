import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_iot_ui/core/models/contracts/Oracle.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/OracleManager.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/Task.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/TaskManager.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/TokenManager.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/User.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/UserManager.g.dart';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Web3 {
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
      Client(),
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

  late Web3Client ethClient;

  late UserManager userManager;
  late OracleManager oracleManager;
  late TaskManager taskManager;
  late TokenManager tokenManager;

  late User deployedUser;
  late Map<JsonId, Oracle> deployedOracles;
  late Task deployedTask;

  /// This is the id of the currently selected device
  JsonId? selectedOracleId;

  late EthPrivateKey privateKey;
  // This should also be the address of the user that created the user contract
  EthereumAddress get publicAddress => privateKey.address;

  late int chainId;

  EthereumAddress _getContractAddress(String contractName, String data) {
    var decoded = json.decode(data);
    var address = decoded[contractName]['address'];

    return EthereumAddress.fromHex(address);
  }

  Future<void> _loadContracts() async {
    String jsonData = await rootBundle.loadString('resources/ABI.json');
    userManager = UserManager(
      address: _getContractAddress('usermanager', jsonData),
      client: ethClient,
      chainId: chainId,
    );
    oracleManager = OracleManager(
      address: _getContractAddress('oraclemanager', jsonData),
      client: ethClient,
      chainId: chainId,
    );
    taskManager = TaskManager(
      address: _getContractAddress('taskmanager', jsonData),
      client: ethClient,
      chainId: chainId,
    );
    tokenManager = TokenManager(
      address: _getContractAddress('tokenmanager', jsonData),
      client: ethClient,
      chainId: chainId,
    );

    // We can't load the other contracts yet,
    // since we don't know what address they have been deployed to
    // before querying info from the manager contracts...
  }

  Future<bool> checkUserExists() async {
    // Requires the address of the user that has been created...
    return userManager.exists(publicAddress);
  }

  Future<User> loadUser() async {
    // TODO: don't check this because the node checks it, as written in contract function, upon call
    bool exists = await checkUserExists();

    if (exists) {
      var address = await userManager.fetch(publicAddress);
      deployedUser =
          User(address: address, client: ethClient, chainId: chainId);
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
      await userManager.create(credentials: privateKey);
    }
  }

  /// The uniqe id is sotred in the oracle(device) contract.
  /// The price is the minimum required price in ERC-20 tokens required to run a task on this device.
  Future<void> createOracle(String uniqueId, int price) async {
    await oracleManager.create(uniqueId, BigInt.from(price),
        credentials: privateKey);
  }

  /// This needs to be called after loadUser, because it fetches all oracles registered to the current user
  Future<Map<JsonId, Oracle>> loadOraclesForActiveUser() async {
    // Fetch all the oracles (devices) that are registered to our user

    var oracleIds = await oracleManager.fetch_collection(publicAddress);

    // This is the id String of the oracle (device).
    // We select the last availabe one as our main device that we will display data from.
    // That should be the last created oracle.
    // In the future, there might not be a single selected device
    // If there is already as selected device, won won't override it.
    if (selectedOracleId == null) selectedOracleId = JsonId(oracleIds.last);

    deployedOracles = Map<JsonId, Oracle>();

    for (String id in oracleIds) {
      var address = await oracleManager.fetch_oracle(id);
      var jsonId = JsonId(id);
      deployedOracles[jsonId] =
          Oracle(address: address, client: ethClient, chainId: chainId);
    }

    return deployedOracles;
  }

  /// Adds a task and returns the address of that created task.
  /// This needs to be processed on-chain, and that takes a while.
  Future<EthereumAddress> addTask(String params) async {
    if (selectedOracleId == null) {
      throw Exception(
          'Can\'t create a task without selecting a oracle on which to create it first.');
    }

    var taskCreatedEvent = taskManager.self.event('task_created');

    var theOneEvent = ethClient
        .events(FilterOptions.events(
            contract: taskManager.self, event: taskCreatedEvent))
        // TODO: don't use first, add retry possibility
        .first;

    // The result will be a transaction hash
    // We don't need to wait for this since we catch the result in the event listener and wait on that
    var txHash = taskManager.create(
        selectedOracleId!.id, BigInt.from(2), BigInt.from(2), params,
        credentials: privateKey);

    var awaitedEvent = await theOneEvent;
    await txHash;

    if (awaitedEvent.transactionHash != await txHash) {
      throw Exception('Got the incorrect event');
    }

    var taskAddress = taskCreatedEvent
        .decodeResults(awaitedEvent.topics!, awaitedEvent.data!)
        .first;

    var result3 = await taskManager.fetch_task(taskAddress);
    return result3;
  }

  // Used to retire COMPLETED tasks
  retireTask() {
    throw UnimplementedError();
  }

  /// Returns the eth balance for the current user.
  /// Value is in ether by default,
  /// but you can specifya different unit such as gwei or wei.
  Future<num> getUserBalance({EtherUnit unit = EtherUnit.ether}) async {
    return (await ethClient.getBalance(publicAddress)).getValueInUnit(unit);
  }

  /// Special method needed because we need to include the required eth in the transaction
  Future<void> purchaseTokens(BigInt amount) async {
    var price = await tokenManager.price();
    var requiredTokens = price * amount;

    await tokenManager.purchase(
      amount,
      credentials: privateKey,
      transaction: Transaction(
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, requiredTokens),
      ),
    );
  }
}

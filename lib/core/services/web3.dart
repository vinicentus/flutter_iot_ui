import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_iot_ui/core/models/contracts/Oracle.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/OracleManager.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/TaskManager.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/TokenManager.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/User.g.dart';
import 'package:flutter_iot_ui/core/models/contracts/UserManager.g.dart';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:flutter_iot_ui/core/services/selected_devices_model.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Web3 {
  /// This is essentilay equvalent to a Facatory constructor that returns a Future<Web3>.
  /// But dart doesn't support such things, so this is probably the closest thing to that (but still quite neat).
  static Future<Web3> createAsync() async {
    final web3 = Web3();
    web3._loadClientsAndKeys();
    await web3._loadContracts();

    return web3;
  }

  /// Load necessary configuration from file, and set up all late fields.
  /// Only to be used on init.
  Future<void> _loadClientsAndKeys() async {
    String jsonData = await rootBundle.loadString('resources/settings.json');
    Map settings = json.decode(jsonData);

    httpUrl = Uri(
        scheme: 'http',
        host: settings["gateway"]["host"],
        port: settings["gateway"]["port"]);

    wsUrl = Uri(
        scheme: 'ws',
        host: settings["gateway"]["host"],
        port: settings["gateway"]["wsPort"]);

    ethClient = new Web3Client(
      httpUrl.toString(),
      Client(),
      // Experimental websocket support
      socketConnector: () => WebSocketChannel.connect(wsUrl).cast<String>(),
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
  }

  /// Load contracts addresses from file and init late contract variables.
  /// Only to be used on init.
  Future<void> _loadContracts() async {
    userManager = UserManager(
      address: await _getContractAddress('UserManager.abi.json'),
      client: ethClient,
      chainId: chainId,
    );
    oracleManager = OracleManager(
      address: await _getContractAddress('OracleManager.abi.json'),
      client: ethClient,
      chainId: chainId,
    );
    taskManager = TaskManager(
      address: await _getContractAddress('TaskManager.abi.json'),
      client: ethClient,
      chainId: chainId,
    );
    tokenManager = TokenManager(
      address: await _getContractAddress('TokenManager.abi.json'),
      client: ethClient,
      chainId: chainId,
    );

    // We can't load the other contracts yet,
    // since we don't know what address they have been deployed to
    // before querying info from the manager contracts...
    // That is left up to the user.
  }

  /// This should only be used on init.
  Future<EthereumAddress> _getContractAddress(String contractName) async {
    String jsonData =
        await rootBundle.loadString('lib/core/models/contracts/$contractName');
    var decoded = json.decode(jsonData);
    var address = decoded['networks'][chainId.toString()]['address'];
    // var abi = decoded['abi'];

    return EthereumAddress.fromHex(address);
  }

  late final Uri httpUrl;
  late final Uri wsUrl;

  late final Web3Client ethClient;

  late final EthPrivateKey privateKey;
  // This should also be the address of the user that created the user contract
  EthereumAddress get publicAddress => privateKey.address;

  late final int chainId;

  late final UserManager userManager;
  late final OracleManager oracleManager;
  late final TaskManager taskManager;
  late final TokenManager tokenManager;

  Future<bool> checkUserExists() async {
    return userManager.exists(publicAddress);
  }

  Future<User> loadUser() async {
    var address = await userManager.fetch(publicAddress);
    return User(address: address, client: ethClient, chainId: chainId);
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
  Future<Map<JsonId, Oracle>> getOraclesForActiveUser() async {
    // Fetch all the oracles (devices) that are registered to our user

    var oracleIds = await oracleManager.fetch_collection(publicAddress);

    var deployedOracles = Map<JsonId, Oracle>();

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
  // TODO: make it an extension metod on Oracle class?
  Future<EthereumAddress> addTask(String params) async {
    var selectedDevicesModel = GetIt.instance<SelectedDevicesModel>();

    if (selectedDevicesModel.selectedOracleId == null) {
      throw Exception(
          'Can\'t create a task without selecting a oracle on which to create it first.');
    }

    var taskCreatedEvent = taskManager.self.event('task_created');

    var eventStream = ethClient
        .events(FilterOptions.events(
            contract: taskManager.self, event: taskCreatedEvent))
        // Time out stream if after 10 seconds
        // (meaning we have 10 seconds to get the right event before stream is canceled)
        .timeout(Duration(seconds: 10));

    // The result will be a transaction hash
    // We don't need to wait for this since we catch the result in the event listener and wait on that
    var txHash = taskManager.create(selectedDevicesModel.selectedOracleId!.id,
        BigInt.from(2), BigInt.from(2), params,
        credentials: privateKey);

    // The stream is canceled when the loop exits
    await for (FilterEvent event in eventStream) {
      if (event.transactionHash == await txHash) {
        print('yay');
        var taskAddress =
            taskCreatedEvent.decodeResults(event.topics!, event.data!).first;

        return await taskManager.fetch_task(taskAddress);
      } else {
        print('nope');
      }
    }

    // If the loop was exited without returning
    // (i.e if the stream was canceled, but not if it completed with an error)
    throw Exception('Could not get the correct event');
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

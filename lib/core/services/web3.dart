import 'dart:convert';
import 'package:flutter/services.dart';
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
  String? selectedOracleId;

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
      await ethClient.sendTransaction(
          privateKey,
          Transaction.callContract(
            contract: userManager,
            function: userManager.function('create'),
            parameters: [],
          ),
          chainId: chainId);
    }
  }

  /// The uniqe id is sotred in the oracle(device) contract.
  /// The price is the minimum required price in ERC-20 tokens required to run a task on this device.
  Future<void> createOracle(String uniqueId, int price) async {
    await ethClient.sendTransaction(
      privateKey,
      Transaction.callContract(
        contract: oracleManager,
        function: oracleManager.function('create'),
        parameters: [uniqueId, BigInt.from(price)],
      ),
      chainId: chainId,
    );
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
    // If there is already as selected device, won won't override it.
    if (selectedOracleId == null) selectedOracleId = oracleIds.last;

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
  Future<EthereumAddress> addTask(String params) async {
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
            params,
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
  retireTask() {
    throw UnimplementedError();
  }

  /// Call a function of a contract that modifies blockchain state,
  /// using the already loaded parameters (private key and chainID).
  Future<String> callWriteFunction(
      DeployedContract contract, String function, List<dynamic> parameters) {
    return ethClient.sendTransaction(
      privateKey,
      Transaction.callContract(
        contract: contract,
        function: contract.function(function),
        parameters: [],
      ),
      chainId: chainId,
    );
  }

  Future<List<dynamic>> callReadFunction(
      DeployedContract contract, String function, List<dynamic> parameters) {
    return ethClient.call(
        contract: contract,
        function: contract.function(function),
        params: parameters);
  }
}

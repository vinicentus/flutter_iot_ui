// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
    '[{"anonymous":false,"inputs":[],"name":"modification","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"task","type":"address"},{"indexed":false,"internalType":"string","name":"data","type":"string"}],"name":"task_completed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"task","type":"address"}],"name":"task_created","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"task","type":"address"}],"name":"task_retired","type":"event"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"completed","outputs":[{"internalType":"address","name":"task","type":"address"},{"internalType":"string","name":"data","type":"string"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[],"name":"fee","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[],"name":"initialized","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[],"name":"oracle_manager","outputs":[{"internalType":"contract OracleManager","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"pending","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"tasks","outputs":[{"internalType":"contract Task","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[],"name":"token_manager","outputs":[{"internalType":"contract TokenManager","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[],"name":"user_manager","outputs":[{"internalType":"contract UserManager","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"address","name":"task","type":"address"}],"name":"fetch_task","outputs":[{"internalType":"contract Task","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"fetch_lists","outputs":[{"internalType":"address[]","name":"","type":"address[]"},{"components":[{"internalType":"address","name":"task","type":"address"},{"internalType":"string","name":"data","type":"string"}],"internalType":"struct TaskManager.result[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"string","name":"_oracle","type":"string"},{"internalType":"uint256","name":"_reward","type":"uint256"},{"internalType":"uint256","name":"_timelimit","type":"uint256"},{"internalType":"string","name":"_params","type":"string"}],"name":"create","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_task","type":"address"},{"internalType":"string","name":"_data","type":"string"}],"name":"complete","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_task","type":"address"}],"name":"retire","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_fee","type":"uint256"},{"internalType":"address","name":"_user_manager","type":"address"},{"internalType":"address","name":"_oracle_manager","type":"address"},{"internalType":"address","name":"_token_manager","type":"address"}],"name":"init","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_task","type":"address"}],"name":"exists","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true}]',
    'TaskManager');

class TaskManager extends _i1.GeneratedContract {
  TaskManager(
      {required _i1.EthereumAddress address,
      required _i1.Web3Client client,
      int? chainId})
      : super(_i1.DeployedContract(_contractAbi, address), client, chainId);

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<Completed> completed(_i1.EthereumAddress $param0, BigInt $param1,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, 'aa995c2c'));
    final params = [$param0, $param1];
    final response = await read(function, params, atBlock);
    return Completed(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> fee({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, 'ddca3f43'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> initialized({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '158ef93e'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> oracle_manager({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, '590be822'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> pending(
      _i1.EthereumAddress $param2, BigInt $param3,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, '15167c03'));
    final params = [$param2, $param3];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> tasks(_i1.EthereumAddress $param4,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '77c237fd'));
    final params = [$param4];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> token_manager({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, '19a42663'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> user_manager({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '9eeb67c4'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> fetch_task(_i1.EthereumAddress task,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, 'f772282c'));
    final params = [task];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<Fetch_lists> fetch_lists(_i1.EthereumAddress user,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, '950a5545'));
    final params = [user];
    final response = await read(function, params, atBlock);
    return Fetch_lists(response);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> create(
      String _oracle, BigInt _reward, BigInt _timelimit, String _params,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, '5a886d79'));
    final params = [_oracle, _reward, _timelimit, _params];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> complete(_i1.EthereumAddress _task, String _data,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, 'd8b2532a'));
    final params = [_task, _data];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> retire(_i1.EthereumAddress _task,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, '9e6371ba'));
    final params = [_task];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> init(BigInt _fee, _i1.EthereumAddress _user_manager,
      _i1.EthereumAddress _oracle_manager, _i1.EthereumAddress _token_manager,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, 'dc890da9'));
    final params = [_fee, _user_manager, _oracle_manager, _token_manager];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> exists(_i1.EthereumAddress _task,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, 'f6a3d24e'));
    final params = [_task];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// Returns a live stream of all modification events emitted by this contract.
  Stream<modification> modificationEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('modification');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return modification(decoded);
    });
  }

  /// Returns a live stream of all task_completed events emitted by this contract.
  Stream<task_completed> task_completedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('task_completed');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return task_completed(decoded);
    });
  }

  /// Returns a live stream of all task_created events emitted by this contract.
  Stream<task_created> task_createdEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('task_created');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return task_created(decoded);
    });
  }

  /// Returns a live stream of all task_retired events emitted by this contract.
  Stream<task_retired> task_retiredEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('task_retired');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return task_retired(decoded);
    });
  }
}

class Completed {
  Completed(List<dynamic> response)
      : task = (response[0] as _i1.EthereumAddress),
        data = (response[1] as String);

  final _i1.EthereumAddress task;

  final String data;
}

class Fetch_lists {
  Fetch_lists(List<dynamic> response)
      : var1 = (response[0] as List<dynamic>).cast<_i1.EthereumAddress>(),
        var2 = (response[1] as List<dynamic>).cast<dynamic>();

  final List<_i1.EthereumAddress> var1;

  final List<dynamic> var2;
}

class modification {
  modification(List<dynamic> response);
}

class task_completed {
  task_completed(List<dynamic> response)
      : task = (response[0] as _i1.EthereumAddress),
        data = (response[1] as String);

  final _i1.EthereumAddress task;

  final String data;
}

class task_created {
  task_created(List<dynamic> response)
      : task = (response[0] as _i1.EthereumAddress);

  final _i1.EthereumAddress task;
}

class task_retired {
  task_retired(List<dynamic> response)
      : task = (response[0] as _i1.EthereumAddress);

  final _i1.EthereumAddress task;
}

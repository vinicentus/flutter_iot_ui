import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/core/models/contracts/TokenManager.g.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:flutter_iot_ui/core/util/view_state_enum.dart';
import 'package:get_it/get_it.dart';
import 'package:web3dart/web3dart.dart';

class TokenManagerPageModel extends ChangeNotifier {
  final _web3 = GetIt.instance<Web3>();
  late final TokenManager _manager;

  ViewState viewState = ViewState.ready;

  // TODO: figure out a way to list all users and their respective balances
  // late Map<EthereumAddress, int> tokensPerUser;
  late String symbol;
  late int price;
  late int capacity;
  late int sold;
  late final bool initialized;
  late final EthereumAddress taskManager;

  init() async {
    viewState = ViewState.loading;

    // Make sure web3 is initialized and then fetch the tokenManager
    await _web3.init();
    _manager = _web3.tokenManager;

    symbol = await _manager.symbol();
    price = (await _manager.price()).toInt();
    capacity = (await _manager.capacity()).toInt();
    sold = (await _manager.sold()).toInt();
    initialized = await _manager.initialized();
    taskManager = await _manager.task_manager();
    viewState = ViewState.ready;
    notifyListeners();
  }
}

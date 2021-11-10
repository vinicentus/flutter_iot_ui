import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/core/models/contracts/TokenManager.g.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:flutter_iot_ui/core/util/view_state_enum.dart';
import 'package:get_it/get_it.dart';
import 'package:web3dart/web3dart.dart';

class TokenManagerPageModel extends ChangeNotifier {
  final _web3 = GetIt.instance<Web3>();
  late TokenManager _manager;

  ViewState viewState = ViewState.ready;

  // TODO: figure out a way to list all users and their respective balances
  // late Map<EthereumAddress, int> tokensPerUser;
  late String symbol;

  /// The unit is wei.
  late int price;
  late int capacity;
  late int sold;
  late bool initialized;
  late EthereumAddress taskManager;
  late num currentUserBalance;

  init() async {
    viewState = ViewState.loading;

    _manager = _web3.tokenManager;

    symbol = await _manager.symbol();
    price = (await _manager.price()).toInt();
    capacity = (await _manager.capacity()).toInt();
    sold = (await _manager.sold()).toInt();
    initialized = await _manager.initialized();
    taskManager = await _manager.task_manager();

    currentUserBalance = await _web3.getUserBalance(unit: EtherUnit.wei);

    viewState = ViewState.ready;
    notifyListeners();
  }

  purchaseTokens(String amount) async {
    // We don't expect to get a value that can not be parsed, since we validate the form input...
    var bigInt = BigInt.parse(amount);
    await _web3.purchaseTokens(bigInt);

    // Fetch new values
    init();
    notifyListeners();
  }

  /// Returns the price in wei.
  String calculatePurchasePrice(String amount) {
    return ((int.tryParse(amount) ?? 0) * price).toString();
  }

  String computeMaxPurchaseableAMount() {
    return (currentUserBalance / price).floor().toString();
  }
}

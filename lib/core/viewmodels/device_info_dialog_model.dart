import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/core/models/contracts/Oracle.g.dart';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:flutter_iot_ui/core/util/view_state_enum.dart';
import 'package:get_it/get_it.dart';
import 'package:web3dart/web3dart.dart';

class DeviceInfoDialogModel extends ChangeNotifier {
  final Oracle _device;
  late final JsonId _jsonId;
  var _web3 = GetIt.instance<Web3>();

  ViewState dataState = ViewState.loading;

  DeviceInfoDialogModel(this._device, JsonId id) : _jsonId = id;

  init() async {
    _active = await _device.active();
    _backlog = await _device.fetch_backlog();
    _price = (await _device.price()).toInt();
    _taskManager = await _device.task_manager();
    _owner = await _device.owner();
    _completed = (await _device.completed()).toInt();

    dataState = ViewState.ready;
    notifyListeners();
  }

  JsonId get jsonId => _jsonId;

  late bool _active;

  bool get active => _active;

  toggleActive() async {
    await _device.toggle_active(credentials: _web3.privateKey);
    _active = await _device.active();
    notifyListeners();
  }

  late List<EthereumAddress> _backlog;

  List<EthereumAddress> get backlog => _backlog;

  late int _price;

  int get price => _price;

  late EthereumAddress _taskManager;

  EthereumAddress get manager => _taskManager;

  late EthereumAddress _owner;

  EthereumAddress get owner => _owner;

  late int _completed;

  int get completed => _completed;
}

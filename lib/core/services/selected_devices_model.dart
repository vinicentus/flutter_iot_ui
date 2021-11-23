import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:get_it/get_it.dart';

class SelectedDevicesModel {
  /// The id of the currently selected device.
  /// There are numerous cases where this will be null,
  /// such as when no user is loaded, or when there are no oracles for that user.
  JsonId? selectedOracleId;

  /// This is set if a local config file was found and loaded.
  JsonId? localOracleId;

  loadLocalID() async {
    // TODO
    localOracleId =
        JsonId('{"name":"RaspberryPiNew","sensors":["scd41"],"uniqueId":"1"}');
  }

  Future<JsonId?> loadRemoteID() async {
    var _web3 = GetIt.instance<Web3>();

    if (await _web3.checkUserExists()) {
      var availableOracles = await _web3.getOraclesForActiveUser();
      // We select the last availabe one as our main device that we will display data from.
      // That should be the last created oracle.
      // In the future, there might not be a single selected device
      // If there is already as selected device, we won't override it.
      if (availableOracles.isNotEmpty && selectedOracleId == null) {
        selectedOracleId = availableOracles.keys.last;
      }
    }
    return selectedOracleId;
  }
}

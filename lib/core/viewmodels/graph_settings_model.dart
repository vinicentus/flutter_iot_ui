import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/core/services/selected_devices_model.dart';
import 'package:get_it/get_it.dart';

class GraphSettingsModel extends ChangeNotifier {
  var _devicesModel = GetIt.instance<SelectedDevicesModel>();

  /// Wether to subtract the smaller size values from the larger ones,
  /// so that the range of the bigger particle size measurements doesn't include the range of the smaller ones...
  bool subtractParticleSizes = true;

  setSubtractParticleSizes(bool value) {
    this.subtractParticleSizes = value;
    notifyListeners();
  }

  /// Wether to enable moving average on all graphs.
  bool useMovingAverage = false;

  setUseMovingAverage(bool value) {
    this.useMovingAverage = value;
    notifyListeners();
  }

  /// The number of samples used per moving average sample,
  /// if moving average is enabled.
  int movingAverageSamples = 10;

  setMovingAverageSamples(double value) {
    movingAverageSamples = value.toInt();
    notifyListeners();
  }

  /// This sets how often the UI gets new data to display.
  Duration graphRefreshTime = Duration(seconds: 60);

  setGraphRefreshimeSeconds(double value) {
    graphRefreshTime = Duration(seconds: value.toInt());
    notifyListeners();
  }

  /// Specifies which time interval to show data from in graphs.
  Duration graphTimeWindow = Duration(hours: 3);

  setGraphTimeWindowHours(double value) {
    graphTimeWindow = Duration(hours: value.toInt());
    notifyListeners();
  }

  bool _usesWeb3 = true;

  bool usesWeb3() {
    return _usesWeb3;
  }

  setUsesWeb3(bool value) async {
    if (value) {
      await _devicesModel.loadLocalID();
    }
    _usesWeb3 = value;
    notifyListeners();
  }

  bool _usesSQLite = true;

  bool usesSqLite() {
    return _usesSQLite;
  }

  setUsesSqLite(bool value) async {
    if (value) {
      await _devicesModel.loadRemoteID();
    }
    _usesSQLite = value;
    notifyListeners();
  }

  bool _usesStorj = true;

  bool usesStorj() => _usesStorj;

  setUsesStorj(bool value) {
    // TODO: load different db object from getit
    _usesStorj = value;
    notifyListeners();
  }

  bool _usesEncryption = true;

  bool usesEncryption() => _usesEncryption;

  setUsesEncryption(bool value) {
    _usesEncryption = value;
    notifyListeners();
  }
}

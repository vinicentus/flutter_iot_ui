import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/data/settings_constants.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/data/web3.dart';

class GraphSettingsModel extends ChangeNotifier {
  /// Wether to subtract the smaller size values from the bigger ones,
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

  setGraphRefreshime(double value) {
    graphRefreshTime = Duration(seconds: value.toInt());
    notifyListeners();
  }

  /// Specifies which time interval to show data from in graphs.
  Duration graphTimeWindow = Duration(hours: 3);

  bool usesWeb3() {
    switch (globalDBManager.runtimeType) {
      case Web3Manager:
        return true;
      default:
        return false;
    }
  }

  setUsesWeb3(bool value) {
    if (value)
      globalDBManager = Web3Manager();
    else
      globalDBManager = SQLiteDatabaseManager();
    notifyListeners();
  }
}

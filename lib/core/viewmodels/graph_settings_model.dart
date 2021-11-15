import 'package:flutter/foundation.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/sqlite_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_db.dart';
import 'package:get_it/get_it.dart';

class GraphSettingsModel extends ChangeNotifier {
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

  bool usesWeb3() {
    var db = GetIt.instance<DatabaseManager>();
    switch (db.runtimeType) {
      case Web3Manager:
        return true;
      default:
        return false;
    }
  }

  setUsesWeb3(bool value) {
    var getIt = GetIt.instance;
    // Overwrite previous registration
    if (value)
      getIt.registerSingleton<DatabaseManager>(Web3Manager());
    else
      getIt.registerSingleton<DatabaseManager>(SQLiteDatabaseManager());
    notifyListeners();
  }
}

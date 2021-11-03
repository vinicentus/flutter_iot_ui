import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_db.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:get_it/get_it.dart';

void registerGetItServices() {
  // This is a singleton, we don't need a global varibale
  GetIt getIt = GetIt.instance;

  getIt.registerSingleton<Web3>(Web3());
  // TODO: maybe make it lazy
  getIt.registerSingleton<DatabaseManager>(Web3Manager());

  // Make sure that we can re-register the DatabaseManager with a different type of extending Manager
  getIt.allowReassignment = true;
}

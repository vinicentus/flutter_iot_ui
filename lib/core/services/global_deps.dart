import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_db.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:get_it/get_it.dart';

void registerGetItServices() {
  // This is a singleton, we don't need a global varibale
  GetIt getIt = GetIt.instance;

  getIt.registerSingletonAsync<Web3>(Web3.createAsync);
  getIt.registerSingletonWithDependencies<DatabaseManager>(() => Web3Manager(),
      dependsOn: [Web3]);

  // Make sure that we can re-register the DatabaseManager with a different type of extending Manager
  getIt.allowReassignment = true;
}

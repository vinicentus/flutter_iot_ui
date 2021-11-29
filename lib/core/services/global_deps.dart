import 'package:flutter_iot_ui/core/services/sensors_db/sqlite_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/storj_web3_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_db.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:flutter_iot_ui/core/services/selected_devices_model.dart';
import 'package:get_it/get_it.dart';

void registerGetItServices() {
  // This is a singleton, we don't need a global varibale
  GetIt getIt = GetIt.instance;

  getIt.registerSingletonAsync<Web3>(Web3.createAsync);

  getIt.registerSingletonWithDependencies(() => SelectedDevicesModel(),
      dependsOn: [Web3]);

  getIt.registerSingletonWithDependencies<Web3Manager>(() => Web3Manager(),
      dependsOn: [Web3]);
  // TODO: change back to SQLiteDatabaseManager
  getIt.registerSingleton<SQLiteDatabaseManager>(StorjSQLiteWeb3DbManager());
}

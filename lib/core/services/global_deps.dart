import 'package:flutter_iot_ui/core/services/sensors_db/sqlite_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/storj_web3_sqlite_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web_chunks_db.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:flutter_iot_ui/core/services/selected_devices_model.dart';
import 'package:get_it/get_it.dart';

void registerGetItServices() {
  // This is a singleton, we don't need a global varibale
  GetIt getIt = GetIt.instance;

  getIt.registerSingletonAsync<Web3>(Web3.createAsync);

  getIt.registerSingletonWithDependencies(() => SelectedDevicesModel(),
      dependsOn: [Web3]);

  getIt.registerSingletonWithDependencies<Web3ChunkDbManager>(
      () => Web3ChunkDbManager(),
      dependsOn: [Web3]);
  getIt.registerSingletonWithDependencies<StorjSQLiteWeb3DbManager>(
      () => StorjSQLiteWeb3DbManager(),
      dependsOn: [Web3]);
  getIt.registerSingleton<SQLiteDatabaseManager>(SQLiteDatabaseManager());
}

// This is bad!
// We should use a service injector such as GetIt instead

import 'package:flutter_iot_ui/core/services/sensors_db/abstract_db.dart';
import 'package:flutter_iot_ui/core/services/sensors_db/web3_db.dart';

DatabaseManager globalDBManager = Web3Manager();

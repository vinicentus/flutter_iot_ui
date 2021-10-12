// This is bad!
// We should have a datastore such as BLOC instead
import 'package:flutter_iot_ui/data/database_manager.dart';
import 'package:flutter_iot_ui/data/web3.dart';

bool useMovingAverage = false;
bool subtractParticleSizes = true;
// The default manager is SQL for now, the current value can be changed in settings
DatabaseManager globalDBManager = Web3Manager();
int numberOfSamplesPerMovingAverageWindow = 10;

/// This sets how often the UI gets new data to display.
int numberOfSecondsBetweenGraphRefresh = 60;

/// Specifies which time interval to show data from in graphs.
Duration defaultTimeWindow = Duration(hours: 3);

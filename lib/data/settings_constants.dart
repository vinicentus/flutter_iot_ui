// This is bad!
// We should have a datastore such as BLOC instead
import 'package:flutter_iot_ui/data/database_manager.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';

bool useMovingAverage = false;
bool subtractParticleSizes = true;
// The default manager is SQL for now, the current value can be changed in settings
DatabaseManager globalDBManager = SQLiteDatabaseManager();
int numberOfSamplesPerMovingAverageWindow = 10;
// This sets how often the UI gets new data to display
int numberOfSecondsBetweenGraphRefresh = 20;

/// This class is mostly used to get a common type for all the classes that extend it.
abstract class GenericSensorDataEntry {
  // The timestamp param is the only thing every sensor data entry class will have in common.
  final DateTime timeStamp;

  GenericSensorDataEntry.createFromDB(this.timeStamp);
}

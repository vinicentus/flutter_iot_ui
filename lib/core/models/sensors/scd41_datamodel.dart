import 'package:flutter_iot_ui/core/models/sensors/scdxx_generic_datamodel.dart';

class SCD41SensorDataEntry extends SCDXXSensorDataEntry {
  /// Carbon Dioxide (ppm)
  @override
  int get carbonDioxide => super.carbonDioxide.toInt();

  // SCD41SensorDataEntry(DateTime timeStamp, int carbonDioxide,
  //     double temperature, double humidity)
  //     : super(timeStamp, carbonDioxide, temperature, humidity);

  SCD41SensorDataEntry.createFromDB(
    String dateTime,
    int carbonDioxide,
    double temperature,
    double humidity,
  ) : super.createFromDB(dateTime, carbonDioxide, temperature, humidity);
}

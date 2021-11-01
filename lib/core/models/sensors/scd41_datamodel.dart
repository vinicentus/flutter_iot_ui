import 'package:flutter_iot_ui/core/models/sensors/generic_datamodel.dart';

class SCD41SensorDataEntry extends GenericSensorDataEntry {
  /// Carbon Dioxide (ppm)
  final int carbonDioxide;

  /// Temperature (°C)
  final double temperature;

  /// Humidity (%RH)
  final double humidity;

  SCD41SensorDataEntry(
      DateTime timeStamp, this.carbonDioxide, this.temperature, this.humidity)
      : super.createFromDB(timeStamp);

  SCD41SensorDataEntry.createFromDB(
    String dateTime,
    this.carbonDioxide,
    this.temperature,
    this.humidity,
  ) : super.createFromDB(DateTime.parse(dateTime));
}

import 'package:flutter_iot_ui/core/models/sensors/generic_datamodel.dart';

abstract class SCDXXSensorDataEntry extends GenericSensorDataEntry {
  /// Carbon Dioxide (ppm).
  /// This can be a integer for SCD41 or double for SCD30.
  final num carbonDioxide;

  /// Temperature (°C)
  final double temperature;

  /// Humidity (%RH)
  final double humidity;

  // SCDXXSensorDataEntry(
  //     DateTime timeStamp, this.carbonDioxide, this.temperature, this.humidity)
  //     : super(timeStamp);

  SCDXXSensorDataEntry.createFromDB(
    String dateTime,
    this.carbonDioxide,
    this.temperature,
    this.humidity,
  ) : super.createFromDB(dateTime);
}

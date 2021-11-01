import 'package:flutter_iot_ui/core/models/sensors/scdxx_generic_datamodel.dart';

class SCD30SensorDataEntry extends SCDXXSensorDataEntry {
  // f"CO2: {m[0]:.2f}ppm, temp: {m[1]:.2f}'C, rh: {m[2]:.2f}%"

  /// Carbon Dioxide (ppm)
  @override
  double get carbonDioxide => super.carbonDioxide.toDouble();

  // SCDXXSensorDataEntry(
  //     DateTime timeStamp, this.carbonDioxide, this.temperature, this.humidity)
  //     : super(timeStamp, carbonDioxide, temperature, humidity);

  SCD30SensorDataEntry.createFromDB(
    String dateTime,
    double d1,
    double d2,
    double d3,
  ) : super.createFromDB(dateTime, d1, d2, d3);
}

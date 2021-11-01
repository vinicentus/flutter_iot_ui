import 'package:flutter_iot_ui/core/models/sensors/generic_datamodel.dart';

class SCD30SensorDataEntry extends GenericSensorDataEntry {
  final List<double> _measurements;

  // f"CO2: {m[0]:.2f}ppm, temp: {m[1]:.2f}'C, rh: {m[2]:.2f}%"

  /// Carbon Dioxide (ppm)
  get carbonDioxide => this._measurements[0];

  /// Temperature (°C)
  get temperature => this._measurements[1];

  /// Humidity (%RH)
  get humidity => this._measurements[2];

  SCD30SensorDataEntry(DateTime timeStamp, this._measurements)
      : super.createFromDB(timeStamp);

  SCD30SensorDataEntry.createFromDB(
    String dateTime,
    double d1,
    double d2,
    double d3,
  )   : this._measurements = [d1, d2, d3],
        super.createFromDB(DateTime.parse(dateTime));
}

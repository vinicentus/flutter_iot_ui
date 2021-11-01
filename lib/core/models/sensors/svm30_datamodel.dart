import 'package:flutter_iot_ui/core/models/sensors/generic_datamodel.dart';

class SVM30SensorDataEntry extends GenericSensorDataEntry {
  final List<double> _measurements;

  /// CO2eq (ppm)
  get carbonDioxide => this._measurements[0];

  /// tVOC (ppb)
  get totalVolatileOrganicCompounds => this._measurements[1];

  // SVM30SensorDataEntry(DateTime timeStamp, this._measurements)
  //     : super(timeStamp);

  SVM30SensorDataEntry.createFromDB(
    String dateTime,
    double co2,
    double tvoc,
  )   : this._measurements = [co2, tvoc],
        super.createFromDB(dateTime);
}

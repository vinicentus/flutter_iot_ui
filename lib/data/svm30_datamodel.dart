class SVM30SensorDataEntry {
  final DateTime timeStamp;
  final List<double> _measurements;

  /// CO2eq (ppm)
  get carbonDioxide => this._measurements[0];

  /// tVOC (ppb)
  get totalVolatileOrganicCompounds => this._measurements[1];

  SVM30SensorDataEntry(this.timeStamp, this._measurements);

  SVM30SensorDataEntry.createFromDB(
    String dateTime,
    double co2,
    double tvoc,
  )   : this.timeStamp = DateTime.parse(dateTime),
        this._measurements = [co2, tvoc];
}

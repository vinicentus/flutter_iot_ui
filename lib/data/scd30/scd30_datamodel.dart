class SCD30SensorDataEntry {
  final DateTime timeStamp;
  final List<double> _measurements;

  // f"CO2: {m[0]:.2f}ppm, temp: {m[1]:.2f}'C, rh: {m[2]:.2f}%"

  /// Canrbon dioxide (ppm)
  get carbonDioxide => this._measurements[0];

  /// Temperature (C)
  get temperature => this._measurements[1];

  /// Humidity (%)
  get humidity => this._measurements[2];

  SCD30SensorDataEntry(this.timeStamp, this._measurements);

  SCD30SensorDataEntry.createFromDB(
    String dateString,
    String timeString,
    num d1,
    num d2,
    num d3,
  )   : this.timeStamp = DateTime.parse('$dateString $timeString'),
        this._measurements = [d1, d2, d3];
}
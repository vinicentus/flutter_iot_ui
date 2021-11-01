class SCD41SensorDataEntry {
  final DateTime timeStamp;

  /// Carbon Dioxide (ppm)
  final int carbonDioxide;

  /// Temperature (°C)
  final double temperature;

  /// Humidity (%RH)
  final double humidity;

  SCD41SensorDataEntry(
      this.timeStamp, this.carbonDioxide, this.temperature, this.humidity);

  SCD41SensorDataEntry.createFromDB(
    String dateTime,
    this.carbonDioxide,
    this.temperature,
    this.humidity,
  ) : this.timeStamp = DateTime.parse(dateTime);
}

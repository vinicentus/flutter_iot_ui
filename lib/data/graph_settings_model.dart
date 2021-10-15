class GraphSettingsModel {
  /// Wether to subtract the smaller size values from the bigger ones,
  /// so that the range of the bigger particle size measurements doesn't include the range of the smaller ones...
  bool subtractParticleSizes = true;

  /// Wether to enable moving average on all graphs.
  bool useMovingAverage = false;

  /// The number of samples used per moving average sample,
  /// if moving average is enabled.
  int movingAverageSamples = 10;

  /// This sets how often the UI gets new data to display.
  Duration graphRefreshTime = Duration(seconds: 60);

  /// Specifies which time interval to show data from in graphs.
  Duration graphTimeWindow = Duration(hours: 3);
}

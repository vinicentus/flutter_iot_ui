import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/visual/widgets/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  static const String route = '/SettingsPage';
  final String title = 'Settings';

  @override
  Widget build(BuildContext context) {
    var model = context.watch<GraphSettingsModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [AppbarTrailingInfo()],
      ),
      drawer: NavDrawer(SettingsPage.route),
      body: ListView(
        children: [
          // This could also be a CheckboxListTile
          SwitchListTile(
            title: Text(
                'Subtract smaller particle size ranges from the bigger ones?'),
            subtitle: Text(
                '''Show particle sizes in separate ranges instead of beginning all ranges from 0.3µm.
This applies to the Mass Concentration and Number Concentration graphs
Example:  2.5-4.0µm, instead of 0.3-4.0µm.
This output is generated by subtracting the smaller particle size ranges from the bigger ones.'''),
            value: model.subtractParticleSizes,
            onChanged: model.setSubtractParticleSizes,
          ),
          SwitchListTile(
            title: Text('Use moving average?'),
            subtitle: Text(
                'Forces the graphs to take a moving average with a time period of 10 minutes. This essentially smooths out the graph.'),
            value: model.useMovingAverage,
            onChanged: model.setUseMovingAverage,
          ),
          Column(
            children: [
              ListTile(
                title: Text(
                    'Set the number of samples per moving average point on the graph.'),
                subtitle: Text(
                    '''We currently get samples roughly every minute, so a value of 10 would mean that the averages are calculated over 10 minute periods.
Higher values mean smoother lines on the graph.'''),
              ),
              Slider(
                value: model.movingAverageSamples.toDouble(),
                min: 10,
                max: 60,
                divisions: 5,
                label: model.movingAverageSamples.round().toString(),
                onChanged: model.setMovingAverageSamples,
              ),
            ],
          ),
          SwitchListTile(
            title: Text('Get data over web3?'),
            value: model.usesWeb3(),
            onChanged: model.setUsesWeb3,
          ),
          Column(
            children: [
              ListTile(
                title: Text(
                    'Set the number of seconds to wait between graph data fetch.'),
                subtitle: Text(
                    'This controls how often the app fetches new data to display.'),
              ),
              Slider(
                value: model.graphRefreshTime.inSeconds.toDouble(),
                min: 10,
                max: 120,
                divisions: 11,
                label: '${model.graphRefreshTime.inSeconds.round()}s',
                onChanged: model.setGraphRefreshime,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

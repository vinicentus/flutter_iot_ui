import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/util/sensor_location_enum.dart';
import 'package:flutter_iot_ui/core/util/view_state_enum.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/core/services/selected_devices_model.dart';
import 'package:flutter_iot_ui/visual/pages/devices.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/mass_concentration.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/number_concentration.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/scdxx_pages.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/typical_particle_size.dart';
import 'package:flutter_iot_ui/visual/pages/settings.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/svm30_page.dart';
import 'package:flutter_iot_ui/visual/pages/token_manager.dart';
import 'package:flutter_iot_ui/visual/pages/users.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatefulWidget {
  final String selectedRoute;
  NavDrawer(this.selectedRoute, {Key? key}) : super(key: key);

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  var _selectedDevicesModel = GetIt.instance<SelectedDevicesModel>();

  List<String> _sensorsRemote = [];
  List<String> _sensorsLocal = [];

  var viewState = ViewState.loading;

  @override
  initState() {
    super.initState();

    // This will complete sometime in the future and call setState
    _asyncLoadBothIDs();
  }

  _asyncLoadBothIDs() async {
    await _selectedDevicesModel.loadRemoteID();
    await _selectedDevicesModel.loadLocalID();

    setState(() {
      if (_selectedDevicesModel.selectedOracleId != null)
        _sensorsRemote = _selectedDevicesModel.selectedOracleId!.sensors;

      if (_selectedDevicesModel.localOracleId != null)
        _sensorsLocal = _selectedDevicesModel.localOracleId!.sensors;

      viewState = ViewState.ready;
    });
  }

  Widget _buildMenuItem(
      {required BuildContext context,
      required Widget leading,
      required Widget title,
      required String routeName,
      List? routeArguments}) {
    var activeArguments = ModalRoute.of(context)!.settings.arguments as List?;

    bool routesMatch = routeName == widget.selectedRoute;
    bool argumentsMatch = routeArguments?[0] == activeArguments?[0] &&
        routeArguments?[1] == activeArguments?[1];
    bool isSelected = routesMatch && argumentsMatch;

    return ListTile(
      leading: leading,
      title: title,
      onTap: () {
        if (isSelected) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context)
              .pushReplacementNamed(routeName, arguments: routeArguments);
        }
      },
      selected: isSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    var settingsModel = context.read<GraphSettingsModel>();

    var children = <Widget>[
      _buildMenuItem(
        context: context,
        leading: Icon(Icons.account_circle),
        title: Text('Users'),
        routeName: UsersPage.route,
      ),
      _buildMenuItem(
        context: context,
        leading: Icon(Icons.devices),
        title: Text('Devices'),
        routeName: DevicesPage.route,
      ),
      _buildMenuItem(
        context: context,
        leading: Icon(Icons.attach_money),
        title: Text('Tokens'),
        routeName: TokenManagerPage.route,
      ),
      _buildMenuItem(
        context: context,
        leading: Icon(Icons.settings),
        title: Text('Settings'),
        routeName: SettingsPage.route,
      ),
    ];

    if (viewState == ViewState.loading) {
      children.add(Center(child: CircularProgressIndicator()));
    }

    if (settingsModel.usesSqLite()) {
      children.addAll([
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text('SQLite')),
        ),
      ]);

      children.addAll(displayRelevantSensors(context, SensorLocation.local));
    }

    if (settingsModel.usesWeb3()) {
      children.addAll([
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text('Web3')),
        ),
      ]);

      children.addAll(displayRelevantSensors(context, SensorLocation.remote));
    }

    return Drawer(
        child: ListView(
      controller:
          ScrollController(), // I don't know why this is neede, but probably related to https://github.com/flutter/flutter/issues/85456
      children: children,
    ));
  }

  List<Widget> displayRelevantSensors(
      BuildContext context, SensorLocation sensorLocation) {
    var children = <Widget>[];

    List<String> sensors;
    switch (sensorLocation) {
      case SensorLocation.local:
        sensors = _sensorsLocal;
        break;
      case SensorLocation.remote:
        sensors = _sensorsRemote;
        break;
      default:
        throw Exception('No mtching case');
    }

    if (sensors.contains('svm30')) {
      children.addAll([
        Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('SVM30'),
        ),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.airplay),
            title: Text('SVM30'),
            routeName: SVM30Page.route,
            routeArguments: [sensorLocation]),
      ]);
    }

    if (sensors.contains('scd30')) {
      children.addAll([
        Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('SCD30'),
        ),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.air),
            title: Text('Carbon Dioxide'),
            routeName: CarbonDioxidePage.route,
            routeArguments: [sensorLocation, 'scd30']),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.thermostat),
            title: Text('Temperature'),
            routeName: TemperaturePage.route,
            routeArguments: [sensorLocation, 'scd30']),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.water),
            title: Text('Humidity'),
            routeName: HumidityPage.route,
            routeArguments: [sensorLocation, 'scd30']),
      ]);
    }

    if (sensors.contains('scd41')) {
      children.addAll([
        Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('SCD41'),
        ),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.air),
            title: Text('Carbon Dioxide'),
            routeName: CarbonDioxidePage.route,
            routeArguments: [sensorLocation, 'scd41']),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.thermostat),
            title: Text('Temperature'),
            routeName: TemperaturePage.route,
            routeArguments: [sensorLocation, 'scd41']),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.water),
            title: Text('Humidity'),
            routeName: HumidityPage.route,
            routeArguments: [sensorLocation, 'scd41']),
      ]);
    }

    if (sensors.contains('sps30')) {
      children.addAll([
        Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('SPS30'),
        ),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.circle),
            title: Text('Mass Concentration'),
            routeName: MassConcentrationPage.route,
            routeArguments: [sensorLocation]),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.ac_unit),
            title: Text('Number Concentration'),
            routeName: NumberConcentrationPage.route,
            routeArguments: [sensorLocation]),
        _buildMenuItem(
            context: context,
            leading: Icon(Icons.add_road),
            title: Text('Typical Particle Size'),
            routeName: TypicalParticleSizePage.route,
            routeArguments: [sensorLocation]),
      ]);
    }

    return children;
  }
}

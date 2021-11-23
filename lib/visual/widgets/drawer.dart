import 'package:flutter/material.dart';
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

    if (_selectedDevicesModel.selectedOracleId != null) {
      _sensorsRemote = _selectedDevicesModel.selectedOracleId!.sensors;
      viewState = ViewState.ready;
    } else {
      // This will complete sometime in the future and call setState
      _asyncLoadRemoteID();
    }

    if (_selectedDevicesModel.localOracleId != null) {
      _sensorsLocal = _selectedDevicesModel.localOracleId!.sensors;
    } else {
      // This will complete sometime in the future and call setState
      _asyncLoadLocalID();
    }
  }

  _asyncLoadRemoteID() async {
    await _selectedDevicesModel.loadRemoteID();

    setState(() {
      if (_selectedDevicesModel.selectedOracleId != null)
        _sensorsRemote = _selectedDevicesModel.selectedOracleId!.sensors;
      viewState = ViewState.ready;
    });
  }

  _asyncLoadLocalID() async {
    await _selectedDevicesModel.loadLocalID();

    setState(() {
      if (_selectedDevicesModel.localOracleId != null)
        _sensorsRemote = _selectedDevicesModel.localOracleId!.sensors;
      viewState = ViewState.ready;
    });
  }

  Widget _buildMenuItem(
      {required BuildContext context,
      required Widget leading,
      required Widget title,
      required String routeName}) {
    var isSelected = routeName == widget.selectedRoute;

    return ListTile(
      leading: leading,
      title: title,
      onTap: () {
        if (isSelected) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed(routeName);
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

      // TODO: display local sensors
    }

    if (settingsModel.usesWeb3()) {
      children.addAll([
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text('Web3')),
        ),
      ]);

      if (_sensorsRemote.contains('svm30')) {
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
          ),
        ]);
      }

      if (_sensorsRemote.contains('scd30')) {
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
            routeName: CarbonDioxidePage.route + '/scd30',
          ),
          _buildMenuItem(
            context: context,
            leading: Icon(Icons.thermostat),
            title: Text('Temperature'),
            routeName: TemperaturePage.route + '/scd30',
          ),
          _buildMenuItem(
            context: context,
            leading: Icon(Icons.water),
            title: Text('Humidity'),
            routeName: HumidityPage.route + '/scd30',
          ),
        ]);
      }

      if (_sensorsRemote.contains('scd41')) {
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
            routeName: CarbonDioxidePage.route + '/scd41',
          ),
          _buildMenuItem(
            context: context,
            leading: Icon(Icons.thermostat),
            title: Text('Temperature'),
            routeName: TemperaturePage.route + '/scd41',
          ),
          _buildMenuItem(
            context: context,
            leading: Icon(Icons.water),
            title: Text('Humidity'),
            routeName: HumidityPage.route + '/scd41',
          ),
        ]);
      }

      if (_sensorsRemote.contains('sps30')) {
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
          ),
          _buildMenuItem(
            context: context,
            leading: Icon(Icons.ac_unit),
            title: Text('Number Concentration'),
            routeName: NumberConcentrationPage.route,
          ),
          _buildMenuItem(
            context: context,
            leading: Icon(Icons.add_road),
            title: Text('Typical Particle Size'),
            routeName: TypicalParticleSizePage.route,
          ),
        ]);
      }
    }

    return Drawer(
        child: ListView(
      children: children,
    ));
  }
}

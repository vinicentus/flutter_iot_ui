import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:flutter_iot_ui/core/settings_constants.dart';
import 'package:flutter_iot_ui/visual/pages/devices.dart';
import 'package:flutter_iot_ui/visual/pages/pages.dart';
import 'package:flutter_iot_ui/visual/pages/settings.dart';
import 'package:flutter_iot_ui/visual/pages/svm30_page.dart';
import 'package:flutter_iot_ui/visual/pages/users.dart';

class NavDrawer extends StatelessWidget {
  final String selectedRoute;
  NavDrawer(this.selectedRoute, {Key? key}) : super(key: key);

  Widget _buildMenuItem(
      {required BuildContext context,
      required Widget leading,
      required Widget title,
      required String routeName}) {
    var isSelected = routeName == selectedRoute;

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
    // An empty list means that the device doesn't have any sensors connected or that the ID could not be correctly parsed
    // TODO: handle that situation
    var sensors = <String>[];
    if (globalWeb3Client.selectedOracleId != null) {
      try {
        sensors = JsonId.fromString(globalWeb3Client.selectedOracleId!)
            .sensors
            .toList();
      } catch (e) {
        print('Drawer: Could not parse JsonId');
      }
    } else {
      print('Drawer: Could not get selected Oracle');
    }

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
        leading: Icon(Icons.settings),
        title: Text('Settings'),
        routeName: SettingsPage.route,
      ),
    ];

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
        ),
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

    return Drawer(
        child: ListView(
      children: children,
    ));
  }
}

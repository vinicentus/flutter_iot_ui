import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/visual/pages.dart';
import 'package:flutter_iot_ui/visual/settings.dart';
import 'package:flutter_iot_ui/visual/svm30_page.dart';

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
    return Drawer(
        child: ListView(
      children: [
        _buildMenuItem(
          context: context,
          leading: Icon(Icons.airplay),
          title: Text('SVM30'),
          routeName: SVM30Page.route,
        ),
        _buildMenuItem(
          context: context,
          leading: Icon(Icons.air),
          title: Text('Carbon Dioxide'),
          routeName: CarbonDioxidePage.route,
        ),
        _buildMenuItem(
          context: context,
          leading: Icon(Icons.ac_unit),
          title: Text('Temperature'),
          routeName: TemperaturePage.route,
        ),
        _buildMenuItem(
          context: context,
          leading: Icon(Icons.add_road),
          title: Text('Humidity'),
          routeName: HumidityPage.route,
        ),
        _buildMenuItem(
          context: context,
          leading: Icon(Icons.air),
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
        _buildMenuItem(
          context: context,
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          routeName: SettingsPage.route,
        ),
      ],
    ));
  }
}

import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  //final int selectedRoute;

  //const NavDrawer({Key key, this.selectedRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        ListTile(
          leading: Icon(Icons.airplay),
          title: Text('SVM30'),
          onTap: () => Navigator.of(context).pushReplacementNamed('/svm_page'),
        ),
        ListTile(
          leading: Icon(Icons.air),
          title: Text('Carbon Dioxide'),
          onTap: () =>
              Navigator.of(context).pushReplacementNamed('/carbondioxide_page'),
        ),
        ListTile(
          leading: Icon(Icons.ac_unit),
          title: Text('Temperature'),
          onTap: () =>
              Navigator.of(context).pushReplacementNamed('/temperature_page'),
        ),
        ListTile(
          leading: Icon(Icons.add_road),
          title: Text('Humidity'),
          onTap: () =>
              Navigator.of(context).pushReplacementNamed('/humidity_page'),
        ),
        ListTile(
          leading: Icon(Icons.air),
          title: Text('Mass Concentration'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed('/massconcentration_page'),
        ),
        ListTile(
          leading: Icon(Icons.ac_unit),
          title: Text('Number Concentration'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed('/numberconcentration_page'),
        ),
        ListTile(
          leading: Icon(Icons.add_road),
          title: Text('Typical Particle Size'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed('/typicalparticlesize_page'),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    ));
  }
}

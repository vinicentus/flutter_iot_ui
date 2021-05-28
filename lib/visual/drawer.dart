import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  //final int selectedRoute;

  //const NavDrawer({Key key, this.selectedRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
          child: Text(
            'Select sensor',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            //image: DecorationImage(
            //    fit: BoxFit.fill,
            //    image:
            //        NetworkImage('https://picsum.photos/seed/picsum/200/300')),
          ),
        ),
        ListTile(
          leading: Icon(Icons.input),
          title: Text('SPS30'),
          //selected: this.selectedRoute == '/sps_chart',
          onTap: () => Navigator.of(context).pushReplacementNamed('/sps_page'),
        ),
        ListTile(
          leading: Icon(Icons.verified_user),
          title: Text('SCD30'),
          onTap: () => Navigator.of(context).pushReplacementNamed('/scd_page'),
        ),
        ListTile(
          leading: Icon(Icons.border_color),
          title: Text('Other'),
          onTap: () => Navigator.of(context).pop(),
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
import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';

class UsersPage extends StatefulWidget {
  static const String route = '/UsersPage';
  final String title = 'Users';

  @override
  State<StatefulWidget> createState() {
    return UsersPageState();
  }
}

class UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: NavDrawer(UsersPage.route),
      body: Center(
          child: Card(
              child: Text(
                  'There are no registered ussers for this Ethereum account'))),
    );
  }
}

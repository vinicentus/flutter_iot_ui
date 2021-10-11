import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/settings_constants.dart';
import 'package:flutter_iot_ui/data/web3.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:web3dart/web3dart.dart';

class UsersPage extends StatefulWidget {
  static const String route = '/UsersPage';
  final String title = 'Users';

  @override
  State<StatefulWidget> createState() {
    return UsersPageState();
  }
}

class UsersPageState extends State<UsersPage> {
  Future<DeployedContract?> _userOrNull() async {
    if (globalDBManager is! Web3Manager) {
      throw Exception('Not using web3 for data access!');
    }

    var web3 = (globalDBManager as Web3Manager);
    await web3.init();

    if (await web3.checkUserExists()) {
      return await web3.loadUser();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: NavDrawer(UsersPage.route),
        body: Center(
            child: FutureBuilder(
          future: _userOrNull(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is DeployedContract) {
                return Card(
                  child: Text(
                      'The currently loaded user is ${(snapshot.data as DeployedContract).address}'),
                );
              } else {
                return Card(
                    child: Text(
                        'There is no user registered to the current ethereum address. Do you want to create one?'));
              }
            } else if (snapshot.hasError) {
              return Card(
                child: Text('error: ${snapshot.error}'),
              );
            } else {
              return Card(child: Text('loading...'));
            }
          },
        )));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/settings_constants.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';

class UsersPage extends StatefulWidget {
  static const String route = '/UsersPage';
  final String title = 'Users';

  @override
  State<StatefulWidget> createState() {
    return UsersPageState();
  }
}

class UsersPageState extends State<UsersPage> {
  bool _userExists = false;

  @override
  initState() {
    super.initState();

    _initUser();
  }

  void _initUser() async {
    await globalWeb3Client.init();
    var exists = await globalWeb3Client.checkUserExists();
    await globalWeb3Client.loadUser();
    setState(() {
      _userExists = exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: NavDrawer(UsersPage.route),
      body: Center(
        child: _userExists
            ? Card(
                child: Text(
                    'The currently loaded user is ${globalWeb3Client.publicAddress}'),
              )
            : Card(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'There is no user registered to the current ethereum address (${globalWeb3Client.publicAddress}). Do you want to create one?'),
                  MaterialButton(
                    child: Text('Create user for the current account?'),
                    onPressed: () async {
                      await globalWeb3Client.createUser();
                      var exists = await globalWeb3Client.checkUserExists();
                      await globalWeb3Client.loadUser();
                      setState(() {
                        _userExists = exists;
                      });
                    },
                  ),
                ],
              )),
      ),
    );
  }
}

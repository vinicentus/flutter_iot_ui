import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:flutter_iot_ui/core/util/view_state_enum.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
import 'package:get_it/get_it.dart';

class UsersPage extends StatefulWidget {
  static const String route = '/UsersPage';
  final String title = 'Users';

  @override
  State<StatefulWidget> createState() {
    return UsersPageState();
  }
}

class UsersPageState extends State<UsersPage> {
  var web3 = GetIt.instance<Web3>();
  bool _userExists = false;

  late num _balance;

  ViewState _viewState = ViewState.loading;

  @override
  initState() {
    super.initState();

    _initUser();
  }

  void _initUser() async {
    await web3.init();
    var exists = await web3.checkUserExists();
    if (exists) {
      await web3.loadUser();
    }

    var balance = await web3.getUserBalance();

    setState(() {
      _userExists = exists;
      _balance = balance;
      _viewState = ViewState.ready;
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
        child: _viewState == ViewState.loading
            ? CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _userExists
                      ? Card(
                          child: Text(
                              'The currently loaded user is ${web3.publicAddress.hexEip55}'),
                        )
                      : Card(
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'There is no user registered to the current ethereum address (${web3.publicAddress.hexEip55}). Do you want to create one?'),
                            ElevatedButton(
                              child:
                                  Text('Create user for the current account?'),
                              onPressed: () async {
                                await web3.createUser();
                                var exists = await web3.checkUserExists();
                                await web3.loadUser();
                                setState(() {
                                  _userExists = exists;
                                });
                              },
                            ),
                          ],
                        )),
                  Card(
                    child: Text('current account balance in ETH: $_balance'),
                  ),
                ],
              ),
      ),
    );
  }
}

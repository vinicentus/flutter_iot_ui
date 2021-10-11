import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/settings_constants.dart';
import 'package:flutter_iot_ui/data/web3.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:web3dart/web3dart.dart';

class DevicesPage extends StatefulWidget {
  static const String route = '/DevicesPage';
  final String title = 'Devices';

  @override
  State<StatefulWidget> createState() {
    return DevicesPageState();
  }
}

class DevicesPageState extends State<DevicesPage> {
  Web3Manager get web3 {
    if (globalDBManager is! Web3Manager) {
      throw Exception('Not using web3 for data access!');
    } else {
      return globalDBManager as Web3Manager;
    }
  }

  _init() async {
    await web3.init();
    return await web3.loadOracles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: NavDrawer(DevicesPage.route),
      body: FutureBuilder(
          future: _init(),
          builder: (context, snapshot) {
            print(snapshot.hasData);
            if (snapshot.hasData) {
              Map devices = snapshot.data as Map;
              print(devices);
              return ListView.separated(
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(devices.values.first.address.toString()));
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: devices.length);
            } else {
              return Text('loading');
            }
          }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/create_config.dart';
import 'package:flutter_iot_ui/data/settings_constants.dart';
import 'package:flutter_iot_ui/data/web3.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:web3dart/web3dart.dart';
import 'device_config_creator.dart';

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

  Future<bool> _checkOracleActive(DeployedContract contract) async {
    var result = await web3.ethClient.call(
        contract: contract, function: contract.function('active'), params: []);
    return result.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          MaterialButton(
              child: Text('Create device'),
              onPressed: () {
                showDialog(
                    context: context, builder: (context) => FormWidget());
              })
        ],
      ),
      drawer: NavDrawer(DevicesPage.route),
      body: FutureBuilder(
          future: _init(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map devices = snapshot.data as Map;
              return ListView.separated(
                  itemBuilder: (context, index) {
                    String id = devices.keys.elementAt(index);
                    DeployedContract deviceAtIndex = devices[id];

                    JsonId? jsonId;
                    try {
                      jsonId = JsonId.fromString(id);
                    } catch (e) {
                      print('whoopise');
                    }

                    return RadioListTile(
                      // Use the ID of the oracle as stored in the oracle manager,
                      // instead of the oracle address.
                      title: Text(jsonId != null
                          ? '${jsonId.name}  #${jsonId.uniqueId}  ${jsonId.sensors}'
                          : 'ID: $id'),
                      subtitle: FutureBuilder(
                          future: _checkOracleActive(deviceAtIndex),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                  'active: ${snapshot.data.toString()}');
                            } else {
                              return Text('loading status...');
                            }
                          }),
                      // Selected if selected in Web3Manager is the same as this device
                      value: id,
                      onChanged: (String? changedId) {
                        setState(() {
                          web3.selectedOracleId = changedId!;
                        });
                      },
                      groupValue: web3.selectedOracleId,
                      secondary: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: Text(id),
                                children: [
                                  Wrap(
                                    children: [
                                      SimpleDialogOption(
                                        child: Text('Name: ${jsonId?.name}'),
                                      ),
                                      SimpleDialogOption(
                                        child: Text(
                                            'Supported Sensors: ${jsonId?.sensors}'),
                                      ),
                                      SimpleDialogOption(
                                        child: Text(
                                            'Unique ID: ${jsonId?.uniqueId}'),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  SimpleDialogOption(
                                    child: Text('Address of the Owner: YOU!'),
                                  ),
                                  SimpleDialogOption(
                                    child: Text(
                                        'Address of registered Task Manager contract: X'),
                                  ),
                                  SimpleDialogOption(
                                    child: Text('Price per task: X'),
                                  ),
                                  SimpleDialogOption(
                                    child: Text('Task Backlog: X'),
                                  ),
                                  SimpleDialogOption(
                                    child: Text('Active Status: X'),
                                  ),
                                  SimpleDialogOption(
                                    child: Text(
                                        'Discoverable Status (obsolete): X'),
                                  ),
                                  SimpleDialogOption(
                                    child: Text(
                                        'Discovery configuratio (obsolete): X'),
                                  ),
                                  SimpleDialogOption(
                                    child: Text(
                                        'Number of complete assignments: X'),
                                  ),
                                  // TODO: add actions that call functions to change values
                                ],
                              );
                            },
                          );
                        },
                        child: Text('more info'),
                      ),
                    );
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

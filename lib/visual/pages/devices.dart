import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/contracts/Oracle.g.dart';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_iot_ui/visual/widgets/device_config_creator.dart';

class DevicesPage extends StatefulWidget {
  static const String route = '/DevicesPage';
  final String title = 'Devices';

  @override
  State<StatefulWidget> createState() {
    return DevicesPageState();
  }
}

class DevicesPageState extends State<DevicesPage> {
  var web3 = GetIt.instance<Web3>();

  _init() async {
    await web3.init();
    return await web3.loadOraclesForActiveUser();
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
                    Oracle deviceAtIndex = devices[id]!;

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
                          future: deviceAtIndex.active(),
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
                                    child: Row(
                                      children: [
                                        Text('Active Status: X'),
                                        MaterialButton(
                                            child: Text('toggle'),
                                            onPressed: () {
                                              deviceAtIndex.toggle_active(
                                                  credentials: web3.privateKey);
                                              setState(() {});
                                            })
                                      ],
                                    ),
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

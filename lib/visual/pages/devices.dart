import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:flutter_iot_ui/core/settings_constants.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
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
  _init() async {
    await globalWeb3Client.init();
    return await globalWeb3Client.loadOracles();
  }

  // TODO: move into web3 file
  Future<bool> _checkOracleActive(DeployedContract contract) async {
    var result = await globalWeb3Client.ethClient.call(
        contract: contract, function: contract.function('active'), params: []);
    return result.first;
  }

  // TODO: move into web3 file
  _toggleContractActiveStatus(DeployedContract contract) async {
    await globalWeb3Client.ethClient.sendTransaction(
      globalWeb3Client.privateKey,
      Transaction.callContract(
        contract: contract,
        function: contract.function('toggle_active'),
        parameters: [],
      ),
      chainId: globalWeb3Client.chainId,
    );
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
                          globalWeb3Client.selectedOracleId = changedId!;
                        });
                      },
                      groupValue: globalWeb3Client.selectedOracleId,
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
                                              _toggleContractActiveStatus(
                                                  deviceAtIndex);
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
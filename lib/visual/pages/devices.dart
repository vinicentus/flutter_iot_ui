import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/contracts/Oracle.g.dart';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:flutter_iot_ui/core/viewmodels/device_info_dialog_model.dart';
import 'package:flutter_iot_ui/visual/widgets/device_info_dialog.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_iot_ui/visual/widgets/device_config_creator.dart';
import 'package:provider/provider.dart';

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
              var devices = snapshot.data as Map<JsonId, Oracle>;
              if (devices.isEmpty) {
                return Center(child: Text('no devices'));
              } else {
                return ListView.separated(
                    itemBuilder: (context, index) {
                      JsonId jsonId = devices.keys.elementAt(index);
                      Oracle deviceAtIndex = devices[jsonId]!;

                      return RadioListTile(
                        // Use the ID of the oracle as stored in the oracle manager,
                        // instead of the oracle address.
                        title: Text(jsonId.isValidJson
                            ? '${jsonId.name}  #${jsonId.uniqueId}  ${jsonId.sensors}'
                            : 'ID: ${jsonId.id}'),
                        subtitle: FutureBuilder(
                            future: deviceAtIndex.active(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                    'active: ${snapshot.data.toString()}');
                              } else {
                                return CircularProgressIndicator();
                              }
                            }),
                        // Selected if selected in Web3Manager is the same as this device
                        value: jsonId,
                        onChanged: (JsonId? changedId) {
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
                                // TODO: use CangeNotifierProxyProvider !
                                return ChangeNotifierProvider<
                                        DeviceInfoDialogModel>(
                                    create: (context) => DeviceInfoDialogModel(
                                        deviceAtIndex, jsonId),
                                    builder: (context, child) =>
                                        DeviceInfoDialog());
                              },
                            );
                          },
                          child: Text('more info'),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: devices.length);
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

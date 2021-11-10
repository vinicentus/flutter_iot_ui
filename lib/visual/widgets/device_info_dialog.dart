import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/util/view_state_enum.dart';
import 'package:flutter_iot_ui/core/viewmodels/device_info_dialog_model.dart';
import 'package:provider/provider.dart';

class DeviceInfoDialog extends StatefulWidget {
  @override
  State<DeviceInfoDialog> createState() => _DeviceInfoDialogState();
}

class _DeviceInfoDialogState extends State<DeviceInfoDialog> {
  @override
  initState() {
    super.initState();
    var model = context.read<DeviceInfoDialogModel>();
    model.init();
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<DeviceInfoDialogModel>();

    return model.dataState == ViewState.loading
        ? Dialog(
            child: CircularProgressIndicator(),
          )
        : SimpleDialog(
            title: Wrap(
              children: [
                SimpleDialogOption(
                  child: Text('Name: ${model.jsonId.name}'),
                ),
                SimpleDialogOption(
                  child: Text('Supported Sensors: ${model.jsonId.sensors}'),
                ),
                SimpleDialogOption(
                  child: Text('Unique ID: ${model.jsonId.uniqueId}'),
                ),
              ],
            ),
            children: [
              SimpleDialogOption(child: Text('ID: ${model.jsonId}')),
              Divider(),
              SimpleDialogOption(
                child: Text('Address of the Owner: ${model.owner.hexEip55}'),
              ),
              SimpleDialogOption(
                child: Text(
                    'Address of registered Task Manager contract: ${model.manager.hexEip55}'),
              ),
              SimpleDialogOption(
                child: Text('Price per task: ${model.price}'),
              ),

              SimpleDialogOption(
                child: Row(
                  children: [
                    Text('Active Status: ${model.active}'),
                    Spacer(),
                    Flexible(
                      flex: 28,
                      child: OutlinedButton(
                          child: Text('toggle'), onPressed: model.toggleActive),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                child: Text(
                    'Discoverable Status (obsolete): ${model.discoverable}'),
              ),
              SimpleDialogOption(
                child: Text(
                    'Discovery configuratio (obsolete): "${model.configuration}"'),
              ),
              SimpleDialogOption(
                child:
                    Text('Number of complete assignments: ${model.completed}'),
              ),
              SimpleDialogOption(
                child: Text('Task Backlog: ${model.backlog}'),
              ),
              // TODO: add actions that call functions to change values
            ],
          );
  }
}

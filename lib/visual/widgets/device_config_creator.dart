import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_iot_ui/core/services/web3.dart';
import 'package:flutter_iot_ui/core/util/create_config.dart';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:get_it/get_it.dart';
import 'package:web3dart/credentials.dart';

class FormWidget extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final _rnd = Random();

  final web3 = GetIt.instance<Web3>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Column(
            children: [
              FormBuilder(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FormBuilderTextField(
                      name: 'device_name',
                      decoration: InputDecoration(labelText: 'Device Name'),
                      validator: FormBuilderValidators.compose([
                        // Require not empty
                        FormBuilderValidators.required(context),
                        // Require no spaces
                        (value) {
                          if (value == null) {
                            return null;
                          }
                          if (value.contains(' ')) {
                            return 'Device Name can\'t contain spaces';
                          }
                          return null;
                        },
                      ]),
                    ),
                    FormBuilderFilterChip(
                      name: 'device_types',
                      options: [
                        FormBuilderFieldOption(
                          value: 'sps30',
                          child: Text('sps30'),
                        ),
                        FormBuilderFieldOption(
                          value: 'scd30',
                          child: Text('scd30'),
                        ),
                        FormBuilderFieldOption(
                          value: 'scd41',
                          child: Text('scd41'),
                        ),
                        FormBuilderFieldOption(
                          value: 'svm30',
                          child: Text('svm30'),
                        ),
                      ],
                      validator: (list) {
                        if (list == null) {
                          return null;
                        }
                        if (list.isEmpty) {
                          return 'You must select at least one sensor';
                        }
                        return null;
                      },
                    ),
                    // This will be geenerated automatically, and then checked if it is unique!
                    FormBuilderTextField(
                      name: 'unique_id',
                      decoration: InputDecoration(labelText: 'Unique ID'),
                      initialValue: _rnd.nextInt(100).toString(),
                    ),
                    FormBuilderTextField(
                      name: 'service_cost',
                      decoration: InputDecoration(
                          labelText: 'Service Cost (in ERC-20 tokens)'),
                      initialValue: 2.toString(),
                      validator: FormBuilderValidators.integer(context,
                          errorText: "Must be an integer"),
                    ),
                    Text(
                        'The following values are automatically filled in, and set to the same values as used for this app. It is currently not possible to change them.'),
                    FormBuilderTextField(
                      name: 'gateway_host',
                      decoration: InputDecoration(labelText: 'gateway host'),
                      enabled: false,
                      initialValue: web3.httpUrl.host,
                    ),
                    FormBuilderTextField(
                      name: 'gateway_port',
                      decoration: InputDecoration(labelText: 'gateway port'),
                      enabled: false,
                      initialValue: web3.httpUrl.port.toString(),
                    ),
                    FormBuilderTextField(
                      name: 'chain_id',
                      decoration: InputDecoration(labelText: 'Chain ID'),
                      enabled: false,
                      initialValue: web3.chainId.toString(),
                    ),
                    FormBuilderTextField(
                      name: 'public_address',
                      decoration: InputDecoration(
                          labelText: 'Public Ethereum Address of the User'),
                      enabled: false,
                      initialValue: web3.publicAddress.hexEip55,
                    ),
                    FormBuilderTextField(
                      name: 'private_key',
                      decoration: InputDecoration(
                          labelText: 'Private Ethereum Key of the User'),
                      enabled: false,
                      initialValue: web3.privateKey.toHexString,
                    ),
                  ],
                ),
              ),
              Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: MaterialButton(
                      color: Theme.of(context).colorScheme.primary,
                      child: Text(
                        "Save configuration as file, and create device contract",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        _formKey.currentState!.save();
                        if (_formKey.currentState!.validate()) {
                          print(_formKey.currentState!.value);

                          // TODO: save to default location if file picker is not available
                          if (!(Platform.isWindows ||
                              Platform.isLinux ||
                              Platform.isMacOS)) {
                            throw Exception(
                                'Can\'t save file on other platform than desktop');
                          }

                          var path = await FilePicker.platform.saveFile(
                            fileName: 'device_settings.yaml',
                            allowedExtensions: ['yaml'],
                          );
                          // If the user sucessfully chose a path to save the file to
                          if (path != null) {
                            await File(path).writeAsString(
                                await modifyExampleFile(
                                    _formKey.currentState!.value));

                            Navigator.pop(context);

                            // Also create the device contact
                            try {
                              var jsonData = _formKey.currentState!.value;
                              await web3.createOracle(
                                  JsonId.fromValues(
                                          jsonData['device_name'],
                                          jsonData['device_types'],
                                          jsonData['unique_id'])
                                      .toString(),
                                  int.parse(jsonData['service_cost']));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Successfully created a device')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Could not create device contract: $e')));
                            }
                          }
                        } else {
                          print("validation failed");
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: MaterialButton(
                      color: Colors.red,
                      child: Text(
                        "Reset",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                    ),
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sames as .toRadixString(16) but returns the value with a preceding '0x'.
extension Hex on EthPrivateKey {
  String get toHexString {
    return '0x' + this.privateKeyInt.toRadixString(16);
  }
}

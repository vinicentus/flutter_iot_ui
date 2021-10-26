import 'dart:convert';
import 'package:flutter/services.dart';

/// Returns a yaml String, with passed values filled in according to device_config.yaml file format.
/// The returned String is inteded to be written to a file.
Future<String> modifyExampleFile(Map<String, dynamic> jsonData) async {
  var file =
      await rootBundle.loadString('resources/device_settings_template.yaml');

  var deviceTypes = '';
  for (final type in jsonData['device_types']) {
    // TODO: don't add newline if only one device type
    deviceTypes += "        - '$type'" + "\n";
  }
  print(deviceTypes);
  file = file.replaceFirst("        - 'sps30-12345'", deviceTypes);

  file = file.replaceFirst('name-12345', jsonData['device_name']);
  file = file.replaceFirst('unique-id-12345', jsonData['unique_id']);

  file = file.replaceFirst('service-cost-12345', jsonData['service_cost']);

  file = file.replaceFirst('gateway-host-12345', jsonData['gateway_host']);
  file = file.replaceFirst('gateway-port-12345', jsonData['gateway_port']);
  file = file.replaceFirst('chain-id-12345', jsonData['chain_id']);

  file = file.replaceFirst('public-address-12345', jsonData['public_address']);
  file = file.replaceFirst('private-key-12345', jsonData['private_key']);

  return file;
}

computeUniqueID(Map<String, dynamic> jsonData) {
  // Example: '{"name":"Device1","sensors":["sps30","scd30"],"uniqueId":"0"}'

  var idMap = {
    'name': jsonData['device_name'],
    'sensors': jsonData['device_types'],
    'uniqueId': jsonData['unique_id'],
  };

  return json.encode(idMap);
}

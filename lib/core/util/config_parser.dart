import 'dart:io';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:yaml/yaml.dart';

class YamlConfigParser {
  var _localPath =
      ' ~/git-repos/IoT-Microservice/app/resources/device_settings.yaml';

  parse() async {
    final contents = await File(_localPath).readAsString();
    return loadYaml(contents);
  }

  Future<JsonId> getJsonId() async {
    var yaml = await parse();
    return JsonId.fromValues(
        yaml['id']['name'], yaml['id']['sensors'], yaml['id']['uniqueId']);
  }
}

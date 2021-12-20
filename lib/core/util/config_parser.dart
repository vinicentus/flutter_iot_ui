import 'dart:io';
import 'package:flutter_iot_ui/core/models/json_id.dart';
import 'package:flutter_iot_ui/core/util/paths.dart';
import 'package:yaml/yaml.dart';

class YamlConfigParser {
  var _localPath = configPathIotDevice;

  parse() async {
    final contents = await File(_localPath).readAsString();
    return loadYaml(contents);
  }

  Future<JsonId> getJsonId() async {
    var yaml = await parse();
    return JsonId.fromValues(
        yaml['id']['name'],
        yaml['id']['sensors'].whereType<String>().toList(),
        yaml['id']['uniqueId']);
  }
}

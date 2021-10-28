import 'dart:convert';

class JsonId {
  final String name;
  final List<String> sensors;
  final String uniqueId;

  JsonId(this.name, this.sensors, this.uniqueId);

  factory JsonId.fromString(String id) {
    var jsonId = json.decode(id);
    return JsonId(
      jsonId['name'],
      List<String>.from(jsonId['sensors']),
      jsonId['uniqueId'],
    );
  }

  /// Example: '{"name":"Device1","sensors":["sps30","scd30"],"uniqueId":"0"}'
  @override
  String toString() {
    var idMap = {
      'name': name,
      'sensors': sensors,
      'uniqueId': uniqueId,
    };

    return json.encode(idMap);
  }
}

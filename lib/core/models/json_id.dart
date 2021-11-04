import 'dart:convert';

class JsonId {
  /// This is the raw ID.
  /// It might or might not be encodable into json,
  /// and might or might not have the suggested parameters.
  final String id;

  dynamic _decode(String key) {
    try {
      return json.decode(id)[key];
    } catch (e) {
      return null;
    }
  }

  String get name {
    var a = _decode('name');
    if (a is String) {
      return a;
    } else {
      return '';
    }
  }

  List<String> get sensors {
    var a = _decode('sensors');
    if (a is List) {
      return a.whereType<String>().toList();
    } else {
      return <String>[];
    }
  }

  String get uniqueId {
    var a = _decode('uniqueId');
    if (a is String) {
      return a;
    } else {
      return '';
    }
  }

  bool get isValidJson {
    if (name == '') return false;
    if (sensors == []) return false;
    if (uniqueId == '') return false;
    return true;
  }

  JsonId(this.id);

  /// Example: '{"name":"Device1","sensors":["sps30","scd30"],"uniqueId":"0"}'
  JsonId.fromValues(String name, List<String> sensors, String uniqueId)
      : id = json.encode({
          'name': name,
          'sensors': sensors.toList(),
          'uniqueId': uniqueId,
        });

  /// Returns null if it encountered an error
  Map<String, dynamic>? get asJsonMap {
    try {
      return json.decode(id);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => id;

  @override
  bool operator ==(other) {
    return (other is JsonId) && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

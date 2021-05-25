import 'dart:async';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/src/database.dart';
import 'package:sqflite_common/src/factory.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseFactoryMock implements SqfliteDatabaseFactory {
  var db;

  @override
  Future<bool> databaseExists(String path) async {
    return true;
  }

  @override
  Future<void> deleteDatabase(String path) {
    throw UnimplementedError('trying to delete mock database');
  }

  @override
  Future<String> getDatabasesPath() async {
    throw UnimplementedError();
  }

  @override
  Future<Database> openDatabase(String path,
      {OpenDatabaseOptions options}) async {
    db ??= MockDatabase();
    return db;
  }

  @override
  Future<void> setDatabasesPath(String path) {
    throw UnimplementedError();
  }

  @override
  Future<void> closeDatabase(SqfliteDatabase database) {
    // TODO: implement closeDatabase
    throw UnimplementedError();
  }

  @override
  Future<T> invokeMethod<T>(String method, [arguments]) {
    throw UnimplementedError();
  }

  @override
  Lock get lock => throw UnimplementedError();

  @override
  SqfliteDatabase newDatabase(
      SqfliteDatabaseOpenHelper openHelper, String path) {
    throw UnimplementedError();
  }

  @override
  void removeDatabaseOpenHelper(String path) {}

  @override
  Future<T> wrapDatabaseException<T>(Future<T> Function() action) {
    throw UnimplementedError();
  }
}

class MockDatabase implements Database {
  var rnd = Random();

  List<Map<String, Object>> data = [];

  @override
  Batch batch() {
    throw UnimplementedError();
  }

  @override
  Future<void> close() async {
    print('closing mock db');
    return;
  }

  @override
  Future<int> delete(String table, {String where, List<Object> whereArgs}) {
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeMethod<T>(String method, [arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql,
      [List<Object> arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<void> execute(String sql, [List<Object> arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<int> getVersion() {
    throw UnimplementedError();
  }

  @override
  Future<int> insert(String table, Map<String, Object> values,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) {
    throw UnimplementedError();
  }

  @override
  bool get isOpen => false;

  @override
  String get path => throw UnimplementedError();

  @override
  Future<List<Map<String, Object>>> query(String table,
      {bool distinct,
      List<String> columns,
      String where,
      List<Object> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {
    if (table == 'sensor_output') {
      var prevDateTime = DateTime.tryParse((data.isEmpty
          ? '2021-50-25 00:00:00'
          : '${data.elementAt(data.length - 1)['date']} ${data.elementAt(data.length - 1)['time']}'));
      var nextDateTime = prevDateTime.add(Duration(minutes: 5));
      data.add({
        'date': nextDateTime.toIso8601String().split('T').first,
        'time': nextDateTime.toIso8601String().split('T').last,
        'd1': 1,
        'd2': 1,
        'd3': 1,
        'd4': 1,
        'd5': 1,
        'd6': 1,
        'd7': 1,
        'd8': 1,
        'd9': rnd.nextInt(50),
        'd10': 1,
      });
      return data;
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Future<int> rawDelete(String sql, [List<Object> arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawInsert(String sql, [List<Object> arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, Object>>> rawQuery(String sql,
      [List<Object> arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object> arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<void> setVersion(int version) {
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(transaction, {bool exclusive}) {
    throw UnimplementedError();
  }

  @override
  Future<int> update(String table, Map<String, Object> values,
      {String where,
      List<Object> whereArgs,
      ConflictAlgorithm conflictAlgorithm}) {
    throw UnimplementedError();
  }
}

final databaseFactoryMock = DatabaseFactoryMock();

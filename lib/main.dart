import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/visual/pages.dart';
import 'package:flutter_iot_ui/visual/scd30_page.dart';
import 'package:flutter_iot_ui/visual/sps30_page.dart';
import 'package:flutter_iot_ui/visual/svm30_page.dart';

void main() {
  initDBLib();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Graph Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/scd_page',
      routes: {
        '/sps_page': (context) => SPS30Page(),
        '/scd_page': (context) => SCD30Page(),
        '/svm_page': (context) => SVM30Page(),
        '/carbondioxide_page': (context) => CarbonDioxidePage(),
        '/temperature_page': (context) => TemperaturePage(),
        '/humidity_page': (context) => HumidityPage(),
      },
    );
  }
}

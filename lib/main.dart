import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/sqlite.dart';
import 'package:flutter_iot_ui/sps30_data_chart.dart';

String dbPath = '/home/pi/IoT-Microservice/app/oracle/sensor_data.db';

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
      home: MyHomePage(title: 'Flutter Graph Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final rnd = Random();

  final List<SPS30SensorDataEntry> mockDataBase = [
    SPS30SensorDataEntry(
        DateTime(2017, 10, 10), [75, 1, 2, 3, 4, 5, 6, 7, 8, 9])
  ];

  void createRandomEntry() {
    var newTime = mockDataBase.last.timeStamp.add(Duration(hours: 1));
    this.setState(() {
      mockDataBase.add(SPS30SensorDataEntry(
          newTime, [1, 1, 2, 3, 4, 5, 6, 7, rnd.nextInt(50), 9]));
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder(
          stream: Stream.periodic(Duration(seconds: 1), (_) {
            createRandomEntry();
            return SensorDB(mockDataBase);
          }),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return SPS30DataChart(snapshot.data);
            } else if (snapshot.hasError) {
              return Text('Error');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

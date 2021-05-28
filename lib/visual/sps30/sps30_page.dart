import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/sps30/sps30_datamodel.dart';
import 'package:flutter_iot_ui/visual/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/data/constants.dart' show dbPath;
import 'package:flutter_iot_ui/visual/sps30/sps30_data_chart.dart';

class SPS30Page extends StatefulWidget {
  final String title = 'SPS30 Sensor Data';

  @override
  _SPS30PageState createState() => _SPS30PageState();
}

class _SPS30PageState extends State<SPS30Page> {
  bool _continue = true;

  // TODO: don't fetch the whole database every time...
  Stream<List<SPS30SensorDataEntry>> dbUpdates() async* {
    // Init
    var db = await getAllSPS30Entries(dbPath);
    yield db;

    while (_continue) {
      db = await Future.delayed(
          Duration(seconds: 5), () => getAllSPS30Entries(dbPath));
      yield db;
    }
  }

  @override
  void dispose() {
    // This stops the stream
    // could have laso used a StreamController
    _continue = false;
    super.dispose();
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
        actions: [AppbarTrailingInfo()],
      ),
      drawer: NavDrawer(),
      body: Center(
        child: StreamBuilder(
          stream: dbUpdates(),
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

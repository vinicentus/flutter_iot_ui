import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/data/scd30/scd30_datamodel.dart';
import 'package:flutter_iot_ui/visual/drawer.dart';
import 'package:flutter_iot_ui/data/sqlite.dart';
import 'package:flutter_iot_ui/data/constants.dart' show dbPath;
import 'package:flutter_iot_ui/visual/scd30/scd30_data_chart.dart';

class SCD30Page extends StatefulWidget {
  final String title = 'SCD30 Sensor Data';

  @override
  _SCD30PageState createState() => _SCD30PageState();
}

class _SCD30PageState extends State<SCD30Page> {
  bool _continue = true;

  // TODO: don't fetch the whole database every time...
  Stream<List<SCD30SensorDataEntry>> dbUpdates() async* {
    // Init
    var db = await getAllSCD30Entries(dbPath);
    yield db;

    while (_continue) {
      db = await Future.delayed(
          Duration(seconds: 5), () => getAllSCD30Entries(dbPath));
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
      ),
      drawer: NavDrawer(),
      body: Center(
        child: StreamBuilder(
          stream: dbUpdates(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: 0.95,
                      child: SCD30DataChart(snapshot.data),
                    ),
                  ),
                  Row(
                    children: [
                      CheckboxWidget('blue'),
                      CheckboxWidget('green'),
                      CheckboxWidget('purple'),
                    ],
                  )
                ],
              );
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

class CheckboxWidget extends StatefulWidget {
  final displayText;

  const CheckboxWidget(this.displayText, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CheckboxWidgetState();
  }
}

class CheckboxWidgetState extends State<CheckboxWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          checkColor: Colors.white,
          value: isChecked,
          onChanged: (bool value) {
            setState(() {
              isChecked = value;
            });
          },
        ),
        Text(widget.displayText),
      ],
    );
  }
}

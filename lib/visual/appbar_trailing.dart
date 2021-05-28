import 'dart:async';

import 'package:flutter/material.dart';

class AppbarTrailingInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppbarTrailingInfoState();
  }
}

class AppbarTrailingInfoState extends State<AppbarTrailingInfo> {
  DateTime _time;
  Timer _timer;

  void _getTime() {
    var now = DateTime.now();
    setState(() {
      _time = now;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  @override
  void initState() {
    super.initState();
    _time = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _formatDateTime(_time),
            textScaleFactor: 2,
          ),
        ),
      ],
    );
  }
}

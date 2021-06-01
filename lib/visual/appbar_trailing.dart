import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppbarTrailingInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppbarTrailingInfoState();
  }
}

class AppbarTrailingInfoState extends State<AppbarTrailingInfo> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: StreamBuilder(
            // This stream is listened to and canceled automatically
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Center(
                child: Text(
                  DateFormat('MM/dd/yyyy hh:mm:ss').format(DateTime.now()),
                  textScaleFactor: 2,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

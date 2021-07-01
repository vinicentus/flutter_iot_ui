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
        StreamBuilder(
          // This stream is listened to and canceled automatically
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            final ThemeData theme = Theme.of(context);
            final ColorScheme colorScheme = theme.colorScheme;
            return Text(
              DateFormat('MM/dd/yyyy hh:mm').format(DateTime.now()),
              // This is the default text size for the AppBar title, so we use it here as well
              style: theme.textTheme.headline6
                  .copyWith(color: colorScheme.onPrimary),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class CheckboxWidget extends StatelessWidget {
  final String text;
  final Color color;
  final bool value;
  final Function callbackFunction;

  const CheckboxWidget(
      {Key key, this.text, this.color, this.value, this.callbackFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
            activeColor: this.color,
            value: this.value,
            onChanged: this.callbackFunction),
        Text(this.text),
      ],
    );
  }
}

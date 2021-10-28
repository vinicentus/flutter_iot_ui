import 'package:flutter/material.dart';

class CheckboxWidget extends StatelessWidget {
  final String text;
  final Color color;
  // The internal Checkbox widget uses a 'bool?' as an internal value,
  // and accepts a function of type 'void Function(bool?)?'.
  // Since this this custom widget doesn't use tri-state checkboxes,
  // we choose to only accept two values, true and false.
  final bool value;
  final void Function(bool)? callbackFunction;

  CheckboxWidget({
    Key? key,
    required this.text,
    required this.color,
    required this.value,
    required this.callbackFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
            activeColor: this.color,
            value: this.value,
            // We need to do this ugly thing because
            // this.callbackFunction is of the wrong type.
            onChanged: (bool? value) {
              if (this.callbackFunction != null) {
                this.callbackFunction!.call(value!);
              }
            }),
        Text(this.text),
      ],
    );
  }
}

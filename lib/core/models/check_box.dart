import 'package:flutter/widgets.dart';

class CheckBoxModel {
  final String text;
  final Color color;
  bool checked;

  CheckBoxModel(this.text, this.color, {this.checked = true});
}

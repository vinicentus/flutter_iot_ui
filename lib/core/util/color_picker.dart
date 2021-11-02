import 'package:flutter/material.dart';

class ColorPicker {
  int _previousIndex = 0;
  final List<Color> colors;

  ColorPicker(this.colors);

  ColorPicker.material() : colors = Colors.primaries;

  Color get next {
    // Increment index, evaulates to _previousIndex +1
    // Reset if over list length
    if (++_previousIndex > colors.length - 1) {
      reset();
    }
    return colors[_previousIndex];
  }

  void reset() => _previousIndex = 0;
}

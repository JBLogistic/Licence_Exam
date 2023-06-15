import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThermalImagePainter extends CustomPainter {
  final List<double> pixels;

  ThermalImagePainter(this.pixels);

  @override
  void paint(Canvas canvas, Size size) {
    double pixelWidth = 26;
    double pixelHeight = 26;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        double temperature = pixels[row * 8 + col];
        Color? color = _getColorFromTemperature(temperature);

        canvas.drawRect(
          Rect.fromLTWH(
            col * pixelWidth,
            row * pixelHeight,
            pixelWidth,
            pixelHeight,
          ),
          Paint()..color = color!,
        );
      }
    }
  }
  Map<double, Color> getTemperatureColors(Color color, double temperature) {
    final hslColor = HSLColor.fromColor(color);

    Map<double, Color> temperatureColors = {};

    // Calculate the lightness value based on the temperature,
    // with lower temperatures resulting in lighter colors
    final lightness = 1.0 - (temperature / 80.0);

    final shade = hslColor.withLightness(lightness).toColor();
    temperatureColors[temperature] = shade;


    return temperatureColors;
  }
  Color? _getColorFromTemperature(double temperature) {
    if(temperature<15.0) {
      Map<double, Color> temperatureShades = getTemperatureColors(
          Colors.blue, temperature);
      Color? temperatureColor = temperatureShades[temperature];
      return temperatureColor;
    }
    if(temperature<40.0) {
      Map<double, Color> temperatureShades = getTemperatureColors(
          Colors.red, temperature);
      Color? temperatureColor = temperatureShades[temperature];
      return temperatureColor;
    }
    if(temperature<80.0) {
      Map<double, Color> temperatureShades = getTemperatureColors(
          Colors.orange, temperature);
      Color? temperatureColor = temperatureShades[temperature];
      return temperatureColor;
    }
    return Colors.white;
  }

  @override
  bool shouldRepaint(ThermalImagePainter oldDelegate) {
    return !identical(oldDelegate.pixels, pixels);
  }
}
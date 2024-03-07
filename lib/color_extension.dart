import 'dart:ui';

extension ColorExtension on Color {
  Color lighten([int percent = 10]) {
    double factor = percent / 100;

    return Color.fromARGB(
      alpha,
      red + ((255 - red) * factor).round(),
      green + ((255 - green) * factor).round(),
      blue + ((255 - blue) * factor).round(),
    );
  }
}

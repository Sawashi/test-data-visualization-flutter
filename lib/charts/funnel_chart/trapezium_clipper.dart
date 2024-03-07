import 'package:flutter/widgets.dart';

class TrapeziumClipper extends CustomClipper<Path> {
  final double factor;

  const TrapeziumClipper(this.factor);

  @override
  Path getClip(Size size) {
    final Path path = Path();

    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2.0 + size.width * factor / 2.0, size.height);
    path.lineTo(size.width / 2.0 - size.width * factor / 2.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TrapeziumClipper oldClipper) => false;
}

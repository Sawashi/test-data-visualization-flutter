import 'package:flutter/widgets.dart';
import 'package:flutter_animated_charts/chart_segment.dart';
import 'package:flutter_animated_charts/charts/pie_chart/angle_calculator.dart';
import 'package:flutter_animated_charts/dimensions.dart';

class PieClipPath extends CustomClipper<Path> {
  final List<ChartSegment> segments;
  final ChartSegment segment;

  PieClipPath({
    required this.segments,
    required this.segment,
  });

  @override
  Path getClip(Size size) {
    AngleCalculator calculator = AngleCalculator(segments: segments, segment: segment);
    double startAngle = calculator.getStartAngle();
    double sweepAngle = calculator.getSweepAngle();
    Offset center = Offset(size.width / 2.0, size.height / 2.0);
    Rect inner = Rect.fromCircle(center: center, radius: size.width / 2.0 - Dimensions.tappable);
    Rect outer = Rect.fromCircle(center: center, radius: size.width / 2.0);
    Path path = Path();

    path.addArc(outer, startAngle, sweepAngle);

    if (segments.length == 1) {
      path.addArc(inner, startAngle + sweepAngle, -sweepAngle);
    } else {
      path.arcTo(inner, startAngle + sweepAngle, -sweepAngle, false);
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

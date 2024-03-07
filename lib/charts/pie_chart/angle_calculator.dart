import 'dart:math' as math;

import 'package:flutter_animated_charts/chart_segment.dart';

class AngleCalculator {
  final List<ChartSegment> segments;
  final ChartSegment segment;

  AngleCalculator({
    required this.segments,
    required this.segment,
  });

  double getStartAngle() {
    double startAngle = -math.pi / 2.0;

    for (ChartSegment skippedSegment in segments) {
      if (skippedSegment == segment) break;

      double sweepAngle = skippedSegment.value / _getTotalValue() * math.pi * 2.0;

      startAngle += sweepAngle;
    }

    return startAngle;
  }

  double getSweepAngle() {
    return segment.value / _getTotalValue() * math.pi * 2.0;
  }

  int _getTotalValue() {
    int totalValue = 0;

    for (ChartSegment segment in segments) {
      totalValue += segment.value;
    }

    return totalValue;
  }
}

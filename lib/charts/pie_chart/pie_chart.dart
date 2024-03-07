import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_animated_charts/chart_controller.dart';
import 'package:flutter_animated_charts/chart_segment.dart';
import 'package:flutter_animated_charts/charts/pie_chart/angle_calculator.dart';
import 'package:flutter_animated_charts/charts/pie_chart/pie_clip_path.dart';
import 'package:flutter_animated_charts/color_extension.dart';
import 'package:flutter_animated_charts/dimensions.dart';

class PieChart extends StatefulWidget {
  final List<ChartSegment> segments;
  final ChartController<ChartSegment>? controller;
  final ValueChanged<List<ChartSegment>>? onSegmentHover;
  final ValueChanged<ChartSegment?>? onSegmentSelect;
  final ValueChanged<ChartSegment>? onSegmentTap;

  const PieChart({
    super.key,
    required this.segments,
    this.controller,
    this.onSegmentHover,
    this.onSegmentSelect,
    this.onSegmentTap,
  });

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  late final ChartController<ChartSegment> _controller;
  late List<ChartSegment> _segments;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ChartController<ChartSegment>();
  }

  @override
  Widget build(BuildContext context) {
    _segments = widget.segments.where((segment) => segment.value != 0).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            ..._segments.map((segment) => _createShadowSegment(segment)).toList(),
            ..._segments.map((segment) => _createSegment(segment)).toList(),
            ..._segments.map((segment) => _createSegmentLabel(segment, constraints.maxWidth, constraints.maxHeight)).toList(),
          ],
        );
      },
    );
  }

  Widget _createShadowSegment(ChartSegment segment) {
    return Positioned.fill(
      child: ClipPath(
        clipper: PieClipPath(segments: _segments, segment: segment),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 250),
              color: _controller.selected == null || segment == _controller.selected ? segment.color : segment.color.lighten(75),
            ),
            onTap: () => _onSegmentTap(segment),
          ),
          onEnter: (_) => _onSegmentHover(segment, true),
          onExit: (_) => _onSegmentHover(segment, false),
        ),
      ),
    );
  }

  Widget _createSegment(ChartSegment segment) {
    return Positioned.fill(
      child: AnimatedScale(
        scale: segment == _controller.selected
            ? 1.1
            : _controller.hovered.contains(segment)
                ? 1.05
                : 1.0,
        curve: Curves.ease,
        duration: const Duration(milliseconds: 250),
        child: ClipPath(
          clipper: PieClipPath(segments: _segments, segment: segment),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: AnimatedContainer(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 250),
                color: _controller.selected == null || segment == _controller.selected ? segment.color : segment.color.lighten(75),
              ),
              onTap: () => _onSegmentTap(segment),
            ),
            onEnter: (_) => _onSegmentHover(segment, true),
            onExit: (_) => _onSegmentHover(segment, false),
          ),
        ),
      ),
    );
  }

  Widget _createSegmentLabel(ChartSegment segment, double chartWidth, double chartHeight) {
    double animationDelta = (segment == _controller.selected
        ? Dimensions.regular
        : _controller.hovered.contains(segment)
            ? Dimensions.regular / 2.0
            : 0.0);

    chartWidth -= Dimensions.tappable - animationDelta;
    chartHeight -= Dimensions.tappable - animationDelta;

    AngleCalculator calculator = AngleCalculator(segments: _segments, segment: segment);
    double startAngle = calculator.getStartAngle();
    double sweepAngle = calculator.getSweepAngle();
    String text = segment.label ?? segment.value.toString();
    TextStyle textStyle = const TextStyle(
      color: Color(0xffffffff),
      fontWeight: FontWeight.w600,
    );
    double textWidth = getTextWidth(text, textStyle);
    double x =
        chartWidth / 2.0 + chartHeight / 2.0 * math.cos(startAngle + sweepAngle / 2.0) - textWidth / 2.0 + Dimensions.tappable / 2.0 - animationDelta / 2.0;
    double y = chartWidth / 2.0 +
        chartHeight / 2.0 * math.sin(startAngle + sweepAngle / 2.0) -
        Dimensions.text / 2.0 +
        Dimensions.tappable / 2.0 -
        animationDelta / 2.0;

    return AnimatedPositioned(
      left: x,
      top: y,
      curve: Curves.ease,
      duration: const Duration(milliseconds: 250),
      child: IgnorePointer(
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }

  double getTextWidth(String text, TextStyle style) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      maxLines: 1,
    )..layout();

    return textPainter.size.width;
  }

  void _onSegmentTap(ChartSegment segment) {
    setState(() {
      if (segment == _controller.selected) {
        _controller.selected = null;
      } else {
        _controller.selected = segment;
      }
    });

    widget.onSegmentSelect?.call(_controller.selected);
    widget.onSegmentTap?.call(segment);
  }

  void _onSegmentHover(ChartSegment segment, bool isHovered) {
    setState(() {
      if (isHovered) {
        _controller.hovered.add(segment);
      } else {
        _controller.hovered.remove(segment);
      }
    });

    widget.onSegmentHover?.call(_controller.hovered);
  }
}

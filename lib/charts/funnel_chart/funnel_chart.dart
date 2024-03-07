import 'package:flutter/widgets.dart';
import 'package:flutter_animated_charts/chart_controller.dart';
import 'package:flutter_animated_charts/chart_segment.dart';
import 'package:flutter_animated_charts/charts/funnel_chart/trapezium_clipper.dart';
import 'package:flutter_animated_charts/color_extension.dart';
import 'package:flutter_animated_charts/dimensions.dart';

class FunnelChart extends StatefulWidget {
  final List<ChartSegment> segments;
  final ChartController<ChartSegment>? controller;
  final ValueChanged<List<ChartSegment>>? onSegmentHover;
  final ValueChanged<ChartSegment?>? onSegmentSelect;
  final ValueChanged<ChartSegment>? onSegmentTap;

  const FunnelChart({
    super.key,
    required this.segments,
    this.controller,
    this.onSegmentHover,
    this.onSegmentSelect,
    this.onSegmentTap,
  });

  @override
  State<FunnelChart> createState() => _FunnelChartState();
}

class _FunnelChartState extends State<FunnelChart> {
  late final ChartController<ChartSegment> _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ChartController<ChartSegment>();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.segments.map((segment) => _createSegment(segment, constraints.maxWidth)).toList(),
        );
      },
    );
  }

  Widget _createSegment(ChartSegment segment, double chartWidth) {
    ChartSegment? nextSegment = _getNextSegment(segment);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            _createSegmentBar(segment, chartWidth),
            if (nextSegment != null) _createSegmentTransition(segment, nextSegment, chartWidth),
          ],
        ),
        Positioned(
          left: 0.0,
          top: 0.0,
          right: 0.0,
          child: _createSegmentLabel(segment, chartWidth),
        ),
      ],
    );
  }

  Widget _createSegmentBar(ChartSegment segment, double chartWidth) {
    return AnimatedScale(
      scale: segment == _controller.selected
          ? 1.1
          : _controller.hovered.contains(segment)
              ? 1.05
              : 1.0,
      curve: Curves.ease,
      duration: const Duration(milliseconds: 250),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: AnimatedContainer(
            curve: Curves.ease,
            duration: const Duration(milliseconds: 250),
            color: _controller.selected == null || segment == _controller.selected ? segment.color : segment.color.lighten(75),
            width: _getSegmentWidth(segment, chartWidth),
            height: Dimensions.tappable,
          ),
          onTap: () => _onSegmentTap(segment),
        ),
        onEnter: (_) => _onSegmentHover(segment, true),
        onExit: (_) => _onSegmentHover(segment, false),
      ),
    );
  }

  Widget _createSegmentTransition(ChartSegment segment, ChartSegment nextSegment, double chartWidth) {
    return ClipPath(
      clipper: TrapeziumClipper(nextSegment.value / segment.value),
      child: Container(
        color: segment.color.withOpacity(0.15),
        width: _getSegmentWidth(segment, chartWidth),
        height: Dimensions.regular,
      ),
    );
  }

  Widget _createSegmentLabel(ChartSegment segment, double chartWidth) {
    return IgnorePointer(
      child: Container(
        alignment: Alignment.center,
        height: Dimensions.tappable,
        child: Text(
          segment.value.toString(),
          style: const TextStyle(
            color: Color(0xffffffff),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  double _getSegmentWidth(ChartSegment segment, double chartWidth) {
    double segmentWidth = segment.value / _getMaxValue() * chartWidth;

    if (segmentWidth < Dimensions.regular / 4.0) return Dimensions.regular / 4.0;

    return segmentWidth;
  }

  int _getMaxValue() {
    return widget.segments.reduce((current, next) => current.value > next.value ? current : next).value;
  }

  ChartSegment? _getNextSegment(ChartSegment segment) {
    for (int i = 0; i != widget.segments.length; i++) {
      if (widget.segments[i] == segment) {
        if (i < widget.segments.length - 1) {
          return widget.segments[i + 1];
        }
      }
    }

    return null;
  }

  void _onSegmentTap(ChartSegment segment) {
    setState(() {
      if (segment == _controller.selected) {
        _controller.selected = null;
      } else {
        _controller.selected = segment;
      }
    });

    widget.onSegmentTap?.call(segment);
    widget.onSegmentSelect?.call(_controller.selected);
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

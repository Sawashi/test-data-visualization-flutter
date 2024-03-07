import 'package:flutter/material.dart';
import 'package:flutter_animated_charts/chart_point.dart';
import 'package:flutter_animated_charts/chart_segment.dart';
import 'package:flutter_animated_charts/charts/funnel_chart/funnel_chart.dart';
import 'package:flutter_animated_charts/charts/line_chart/line_chart.dart';
import 'package:flutter_animated_charts/charts/pie_chart/pie_chart.dart';
import 'package:flutter_animated_charts/color_extension.dart';
import 'package:flutter_animated_charts/dimensions.dart';
import 'package:flutter_animated_charts/palette.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Animated Charts',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final List<ChartSegment> _chartSegments = [
    ChartSegment(1, value: 1500, color: Palette.colors[1]),
    ChartSegment(2, value: 700, color: Palette.colors[3]),
    ChartSegment(3, value: 450, color: Palette.colors[5]),
    ChartSegment(4, value: 225, color: Palette.colors[8]),
    ChartSegment(5, value: 100, color: Palette.colors[10]),
  ];

  static final DateTime _date = DateTime(2023, 07, 20);

  static final List<ChartPoint> _chartPoints = [
    ChartPoint(x: _date, y: 500),
    ChartPoint(x: _date.add(const Duration(days: 1)), y: 1500),
    ChartPoint(x: _date.add(const Duration(days: 2)), y: 250),
    ChartPoint(x: _date.add(const Duration(days: 3)), y: 750),
    ChartPoint(x: _date.add(const Duration(days: 4)), y: 50),
  ];

  int _chartTypeIndex = 0;
  ChartPoint? _hoveredChartPoint;
  ChartPoint? _selectedChartPoint;
  ChartSegment? _hoveredChartSegment;
  ChartSegment? _selectedChartSegment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _createChart(),
          if (_selectedChartPoint == null && _hoveredChartPoint != null)
            Positioned(
              right: Dimensions.regular / 2.0,
              top: Dimensions.regular / 2.0,
              child: _createHoveredChartPoint(),
            ),
          if (_selectedChartPoint != null)
            Positioned(
              right: Dimensions.regular / 2.0,
              top: Dimensions.regular / 2.0,
              child: _createSelectedChartPoint(),
            ),
          if (_selectedChartSegment == null && _hoveredChartSegment != null)
            Positioned(
              right: Dimensions.regular / 2.0,
              top: Dimensions.regular / 2.0,
              child: _createHoveredChartSegment(),
            ),
          if (_selectedChartSegment != null)
            Positioned(
              right: Dimensions.regular / 2.0,
              top: Dimensions.regular / 2.0,
              child: _createSelectedChartSegment(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.line_axis),
            label: 'Line',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Pie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_alt),
            label: 'Funnel',
          ),
        ],
        currentIndex: _chartTypeIndex,
        onTap: _onChartTypeIndexChange,
      ),
    );
  }

  Widget _createChart() {
    if (_chartTypeIndex == 1) return _createPieChart();

    if (_chartTypeIndex == 2) return _createFunnelChart();

    return _createLineChart();
  }

  Widget _createLineChart() {
    return LineChart(
      xAxisLabel: 'Date',
      yAxisLabel: 'Sum',
      points: _chartPoints,
      onPointHover: _onChartPointHover,
      onPointSelect: _onChartPointSelect,
    );
  }

  Widget _createPieChart() {
    return Center(
      child: SizedBox.square(
        dimension: MediaQuery.of(context).size.shortestSide - Dimensions.tappable * 3.0,
        child: PieChart(
          segments: _chartSegments,
          onSegmentHover: _onChartSegmentHover,
          onSegmentSelect: _onChartSegmentSelect,
        ),
      ),
    );
  }

  Widget _createFunnelChart() {
    return Center(
      child: SizedBox.square(
        dimension: MediaQuery.of(context).size.shortestSide - Dimensions.tappable * 3.0,
        child: FunnelChart(
          segments: _chartSegments,
          onSegmentHover: _onChartSegmentHover,
          onSegmentSelect: _onChartSegmentSelect,
        ),
      ),
    );
  }

  Widget _createHoveredChartPoint() {
    return _createCurrentValue('Hovered X: ${DateFormat.yMMMMd().format(_hoveredChartPoint!.x)}, Y: ${_hoveredChartPoint!.y.toString()}');
  }

  Widget _createSelectedChartPoint() {
    return _createCurrentValue('Selected X: ${DateFormat.yMMMMd().format(_selectedChartPoint!.x)}, Y: ${_selectedChartPoint!.y.toString()}');
  }

  Widget _createHoveredChartSegment() {
    return _createCurrentValue('Hovered: ${_hoveredChartSegment!.value.toString()}');
  }

  Widget _createSelectedChartSegment() {
    return _createCurrentValue('Selected: ${_selectedChartSegment!.value.toString()}');
  }

  Widget _createCurrentValue(String currentValue) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.regular / 4.0),
      decoration: BoxDecoration(
        color: Palette.colors[3].lighten(50),
        borderRadius: BorderRadius.circular(Dimensions.regular / 4.0),
      ),
      child: Text(
        currentValue,
        style: const TextStyle(
          fontSize: Dimensions.text * 1.25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _onChartTypeIndexChange(int chartTypeIndex) {
    _hoveredChartPoint = _selectedChartPoint = _hoveredChartSegment = _selectedChartSegment = null;
    setState(() => _chartTypeIndex = chartTypeIndex);
  }

  void _onChartPointHover(List<ChartPoint> chartPoints) {
    setState(() {
      _hoveredChartPoint = chartPoints.firstOrNull;
    });
  }

  void _onChartPointSelect(ChartPoint? chartPoint) {
    setState(() {
      _selectedChartPoint = chartPoint;
    });
  }

  void _onChartSegmentHover(List<ChartSegment> chartSegments) {
    setState(() {
      _hoveredChartSegment = chartSegments.firstOrNull;
    });
  }

  void _onChartSegmentSelect(ChartSegment? chartSegment) {
    setState(() {
      _selectedChartSegment = chartSegment;
    });
  }
}

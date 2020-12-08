import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_money/models/vector2.dart';

class BalanceLineChart extends StatefulWidget {
  final double maxX;
  final double maxY;
  final List<Vector2> spots;

  const BalanceLineChart({
    Key key,
    this.maxX,
    this.maxY,
    this.spots,
  }) : super(key: key);

  @override
  _BalanceLineChartState createState() => _BalanceLineChartState();
}

class _BalanceLineChartState extends State<BalanceLineChart> {
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: LineChart(mainData()),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      titlesData: _buildTitles(),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 1,
      maxX: widget.maxX,
      minY: 0,
      maxY: widget.maxY,
      lineBarsData: _buildData(),
    );
  }

  _buildData() {
    final list = widget.spots.map((item) => FlSpot(item.x, item.y)).toList();
    return [
      LineChartBarData(
        spots: list.isEmpty ? [FlSpot(0, 0)] : list,
        isCurved: true,
        colors: gradientColors,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors:
              gradientColors.map((color) => color.withOpacity(0.3)).toList(),
        ),
      ),
    ];
  }

  _buildTitles() {
    return FlTitlesData(
      show: true,
      leftTitles: SideTitles(),
      bottomTitles: SideTitles(
        showTitles: true,
        getTitles: (value) {
          return value.toString();
        },
        margin: 8,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatefulWidget {
  final List<FlSpot> spots;
  final double minY;
  final double maxY;
  final String monthLabel; // Change from int to String

  const LineChartWidget({
    super.key,
    required this.spots,
    required this.minY,
    required this.maxY,
    required this.monthLabel, // Update the parameter type
  });

  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  Offset? _tooltipPosition;
  FlSpot? _tooltipSpot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 300,
          child: Stack(
            children: [
              GestureDetector(
                onTapUp: (details) {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);
                  double x = localPosition.dx;

                  double chartX = (x / renderBox.size.width) *
                          (widget.spots.last.x - widget.spots.first.x) +
                      widget.spots.first.x;

                  FlSpot? closestSpot = _findClosestSpot(chartX);
                  if (closestSpot != null) {
                    setState(() {
                      _tooltipPosition = localPosition;
                      _tooltipSpot = closestSpot;
                    });
                  }
                },
                onTapCancel: () {
                  setState(() {
                    _tooltipPosition = null;
                    _tooltipSpot = null;
                  });
                },
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Container(
                              margin: EdgeInsets.only(left: 4),
                              child: Text(
                                _formatValue(value),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontFamily: 'Arial',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: widget.spots
                            .map((spot) => spot.x)
                            .reduce((a, b) => a < b ? a : b) -
                        0.5,
                    maxX: widget.spots
                            .map((spot) => spot.x)
                            .reduce((a, b) => a > b ? a : b) +
                        0.5,
                    minY: 0,
                    maxY: widget.maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: widget.spots,
                        isCurved: true,
                        color: Colors.green,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.white10,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_tooltipPosition != null && _tooltipSpot != null)
                Positioned(
                  left: _tooltipPosition!.dx,
                  top: _tooltipPosition!.dy -
                      40, // Adjust the position above the tap
                  child: _buildTooltip(_tooltipSpot!),
                ),
            ],
          ),
        ),
        SizedBox(height: 8), // Add some space between the graph and the label
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 20,
          ),
          Text(
            widget.monthLabel, // Use the complete month label directly
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontFamily: 'Arial',
            ),
          )
        ]),
      ],
    );
  }

  FlSpot? _findClosestSpot(double x) {
    FlSpot? closestSpot;
    double closestDistance = double.infinity;

    for (var spot in widget.spots) {
      double distance = (spot.x - x).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestSpot = spot;
      }
    }

    return closestSpot;
  }

  Widget _buildTooltip(FlSpot spot) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'X: ${spot.x}\nY: ${spot.y}',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

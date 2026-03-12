import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> gradeData;

  const BarChartWidget(this.gradeData, {Key? key}) : super(key: key);

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.gradeData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    List<BarChartGroupData> buildGroups(double factor) {
      return widget.gradeData.asMap().entries.map((e) {
        final index = e.key;
        final data = e.value;
        final count = (data['count'] ?? 0).toDouble() * factor;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count,
              width: 18,
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 139, 37, 235), Color.fromARGB(255, 181, 96, 250)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ],
        );
      }).toList();
    }

    final dataSignature = widget.gradeData
        .map((e) => '${e['grade']}:${e['count']}')
        .join('|');

    final hoverScale = _isHovered ? 1.3 : 1.0;

    return TweenAnimationBuilder<double>(
      key: ValueKey(dataSignature),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            scale: hoverScale,
            child: SizedBox(
              height: 300,
              child: BarChart(
            BarChartData(
              barGroups: buildGroups(value),
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => const Color.fromARGB(255, 68, 45, 90),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value % 5 != 0) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < widget.gradeData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            widget.gradeData[value.toInt()]['grade']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
            ),
          ),
        );
      },
    );
  }
}
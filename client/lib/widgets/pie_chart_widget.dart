import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> roleData;

  const PieChartWidget(this.roleData, {Key? key}) : super(key: key);

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.roleData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFF16A34A),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF0EA5E9),
    ];

    List<PieChartSectionData> buildSections(double factor) {
      return widget.roleData.asMap().entries.map((e) {
        final index = e.key;
        final data = e.value;
        final value = (data['count'] ?? 0).toDouble() * factor;

        return PieChartSectionData(
          color: colors[index % colors.length],
          value: value,
          title: value == 0 ? '' : value.toStringAsFixed(0),
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        );
      }).toList();
    }

    final legendItems = widget.roleData.asMap().entries.map((e) {
      final index = e.key;
      final data = e.value;

      return _LegendItem(
        color: colors[index % colors.length],
        label: (data['role_name'] ?? 'Unknown').toString(),
        value: (data['count'] ?? 0).toString(),
      );
    }).toList();

    final dataSignature = widget.roleData
        .map((e) => '${e['role_name']}:${e['count']}')
        .join('|');

    final hoverScale = _isHovered ? 1.04 : 1.0;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 520;

                return isWide
                ? Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 240,
                          child: PieChart(
                            PieChartData(
                              sections: buildSections(value),
                              sectionsSpace: 4,
                              centerSpaceRadius: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: legendItems,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 240,
                        child: PieChart(
                          PieChartData(
                            sections: buildSections(value),
                            sectionsSpace: 4,
                            centerSpaceRadius: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: legendItems,
                      ),
                    ],
                  );
              },
            ),
          ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
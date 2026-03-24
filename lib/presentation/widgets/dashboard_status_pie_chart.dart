import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/dashboard.dart';

class DashboardStatusPieChart extends StatelessWidget {
  const DashboardStatusPieChart({super.key, required this.items});

  final List<StatusShare> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No status data'));
    }

    final colors = <String, Color>{
      'active': const Color(0xFF22A06B),
      'maintenance': const Color(0xFFF59E0B),
      'idle': const Color(0xFF64748B),
    };

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 38,
              sections: items.map((item) {
                final color = colors[item.status.toLowerCase()] ??
                    Theme.of(context).colorScheme.primary;

                return PieChartSectionData(
                  value: item.value.toDouble(),
                  radius: 56,
                  color: color,
                  title: '${item.value}',
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: items.map((item) {
            final color = colors[item.status.toLowerCase()] ??
                Theme.of(context).colorScheme.primary;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text('${item.status} (${item.value})'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../data/mood_repository.dart';
import '../../../shared/widgets/app_surface.dart';

class MoodTrendChart extends StatelessWidget {
  final List<MoodEntry> entries;

  const MoodTrendChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (entries.isEmpty) {
      return AppSurface(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Text(
            'No mood data for the last 30 days.\nTrack your mood to see trends!',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    // Sort by date ascending for the chart, filtering out pending local entries (null timestamp)
    final validEntries = entries.where((e) => e.createdAt != null).toList();
    if (validEntries.isEmpty) {
      return AppSurface(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Text(
            'Saving your mood...',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    
    final sortedEntries = validEntries
      ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    return AppSurface(
      child: Container(
        height: 250,
        padding:
            const EdgeInsets.only(right: 24, left: 12, top: 24, bottom: 12),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= sortedEntries.length) {
                      return const SizedBox.shrink();
                    }
                    // Only show a few labels to avoid crowding
                    if (index % (sortedEntries.length / 4).ceil() != 0 &&
                        index != sortedEntries.length - 1) {
                      return const SizedBox.shrink();
                    }
                    final date = sortedEntries[index].createdAt ?? DateTime.now();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MMM d').format(date),
                        style: TextStyle(
                            fontSize: 10, color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  },
                  interval: 1,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                          fontSize: 10, color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.right,
                    );
                  },
                  reservedSize: 28,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (sortedEntries.length - 1).toDouble(),
            minY: 1,
            maxY: 5,
            lineBarsData: [
              LineChartBarData(
                spots: sortedEntries.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.moodScore.toDouble());
                }).toList(),
                isCurved: true,
                color: colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.3),
                      colorScheme.primary.withValues(alpha: 0.0),
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
    );
  }
}

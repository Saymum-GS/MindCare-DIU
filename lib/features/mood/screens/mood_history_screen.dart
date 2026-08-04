import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../data/mood_repository.dart';
import '../providers/mood_providers.dart';
import '../../../core/theme/app_colors.dart';

import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading_state.dart';

class MoodHistoryScreen extends ConsumerWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(moodHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History'),
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const AppEmptyState(
              icon: Icons.mood_bad_outlined,
              title: 'No mood history found.',
              message: 'Check in on your mood to start seeing your trend.',
            );
          }

          // Sort entries by date ascending for the chart, handling potential nulls
          final validEntries = entries.where((e) => e.createdAt != null).toList();
          if (validEntries.isEmpty) {
            return const AppEmptyState(
              icon: Icons.mood_bad_outlined,
              title: 'No mood history found.',
              message: 'Check in on your mood to start seeing your trend.',
            );
          }
          final sortedEntries = List<MoodEntry>.from(validEntries)
            ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Your 30-Day Trend',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: AppSurface(
                    padding: const EdgeInsets.all(24),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < sortedEntries.length) {
                                  final date =
                                      sortedEntries[value.toInt()].createdAt ?? DateTime.now();
                                  return Text(DateFormat('d MMM').format(date),
                                      style: const TextStyle(fontSize: 10));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: sortedEntries.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(),
                                  e.value.moodScore.toDouble());
                            }).toList(),
                            isCurved: true,
                            color: AppColors.blue600,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.blue100.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                        minY: 1,
                        maxY: 5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedEntries.reversed.length,
                    itemBuilder: (context, index) {
                      final entry = sortedEntries.reversed.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AppSurface(
                          padding: const EdgeInsets.all(0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.blue50,
                              child: Text('${entry.moodScore}',
                                  style: const TextStyle(
                                      color: AppColors.blue600,
                                      fontWeight: FontWeight.bold)),
                            ),
                            title: Text(
                                DateFormat('EEEE, MMM d, yyyy')
                                    .format(entry.createdAt ?? DateTime.now()),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle:
                                entry.note != null ? Text(entry.note!) : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const AppLoadingState(),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

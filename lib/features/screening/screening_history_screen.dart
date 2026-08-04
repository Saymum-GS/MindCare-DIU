// lib/features/screening/screening_history_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/risk_engine.dart';

import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading_state.dart';

class ScreeningHistoryScreen extends StatelessWidget {
  const ScreeningHistoryScreen({super.key});

  Color _riskColor(String r) => r == 'red'
      ? AppColors.riskRedFg
      : r == 'yellow'
          ? AppColors.riskYellowFg
          : AppColors.riskGreenFg;
  Color _riskBg(String r) => r == 'red'
      ? AppColors.riskRedBg
      : r == 'yellow'
          ? AppColors.riskYellowBg
          : AppColors.riskGreenBg;
  String _riskLabel(String r) => r == 'red'
      ? '🔴 High Risk'
      : r == 'yellow'
          ? '🟡 Moderate'
          : '🟢 Low Risk';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening History'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestorePaths.screenings)
            .where('studentUid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: AppLoadingState(itemCount: 4));
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const AppEmptyState(
              icon: Icons.assignment_outlined,
              title: 'No screenings yet.',
              message:
                  'Complete a PHQ9 or GAD7 from the Screening tab to see results here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final date = (d['createdAt'] as Timestamp?)?.toDate();
              final instrument = d['instrument'] as String? ?? 'PHQ9';
              final score = (d['totalScore'] as num?)?.toInt() ?? 0;
              final severity = d['severity'] as String? ?? 'minimal';
              final riskLevel = d['riskLevel'] as String? ?? 'green';
              final maxScore = instrument == 'PHQ9' ? 27 : 21;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppSurface(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _riskBg(riskLevel),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$score',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: _riskColor(riskLevel))),
                              Text('/$maxScore',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: _riskColor(riskLevel)
                                          .withValues(alpha: 0.7))),
                            ]),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  instrument == 'PHQ9'
                                      ? 'Depression (PHQ9)'
                                      : 'Anxiety (GAD7)',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(RiskEngine.severityDisplayLabel(severity),
                                  style: const TextStyle(
                                      color: AppColors.gray600, fontSize: 13)),
                              if (date != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                    DateFormat('MMM d, yyyy · h:mm a')
                                        .format(date),
                                    style: const TextStyle(
                                        color: AppColors.gray500,
                                        fontSize: 11)),
                              ],
                            ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: _riskBg(riskLevel),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(_riskLabel(riskLevel),
                            style: TextStyle(
                                color: _riskColor(riskLevel),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

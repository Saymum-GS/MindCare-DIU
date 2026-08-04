// lib/features/admin/admin_verify_student_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/admin_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/widgets/app_empty_state.dart';

class AdminVerifyStudentScreen extends ConsumerWidget {
  const AdminVerifyStudentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingStudentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: const Text('Verify Students',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: pendingAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const AppEmptyState(
              icon: Icons.verified_user_rounded,
              title: 'No pending verifications',
              message: 'All student IDs have been reviewed.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.gray200),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.amber50,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (student.displayName.isNotEmpty ? student.displayName : (student.email ?? student.pseudonym))[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: AppColors.amber600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.displayName.isNotEmpty ? student.displayName : (student.email ?? student.pseudonym),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.gray900)),
                                if (student.studentId != null && student.studentId!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text('Student ID: ${student.studentId}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? AppColors.gray300 : AppColors.gray600)),
                                ],
                                if (student.email != null && student.email!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(student.email!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? AppColors.gray300 : AppColors.gray600)),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.school_rounded,
                                        size: 14, color: AppColors.amber600),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Requests free DIU access',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.amber600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(adminRepositoryProvider)
                                    .updateDiuStatus(student.uid, false);
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('Reject'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.red500,
                                side: const BorderSide(color: AppColors.red500),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(adminRepositoryProvider)
                                    .updateDiuStatus(student.uid, true);
                              },
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Approve'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.sage600,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: AppLoadingState(itemCount: 4)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

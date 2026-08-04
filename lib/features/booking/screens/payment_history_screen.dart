import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/widgets/app_empty_state.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestorePaths.bookings)
            .where('studentUid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const AppLoadingState();

          final docs = snapshot.data!.docs;
          final paidDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['paymentStatus'] == 'completed' &&
                (data['paymentAmountBdt'] as num?) != null &&
                (data['paymentAmountBdt'] as num) > 0;
          }).toList();

          if (paidDocs.isEmpty) {
            return const Center(
              child: AppEmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No payment history',
                message: 'You have not made any payments yet.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            itemCount: paidDocs.length,
            itemBuilder: (context, index) {
              final data = paidDocs[index].data() as Map<String, dynamic>;
              final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              final amount = (data['paymentAmountBdt'] as num?)?.toInt() ?? 0;
              final transactionId = data['paymentReference'] as String? ?? 'N/A';
              final method = data['paymentMethod'] as String? ?? 'Unknown';

              return AppSurface(
                margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.blue900.withValues(alpha: 0.3)
                            : AppColors.blue50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long_rounded,
                          color:
                              isDark ? AppColors.blue400 : AppColors.blue600),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                method,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '৳$amount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.blue500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TXN: $transactionId',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM d, yyyy • h:mm a').format(date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

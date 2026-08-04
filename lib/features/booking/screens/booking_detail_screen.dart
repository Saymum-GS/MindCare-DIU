import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_colors.dart';

import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_loading_state.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':
        return AppColors.riskGreenFg;
      case 'pending':
        return AppColors.riskYellowFg;
      case 'reschedule_requested':
        return AppColors.amber600;
      case 'completed':
        return AppColors.blue500;
      case 'cancelled':
        return AppColors.riskRedFg;
      default:
        return AppColors.gray500;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'confirmed':
        return AppColors.riskGreenBg;
      case 'pending':
        return AppColors.riskYellowBg;
      case 'reschedule_requested':
        return AppColors.amber50;
      case 'completed':
        return AppColors.blue50;
      case 'cancelled':
        return AppColors.riskRedBg;
      default:
        return AppColors.gray100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection(FirestorePaths.bookings)
            .doc(bookingId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Booking not found.'));
          }

          final d = snapshot.data!.data() as Map<String, dynamic>;
          final slotStart = (d['slotStart'] as Timestamp?)?.toDate();
          final status = d['status'] as String? ?? 'pending';
          final psychName = d['psychologistName'] as String? ?? 'Psychologist';
          final meetLink = d['meetLink'] as String? ?? '';
          final sessionType = d['sessionType'] as String? ?? 'video';
          final fee = (d['paymentAmountBdt'] as num?)?.toInt() ?? 0;
          final isDiu = d['isDiuStudent'] as bool? ?? false;
          final carePlan = d['sharedCarePlan'] as Map<String, dynamic>?;

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AppSurface(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status',
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSub
                                    : AppColors.gray600,
                                fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: _statusBg(status),
                              borderRadius: BorderRadius.circular(6)),
                         child: Text(
                              status == 'reschedule_requested'
                                  ? 'RESCHEDULE PENDING'
                                  : status.toUpperCase(),
                              style: TextStyle(
                                  color: _statusColor(status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text('Psychologist',
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSub
                                : AppColors.gray600,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(psychName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    if (slotStart != null) ...[
                      Text('Date & Time',
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSub
                                  : AppColors.gray600,
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                          DateFormat('EEEE, MMMM d, yyyy • h:mm a')
                              .format(slotStart),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 16),
                    ],
                    Text('Session Details',
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSub
                                : AppColors.gray600,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                        '50 minutes · ${sessionType == 'in_person' ? 'IN-PERSON (DIU CAMPUS)' : sessionType.toUpperCase()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 16),
                    Text('Payment',
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSub
                                : AppColors.gray600,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(isDiu ? 'Free (DIU Student)' : '৳$fee',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDiu
                                ? AppColors.riskGreenFg
                                : (isDark ? Colors.white : AppColors.gray900))),
                  ],
                ),
              ),
              if (carePlan != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sage600.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.sage600.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.medical_services_outlined, color: AppColors.sage600, size: 22),
                          SizedBox(width: 8),
                          Text("Doctor's Recommendations & Care Plan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.sage600)),
                        ],
                      ),
                      const Divider(height: 20),
                      if ((carePlan['exercises'] ?? '').toString().isNotEmpty) ...[
                        const Text('Recommended Action / Exercises:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(carePlan['exercises'], style: TextStyle(fontSize: 13, color: isDark ? AppColors.gray300 : AppColors.gray700)),
                        const SizedBox(height: 10),
                      ],
                      if ((carePlan['followUp'] ?? '').toString().isNotEmpty) ...[
                        const Text('Next Follow-up Advice:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(carePlan['followUp'], style: TextStyle(fontSize: 13, color: isDark ? AppColors.gray300 : AppColors.gray700)),
                        const SizedBox(height: 10),
                      ],
                      if ((carePlan['referral'] ?? '').toString().isNotEmpty) ...[
                        const Text('Additional Notes / Referral:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(carePlan['referral'], style: TextStyle(fontSize: 13, color: isDark ? AppColors.gray300 : AppColors.gray700)),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (sessionType == 'in_person') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.blue500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.blue500.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.business_rounded, color: AppColors.blue500, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'In-Person Campus Appointment',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.blue500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please arrive 10 minutes prior to your session time at the DIU Counseling Center (DSC Campus / Room 302 or assigned psychologist office).',
                              style: TextStyle(fontSize: 13, color: isDark ? AppColors.gray300 : AppColors.gray700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (status == 'confirmed' && meetLink.isNotEmpty) ...[
                FilledButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(meetLink);
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Join Google Meet'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.riskGreenFg,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (status == 'reschedule_requested') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.amber600.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.amber600.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.update_rounded, color: AppColors.amber600, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reschedule Requested — Your request is being reviewed by the psychologist/counseling center.',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.amber600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (status == 'pending' || status == 'confirmed') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          if (slotStart != null && slotStart.difference(now).inHours < 24) {
                            showDialog(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Cannot Reschedule'),
                                content: const Text(
                                    'You can\'t reschedule within 24 hours remaining of the booking. Please contact the counseling center directly if you have an emergency.'),
                                actions: [
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: AppColors.amber600),
                                    onPressed: () => Navigator.pop(c),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          final reasonCtrl = TextEditingController();
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Request Reschedule?'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Please state why you need to reschedule this appointment (e.g. exam clash, illness):'),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: reasonCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'Enter reason...',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text('Cancel')),
                                FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.amber600),
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Submit Request'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true && reasonCtrl.text.trim().isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection(FirestorePaths.bookings)
                                .doc(bookingId)
                                .update({
                              'status': 'reschedule_requested',
                              'rescheduleReason': reasonCtrl.text.trim(),
                            });
                          }
                        },
                        icon: const Icon(Icons.edit_calendar_rounded),
                        label: const Text('Reschedule'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.amber600,
                          side: const BorderSide(color: AppColors.amber600),
                          minimumSize: const Size(0, 52),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          if (slotStart != null && slotStart.difference(now).inHours < 24) {
                            showDialog(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Cannot Cancel Booking'),
                                content: const Text(
                                    'You can\'t cancel it within 24 hours remaining of the booking. Please contact the counseling center directly if you have an emergency.'),
                                actions: [
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: AppColors.red500),
                                    onPressed: () => Navigator.pop(c),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Cancel Session?'),
                              content: const Text(
                                  'This will cancel your booking. The slot will be freed.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text('Keep')),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.red500),
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Cancel Booking'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await FirebaseFirestore.instance
                                .collection(FirestorePaths.bookings)
                                .doc(bookingId)
                                .update({'status': 'cancelled'});
                            final slots = await FirebaseFirestore.instance
                                .collection(FirestorePaths.psychologistSlots)
                                .where('bookingId', isEqualTo: bookingId)
                                .get();
                            for (final d in slots.docs) {
                              await d.reference.update({
                                'isBooked': false,
                                'bookedByUid': null,
                                'bookingId': null,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });
                            }
                            if (context.mounted) context.pop();
                          }
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red500,
                          side: const BorderSide(color: AppColors.red500),
                          minimumSize: const Size(0, 52),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Policy: Reschedule or cancellation requests should be submitted at least 24h prior.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.gray400 : AppColors.gray600, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

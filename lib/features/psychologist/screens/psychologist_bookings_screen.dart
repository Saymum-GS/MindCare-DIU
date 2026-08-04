// lib/features/psychologist/screens/psychologist_bookings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading_state.dart';

class PsychologistBookingsScreen extends StatefulWidget {
  const PsychologistBookingsScreen({super.key});
  @override
  State<PsychologistBookingsScreen> createState() =>
      _PsychologistBookingsScreenState();
}

class _PsychologistBookingsScreenState extends State<PsychologistBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _bookingsStream(bool upcoming) {
    final query = FirebaseFirestore.instance
        .collection(FirestorePaths.bookings)
        .where('psychologistUid', isEqualTo: _uid);

    if (upcoming) {
      return query
          .where('status', whereIn: ['pending', 'confirmed', 'reschedule_requested'])
          .orderBy('slotStart')
          .snapshots();
    } else {
      return query
          .where('status', whereIn: ['completed', 'cancelled'])
          .orderBy('slotStart', descending: true)
          .snapshots();
    }
  }

  Future<void> _updateMeetLink(String bookingId, String currentLink) async {
    final controller = TextEditingController(text: currentLink);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Google Meet Link',
              style:
                  TextStyle(color: isDark ? Colors.white : AppColors.gray900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://meet.google.com/new');
                  if (await canLaunchUrl(uri)) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.add_link_rounded, size: 18),
                label: const Text('Create New Meet (Opens Browser)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(
                      color: AppColors.blue500.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                style:
                    TextStyle(color: isDark ? Colors.white : AppColors.gray900),
                decoration: InputDecoration(
                  hintText: 'Paste link: https://meet.google.com/...',
                  hintStyle: TextStyle(
                      color: isDark ? AppColors.gray400 : AppColors.gray500),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface2 : AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.video_call_rounded,
                      color: AppColors.blue500),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(
                      color: isDark ? AppColors.gray400 : AppColors.gray600)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue500,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save Link'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.bookings)
          .doc(bookingId)
          .update({'meetLink': result, 'status': 'confirmed'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: const Text('My Bookings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.gray200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]),
            child: TabBar(
              controller: _tabs,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor:
                  isDark ? AppColors.gray400 : AppColors.gray600,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past History'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _BookingList(
                    stream: _bookingsStream(true),
                    upcoming: true,
                    onSetMeetLink: _updateMeetLink),
                _BookingList(
                    stream: _bookingsStream(false),
                    upcoming: false,
                    onSetMeetLink: _updateMeetLink),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final bool upcoming;
  final Future<void> Function(String bookingId, String currentLink)
      onSetMeetLink;

  const _BookingList({
    required this.stream,
    required this.upcoming,
    required this.onSetMeetLink,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error loading sessions:\n\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.red500),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: AppLoadingState(itemCount: 4));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: AppEmptyState(
              icon: upcoming
                  ? Icons.event_available_rounded
                  : Icons.history_rounded,
              title: upcoming ? 'No upcoming bookings' : 'No past sessions',
              message: upcoming
                  ? 'Students will appear here\nonce they book a slot.'
                  : 'Completed sessions will\nappear in this tab.',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final bookingId = docs[index].id;
            final slotStart = (data['slotStart'] as Timestamp?)?.toDate();
            final status = data['status'] as String? ?? 'pending';
            final meetLink = data['meetLink'] as String? ?? '';
            final studentName = data['studentName'] as String? ??
                data['studentPseudonym'] as String? ??
                'Student';
            final sessionType = data['sessionType'] as String? ?? 'chat';
            final isDiuStudent = data['isDiuStudent'] as bool? ?? false;
            final isExpired = slotStart != null &&
                slotStart
                    .add(const Duration(minutes: 50))
                    .isBefore(DateTime.now());

            return AppSurface(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.blue50,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            studentName[0].toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.blue600,
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
                            Text(studentName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.gray900)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                    isDiuStudent
                                        ? Icons.school_rounded
                                        : Icons.person_rounded,
                                    size: 14,
                                    color: isDiuStudent
                                        ? AppColors.sage600
                                        : AppColors.gray500),
                                const SizedBox(width: 4),
                                Text(
                                  isDiuStudent
                                      ? 'DIU Student (Free)'
                                      : 'External (Paid)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isDiuStudent
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isDiuStudent
                                        ? AppColors.sage600
                                        : (isDark
                                            ? AppColors.gray400
                                            : AppColors.gray600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _StatusChip(
                          status: (isExpired && status == 'confirmed')
                              ? 'completed'
                              : status),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface2 : AppColors.gray50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (slotStart != null) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkBg
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.event_rounded,
                                    size: 16, color: AppColors.blue500),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  DateFormat('EEEE, MMM d, yyyy')
                                      .format(slotStart),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.gray900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkBg
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.schedule_rounded,
                                    size: 16, color: AppColors.amber600),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${DateFormat.jm().format(slotStart)} (50 mins)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.gray900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color:
                                      isDark ? AppColors.darkBg : Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(
                                  sessionType == 'in_person'
                                      ? Icons.business_rounded
                                      : (sessionType == 'video'
                                          ? Icons.videocam_rounded
                                          : Icons.chat_bubble_rounded),
                                  size: 16,
                                  color: sessionType == 'in_person' ? AppColors.blue500 : AppColors.sage600),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                sessionType == 'in_person'
                                    ? 'IN-PERSON VISIT (DIU CAMPUS)'
                                    : sessionType.toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.gray900),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (status == 'reschedule_requested') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.amber600.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.amber600.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reschedule Reason: ${data['rescheduleReason'] ?? 'Not provided'}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.amber600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.amber600),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection(FirestorePaths.bookings)
                                        .doc(bookingId)
                                        .update({'status': 'confirmed'});
                                  },
                                  child: const Text('Keep Slot'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.red500, side: const BorderSide(color: AppColors.red500)),
                                  onPressed: () async {
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
                                      });
                                    }
                                  },
                                  child: const Text('Free Slot'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (upcoming && !isExpired && sessionType == 'in_person') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.blue500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.blue500.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_rounded, color: AppColors.blue500, size: 20),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Meet at Campus Office (DSC Campus)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.blue500, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (upcoming && !isExpired) ...[
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => onSetMeetLink(bookingId, meetLink),
                            icon: Icon(
                                meetLink.isEmpty
                                    ? Icons.add_link_rounded
                                    : Icons.edit_rounded,
                                size: 18),
                            label: Text(meetLink.isEmpty
                                ? 'Set Google Meet Link'
                                : 'Edit Meet Link', style: const TextStyle(fontWeight: FontWeight.w600)),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        if (meetLink.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse(meetLink);
                                if (await canLaunchUrl(uri)) {
                                  launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.videocam_rounded, size: 18),
                              label: const Text('Join Session', style: TextStyle(fontWeight: FontWeight.w600)),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.sage600,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                  ] else if (upcoming && isExpired) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection(FirestorePaths.bookings)
                              .doc(bookingId)
                              .update({'status': 'completed'});
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Mark Session as Completed', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.sage600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context
                              .push('/psychologist/bookings/$bookingId/note'),
                          icon: const Icon(Icons.lock_outline, size: 18),
                          label: const Text('Private Note', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorderSoft
                                    : AppColors.gray300),
                            foregroundColor:
                                isDark ? Colors.white : AppColors.gray900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final exCtrl = TextEditingController(text: data['sharedCarePlan']?['exercises'] ?? '');
                            final followCtrl = TextEditingController(text: data['sharedCarePlan']?['followUp'] ?? '');
                            final refCtrl = TextEditingController(text: data['sharedCarePlan']?['referral'] ?? '');
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Shared Action Plan'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Recommended Exercises / Daily Action:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: exCtrl,
                                        maxLines: 3,
                                        decoration: InputDecoration(hintText: 'e.g. 10 mins breathing exercise, gratitude journal...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text('Next Follow-Up Date Advice:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: followCtrl,
                                        decoration: InputDecoration(hintText: 'e.g. In 2 weeks after midterms...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text('Referral / Additional Advice:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: refCtrl,
                                        decoration: InputDecoration(hintText: 'e.g. Visit DIU Medical Center if sleep persists...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                  FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Share with Student')),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await FirebaseFirestore.instance
                                  .collection(FirestorePaths.bookings)
                                  .doc(bookingId)
                                  .update({
                                'sharedCarePlan': {
                                  'exercises': exCtrl.text.trim(),
                                  'followUp': followCtrl.text.trim(),
                                  'referral': refCtrl.text.trim(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.assignment_turned_in_rounded, size: 18, color: AppColors.blue500),
                          label: const Text('Shared Plan', style: TextStyle(color: AppColors.blue500, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: AppColors.blue500.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case 'confirmed':
        bg = AppColors.sage50;
        fg = AppColors.sage600;
        break;
      case 'pending':
        bg = AppColors.amber50;
        fg = AppColors.amber600;
        break;
      case 'reschedule_requested':
        bg = AppColors.amber50;
        fg = AppColors.amber600;
        break;
      case 'completed':
        bg = AppColors.blue50;
        fg = AppColors.blue600;
        break;
      case 'cancelled':
        bg = AppColors.red50;
        fg = AppColors.red500;
        break;
      default:
        bg = AppColors.gray100;
        fg = AppColors.gray600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status == 'reschedule_requested'
            ? 'RESCHEDULE REQ.'
            : status.toUpperCase(),
        style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
    );
  }
}

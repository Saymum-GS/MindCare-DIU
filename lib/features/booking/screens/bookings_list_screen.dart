// lib/features/booking/screens/bookings_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/widgets/app_loading_state.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});
  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen>
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

  Stream<QuerySnapshot> _stream(bool upcoming) {
    final base = FirebaseFirestore.instance
        .collection(FirestorePaths.bookings)
        .where('studentUid', isEqualTo: _uid);
    if (upcoming) {
      return base
          .where('status', whereIn: ['pending', 'confirmed', 'reschedule_requested'])
          .orderBy('slotStart')
          .snapshots();
    } else {
      return base
          .where('status', whereIn: ['completed', 'cancelled'])
          .orderBy('slotStart', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Sessions', style: TextStyle(fontSize: context.rf(17))),
        bottom: TabBar(
          controller: _tabs,
          labelStyle: TextStyle(fontSize: context.rf(14), fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: context.rf(14)),
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _BookingList(stream: _stream(true)),
          _BookingList(stream: _stream(false))
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  const _BookingList({required this.stream});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.rs(20)),
              child: Text(
                'Error loading sessions:\n\n${snap.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.red500, fontSize: context.rf(14)),
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return Center(child: AppLoadingState(itemCount: 4, height: context.rs(100)));
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/empty_calendar.png',
                    width: context.rs(140), height: context.rs(140), fit: BoxFit.contain),
                SizedBox(height: context.rs(24)),
                Text('No sessions here.',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSub
                            : AppColors.gray500,
                        fontSize: context.rf(16))),
                SizedBox(height: context.rs(8)),
                Text(
                    'Book a session with a psychologist\nfrom the home screen.',
                    style:
                        TextStyle(color: AppColors.gray400, fontSize: context.rf(13)),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(context.rs(16)),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final bookingId = docs[i].id;
            final slotStart = (d['slotStart'] as Timestamp?)?.toDate();
            final status = d['status'] as String? ?? 'pending';
            final psychName =
                d['psychologistName'] as String? ?? 'Psychologist';
            final meetLink = d['meetLink'] as String? ?? '';
            final sessionType = d['sessionType'] as String? ?? 'video';
            final fee = (d['paymentAmountBdt'] as num?)?.toInt() ?? 0;
            final isDiu = d['isDiuStudent'] as bool? ?? false;
            final slotId = d['slotId'] as String?;
            final isExpired = slotStart != null &&
                slotStart
                    .add(const Duration(minutes: 50))
                    .isBefore(DateTime.now());

            return Container(
              margin: EdgeInsets.only(bottom: context.rs(12)),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(context.rs(16)),
                border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.gray200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(context.rs(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: AppColors.blue500, size: context.rs(18)),
                        SizedBox(width: context.rs(8)),
                        Expanded(
                            child: Text(psychName,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: context.rf(15),
                                    color: isDark ? Colors.white : AppColors.gray900))),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.rs(8), vertical: context.rs(3)),
                          decoration: BoxDecoration(
                              color: _statusBg(
                                  isExpired && status == 'confirmed'
                                      ? 'completed'
                                      : status).withValues(alpha: isDark ? 0.2 : 1.0),
                              borderRadius: BorderRadius.circular(6),
                              border: isDark ? Border.all(color: _statusColor(isExpired && status == 'confirmed' ? 'completed' : status).withValues(alpha: 0.3)) : null),
                          child: Text(
                              isExpired && status == 'confirmed'
                                  ? 'Completed'
                                  : status == 'reschedule_requested'
                                      ? 'Reschedule Pending'
                                      : status[0].toUpperCase() + status.substring(1),
                              style: TextStyle(
                                  color: _statusColor(
                                      isExpired && status == 'confirmed'
                                          ? 'completed'
                                          : status),
                                  fontSize: context.rf(11),
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    if (slotStart != null) ...[
                      SizedBox(height: context.rs(8)),
                      Row(children: [
                        Icon(Icons.calendar_today_outlined,
                            size: context.rs(13),
                            color:
                                isDark
                                    ? AppColors.darkTextSub
                                    : AppColors.gray500),
                        SizedBox(width: context.rs(6)),
                        Expanded(
                          child: Text(
                              DateFormat('EEE, MMM d • h:mm a').format(slotStart),
                              style: TextStyle(
                                  fontSize: context.rf(13), color: isDark ? AppColors.gray300 : AppColors.gray700)),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: context.rs(6),
                      runSpacing: context.rs(4),
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                size: context.rs(13),
                                color: isDark
                                    ? AppColors.darkTextSub
                                    : AppColors.gray500),
                            SizedBox(width: context.rs(6)),
                            Text('50 min · ${sessionType == 'in_person' ? 'IN-PERSON (DIU)' : sessionType.toUpperCase()}',
                                style: TextStyle(
                                    fontSize: context.rf(12),
                                    color: isDark
                                        ? AppColors.darkTextSub
                                        : AppColors.gray500)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isDiu ? 'Free (DIU)' : '৳$fee',
                                style: TextStyle(
                                    fontSize: context.rf(12),
                                    color: isDiu
                                        ? AppColors.riskGreenFg
                                        : AppColors.gray500,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    if (sessionType == 'in_person' && !isExpired) ...[
                      SizedBox(height: context.rs(10)),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: context.rs(12), vertical: context.rs(8)),
                        decoration: BoxDecoration(
                          color: AppColors.blue500.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: isDark ? Border.all(color: AppColors.blue500.withValues(alpha: 0.3)) : null,
                        ),
                        child: Row(children: [
                          Icon(Icons.business_rounded,
                              size: context.rs(16),
                              color: AppColors.blue500),
                          SizedBox(width: context.rs(8)),
                          Expanded(
                            child: Text('Meet at DIU Counseling Center / Office',
                                style: TextStyle(
                                    color: AppColors.blue500,
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.rf(13))),
                          ),
                        ]),
                      ),
                    ] else if (status == 'confirmed' &&
                        meetLink.isNotEmpty &&
                        !isExpired) ...[
                      SizedBox(height: context.rs(10)),
                      Builder(
                        builder: (context) {
                          final now = DateTime.now();
                          final isWithin10Mins = slotStart != null &&
                              now.isAfter(slotStart
                                  .subtract(const Duration(minutes: 10)));

                          if (isWithin10Mins) {
                            return InkWell(
                              onTap: () async {
                                final uri = Uri.parse(meetLink);
                                if (await canLaunchUrl(uri)) {
                                  launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: context.rs(12), vertical: context.rs(8)),
                                decoration: BoxDecoration(
                                  color: AppColors.riskGreenBg.withValues(alpha: isDark ? 0.2 : 1.0),
                                  borderRadius: BorderRadius.circular(8),
                                  border: isDark ? Border.all(color: AppColors.riskGreenFg.withValues(alpha: 0.3)) : null,
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.videocam_outlined,
                                          size: context.rs(16),
                                          color: AppColors.riskGreenFg),
                                      SizedBox(width: context.rs(6)),
                                      Text('Join Meet',
                                          style: TextStyle(
                                              color: AppColors.riskGreenFg,
                                              fontWeight: FontWeight.w600,
                                              fontSize: context.rf(13))),
                                    ]),
                              ),
                            );
                          } else {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: context.rs(12), vertical: context.rs(8)),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurface2
                                    : AppColors.gray100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(children: [
                                Icon(Icons.lock_clock_outlined,
                                    size: context.rs(16),
                                    color: isDark
                                        ? AppColors.darkTextSub
                                        : AppColors.gray500),
                                SizedBox(width: context.rs(8)),
                                Text('Link active 10 mins before session',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextSub
                                            : AppColors.gray500,
                                        fontWeight: FontWeight.w600,
                                        fontSize: context.rf(13))),
                              ]),
                            );
                          }
                        },
                      ),
                    ],
                    if ((status == 'pending' || status == 'confirmed') &&
                        !isExpired) ...[
                      SizedBox(height: context.rs(10)),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(
                          onPressed: () async {
                            final now = DateTime.now();
                            if (slotStart != null && slotStart.difference(now).inHours < 24) {
                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: Text('Cannot Cancel Booking', style: TextStyle(fontSize: context.rf(18))),
                                  content: Text(
                                      'You can\'t cancel it within 24 hours remaining of the booking. Please contact the counseling center directly if you have an emergency.',
                                      style: TextStyle(fontSize: context.rf(14))),
                                  actions: [
                                    FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: AppColors.blue500),
                                      onPressed: () => Navigator.pop(c),
                                      child: Text('OK', style: TextStyle(fontSize: context.rf(14))),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: Text('Cancel Session?', style: TextStyle(fontSize: context.rf(18))),
                                content: Text(
                                    'This will cancel your booking. The slot will be freed.', style: TextStyle(fontSize: context.rf(14))),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: Text('Keep', style: TextStyle(fontSize: context.rf(14)))),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.red500),
                                    onPressed: () => Navigator.pop(c, true),
                                    child: Text('Cancel Booking', style: TextStyle(fontSize: context.rf(14))),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              try {
                                final batch =
                                    FirebaseFirestore.instance.batch();
                                batch.update(
                                  FirebaseFirestore.instance
                                      .collection(FirestorePaths.bookings)
                                      .doc(bookingId),
                                  {
                                    'status': 'cancelled',
                                    'updatedAt': FieldValue.serverTimestamp()
                                  },
                                );

                                if (slotId != null && slotId.isNotEmpty) {
                                  batch.update(
                                      FirebaseFirestore.instance
                                          .collection(
                                              FirestorePaths.psychologistSlots)
                                          .doc(slotId),
                                      {
                                        'isBooked': false,
                                        'bookedByUid': null,
                                        'bookingId': null,
                                        'updatedAt':
                                            FieldValue.serverTimestamp()
                                      });
                                }

                                await batch.commit();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Error cancelling: $e', style: TextStyle(fontSize: context.rf(13)))));
                                }
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.red500),
                          child: Text('Cancel Booking', style: TextStyle(fontSize: context.rf(14))),
                        ),
                      ]),
                    ],
                    if ((status == 'pending' || status == 'confirmed') &&
                        isExpired) ...[
                      SizedBox(height: context.rs(10)),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('Session Time Elapsed',
                            style: TextStyle(
                                fontSize: context.rf(13),
                                color: isDark
                                    ? AppColors.darkTextSub
                                    : AppColors.gray500,
                                fontStyle: FontStyle.italic)),
                      ]),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

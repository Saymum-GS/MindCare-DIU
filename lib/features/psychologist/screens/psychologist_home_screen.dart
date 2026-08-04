// lib/features/psychologist/screens/psychologist_home_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/responsive_util.dart';
import '../../chat/providers/chat_providers.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading_state.dart';

class PsychologistHomeScreen extends ConsumerStatefulWidget {
  const PsychologistHomeScreen({super.key});

  @override
  ConsumerState<PsychologistHomeScreen> createState() =>
      _PsychologistHomeScreenState();
}

class _PsychologistHomeScreenState extends ConsumerState<PsychologistHomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isOnCall = false;
  String _myUid = '';
  late AnimationController _pulseController;
  StreamSubscription? _alertSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _loadProfile();
    _setupRoleAlerts();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _alertSub?.cancel();
    super.dispose();
  }

  void _setupRoleAlerts() {
    _alertSub = ref
        .read(notificationServiceProvider)
        .watchRoleAlerts('psychologist')
        .listen((alerts) {
      if (alerts.isNotEmpty && mounted) {
        final last = alerts.last;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.crisis_alert_rounded, color: Colors.white, size: context.rs(22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(last['title'] ?? 'Crisis Alert',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.rf(14))),
                      Text(last['body'] ?? '',
                          style: TextStyle(fontSize: context.rf(12))),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _myUid = uid;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      if (mounted) {
        setState(() {
          _isOnCall = doc.data()?['isOnCall'] ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleOnCall(bool value) async {
    final oldVal = _isOnCall;
    setState(() => _isOnCall = value);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'isOnCall': value});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? '✅ You are now on-call. You will receive crisis alerts.'
                : '🔕 You are off-call. Crisis alerts paused.', style: TextStyle(fontSize: context.rf(13))),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isOnCall = oldVal);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update on-call status: $e')),
        );
      }
    }
  }

  Future<void> _acceptChat(String sessionId) async {
    try {
      await ref.read(chatRepositoryProvider).acceptChat(sessionId);
      if (mounted) context.push('/chat/$sessionId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e', style: TextStyle(fontSize: context.rf(13)))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgentAsync = ref.watch(urgentCrisisSessionsProvider);
    final consultationsAsync = ref.watch(standardConsultationRequestsProvider);
    final activeAsync = ref.watch(activePsychologistSessionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userAsync = ref.watch(currentUserProvider);
    final isVerified = userAsync.valueOrNull?.isVerified ?? false;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: Text('Clinical Dashboard',
            style: TextStyle(fontSize: context.rf(17), fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, size: context.rs(22)),
            tooltip: 'Client Cases',
            onPressed: () => context.go('/chat-history'),
          ),
          IconButton(
            icon: Icon(Icons.person_outline_rounded, size: context.rs(22)),
            tooltip: 'Edit Profile',
            onPressed: () => context.push('/psychologist/profile'),
          ),
          SizedBox(width: context.rs(8)),
        ],
      ),
      body: !isVerified
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(context.rs(24)),
                child: AppEmptyState(
                  icon: Icons.verified_user_outlined,
                  title: 'Verification Pending',
                  message: 'Your account is currently under review by an administrator. You will gain access to clinical features once verified.',
                ),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: CustomScrollView(
            slivers: [
              // On-call toggle card
              SliverToBoxAdapter(
                child: _buildOnCallBanner(isDark),
              ),

              // Quick stats row
              SliverToBoxAdapter(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(FirestorePaths.bookings)
                      .where('psychologistUid', isEqualTo: _myUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final total = snapshot.data?.docs.length ?? 0;
                    final upcomingDocs = snapshot.data?.docs.where((d) {
                          final status = (d.data() as Map)['status'] as String?;
                          return status == 'pending' || status == 'confirmed' || status == 'reschedule_requested';
                        }).toList() ??
                        [];
                    final upcoming = upcomingDocs.length;

                    String? nextSessionSub;
                    if (upcomingDocs.isNotEmpty) {
                      final times = upcomingDocs
                          .map(
                              (d) => (d.data() as Map)['scheduledAt'] as Timestamp?)
                          .whereType<Timestamp>()
                          .map((t) => t.toDate())
                          .where((t) => t.isAfter(DateTime.now()))
                          .toList();
                      if (times.isNotEmpty) {
                        times.sort();
                        nextSessionSub =
                            DateFormat('MMM d, h:mm a').format(times.first);
                      }
                    }

                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: context.rs(20), vertical: context.rs(8)),
                      child: Row(
                        children: [
                          _StatMini(
                              label: 'Total Sessions',
                              value: '$total',
                              icon: Icons.monitor_heart_rounded,
                              color: AppColors.sage600,
                              isDark: isDark),
                          SizedBox(width: context.rs(16)),
                          _StatMini(
                              label: 'Upcoming',
                              value: '$upcoming',
                              subtitle: nextSessionSub != null
                                  ? 'Next: $nextSessionSub'
                                  : null,
                              icon: Icons.calendar_month_rounded,
                              color: AppColors.blue500,
                              isDark: isDark),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Clinical Case Archive Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(context.rs(20), context.rs(8), context.rs(20), 0),
                  child: Container(
                    padding: EdgeInsets.all(context.rs(16)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.purple900.withValues(alpha: 0.4), AppColors.darkSurface]
                            : [AppColors.purple50, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(context.rs(16)),
                      border: Border.all(color: isDark ? AppColors.purple500.withValues(alpha: 0.3) : AppColors.purple200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(context.rs(12)),
                          decoration: BoxDecoration(
                            color: AppColors.purple500.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.folder_shared_rounded, color: AppColors.purple600, size: context.rs(24)),
                        ),
                        SizedBox(width: context.rs(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clinical Case Archive',
                                style: TextStyle(
                                  fontSize: context.rf(16),
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.gray900,
                                ),
                              ),
                              SizedBox(height: context.rs(4)),
                              Text(
                                'Review past client sessions, notes, ratings, and clinical records.',
                                style: TextStyle(
                                  fontSize: context.rf(13),
                                  color: isDark ? AppColors.gray300 : AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: context.rs(12)),
                        FilledButton.icon(
                          onPressed: () => context.go('/chat-history'),
                          icon: Icon(Icons.arrow_forward_rounded, size: context.rs(16)),
                          label: Text('Open', style: TextStyle(fontSize: context.rf(13), fontWeight: FontWeight.w600)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.purple600,
                            padding: EdgeInsets.symmetric(horizontal: context.rs(16), vertical: context.rs(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Incoming Urgent Crisis requests
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(context.rs(20), context.rs(32), context.rs(20), context.rs(12)),
                  child: Row(
                    children: [
                      Icon(Icons.crisis_alert_rounded,
                          color: AppColors.red500, size: context.rs(20)),
                      SizedBox(width: context.rs(8)),
                      Text(
                        'Urgent Crisis Cases',
                        style: TextStyle(
                          fontSize: context.rf(18),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              urgentAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return SliverToBoxAdapter(
                      child: AppEmptyState(
                        title: 'No Active Crises',
                        message: 'There are no pending escalated cases.',
                        icon: Icons.shield_rounded,
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = sessions[index];
                        final pseudonym =
                            session.studentPseudonym ?? 'Anonymous Student';
                        final risk = session.riskLevel ?? 'red';

                        return _buildEscalatedChatCard(
                            session, pseudonym, risk, isDark);
                      },
                      childCount: sessions.length,
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                    child: Center(child: AppLoadingState(itemCount: 2, height: context.rs(100)))),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e', style: TextStyle(fontSize: context.rf(14))))),
              ),

              // Standard Consultations
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(context.rs(20), context.rs(32), context.rs(20), context.rs(12)),
                  child: Row(
                    children: [
                      Icon(Icons.psychology_rounded,
                          color: AppColors.blue500, size: context.rs(20)),
                      SizedBox(width: context.rs(8)),
                      Text(
                        'Consultation Requests',
                        style: TextStyle(
                          fontSize: context.rf(18),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              consultationsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return SliverToBoxAdapter(
                      child: AppEmptyState(
                        title: 'No Pending Consultations',
                        message: 'There are no pending consultation requests.',
                        icon: Icons.psychology_outlined,
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = sessions[index];
                        final waitTimeStr = session.startedAt != null
                            ? 'Requested ${DateFormat('h:mm a').format(session.startedAt!)}'
                            : 'Tap to accept';

                        return Container(
                          margin: EdgeInsets.only(
                              bottom: context.rs(12), left: context.rs(20), right: context.rs(20)),
                          decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(context.rs(16)),
                              border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.blue200),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.blue500.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ]),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(context.rs(12)),
                            leading: Container(
                              width: context.rs(48),
                              height: context.rs(48),
                              decoration: BoxDecoration(
                                  color: AppColors.blue50,
                                  borderRadius: BorderRadius.circular(context.rs(12))),
                              child: Icon(Icons.psychology_rounded,
                                  color: AppColors.blue500, size: context.rs(24)),
                            ),
                            title: Text(session.studentPseudonym ?? 'Student',
                                style: TextStyle(
                                    fontSize: context.rf(16),
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : AppColors.gray900)),
                            subtitle: Text(waitTimeStr,
                                style: TextStyle(
                                    fontSize: context.rf(13),
                                    color: isDark
                                        ? AppColors.gray400
                                        : AppColors.gray500)),
                            trailing: FilledButton(
                              onPressed: () => _acceptChat(session.id),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.blue600,
                                padding: EdgeInsets.symmetric(horizontal: context.rs(16), vertical: context.rs(8)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(context.rs(8)),
                                ),
                              ),
                              child: Text('Accept', style: TextStyle(fontSize: context.rf(13))),
                            ),
                          ),
                        );
                      },
                      childCount: sessions.length,
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                    child: Center(child: AppLoadingState(itemCount: 2, height: context.rs(60)))),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e', style: TextStyle(fontSize: context.rf(14))))),
              ),

              // Active chats
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(context.rs(20), context.rs(32), context.rs(20), context.rs(12)),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          color: AppColors.blue500, size: context.rs(20)),
                      SizedBox(width: context.rs(8)),
                      Text(
                        'Active Consultations',
                        style: TextStyle(
                          fontSize: context.rf(18),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              activeAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return SliverToBoxAdapter(
                      child: AppEmptyState(
                        title: 'No Consultations',
                        message: 'No active consultations right now.',
                        icon: Icons.chat_bubble_outline,
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = sessions[index];
                        final waitTimeStr = session.startedAt != null
                            ? 'Started ${DateFormat('h:mm a').format(session.startedAt!)}'
                            : 'Tap to open chat';

                        return Container(
                          margin: EdgeInsets.only(
                              bottom: context.rs(12), left: context.rs(20), right: context.rs(20)),
                          decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(context.rs(16)),
                              border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.gray200),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ]),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(context.rs(12)),
                            leading: Container(
                              width: context.rs(48),
                              height: context.rs(48),
                              decoration: BoxDecoration(
                                  color: AppColors.blue50,
                                  borderRadius: BorderRadius.circular(context.rs(12))),
                              child: Icon(Icons.chat_bubble_rounded,
                                  color: AppColors.blue500, size: context.rs(24)),
                            ),
                            title: Text(session.studentPseudonym ?? 'Student',
                                style: TextStyle(
                                    fontSize: context.rf(16),
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : AppColors.gray900)),
                            subtitle: Text(waitTimeStr,
                                style: TextStyle(
                                    fontSize: context.rf(13),
                                    color: isDark
                                        ? AppColors.gray400
                                        : AppColors.gray500)),
                            trailing: Icon(Icons.chevron_right_rounded,
                                size: context.rs(20),
                                color:
                                    isDark ? AppColors.gray600 : AppColors.gray400),
                            onTap: () => context.push('/chat/${session.id}'),
                          ),
                        );
                      },
                      childCount: sessions.length,
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                    child: Center(child: AppLoadingState(itemCount: 3, height: context.rs(60)))),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e', style: TextStyle(fontSize: context.rf(14))))),
              ),

              SliverToBoxAdapter(child: SizedBox(height: context.rs(40))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnCallBanner(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.fromLTRB(context.rs(20), context.rs(8), context.rs(20), context.rs(16)),
      padding: EdgeInsets.all(context.rs(20)),
      decoration: BoxDecoration(
        color: _isOnCall
            ? (isDark
                ? AppColors.red900.withValues(alpha: 0.3)
                : AppColors.red50)
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(context.rs(20)),
        border: Border.all(
          color: _isOnCall
              ? AppColors.red500
              : (isDark ? AppColors.darkBorder : AppColors.gray200),
          width: _isOnCall ? 2 : 1,
        ),
        boxShadow: [
          if (_isOnCall)
            BoxShadow(
              color: AppColors.red500.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
        ],
      ),
      child: Row(
        children: [
          if (_isOnCall)
            FadeTransition(
              opacity: _pulseController,
              child: Container(
                padding: EdgeInsets.all(context.rs(12)),
                decoration: BoxDecoration(
                  color: AppColors.red500.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.crisis_alert_rounded,
                    color: AppColors.red500, size: context.rs(28)),
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(context.rs(12)),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface2 : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_off_rounded,
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                  size: context.rs(28)),
            ),
          SizedBox(width: context.rs(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnCall ? 'On-Call Active' : 'Off-Call',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.rf(18),
                    color: _isOnCall
                        ? AppColors.red500
                        : (isDark ? Colors.white : AppColors.gray900),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isOnCall
                      ? 'You are receiving high-priority FCM crisis alerts.'
                      : 'Toggle to receive system crisis notifications.',
                  style: TextStyle(
                      fontSize: context.rf(13),
                      color: isDark ? AppColors.gray400 : AppColors.gray500),
                ),
              ],
            ),
          ),
          SizedBox(width: context.rs(16)),
          Switch(
            value: _isOnCall,
            onChanged: _toggleOnCall,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.red500,
            inactiveThumbColor: isDark ? AppColors.gray400 : Colors.white,
            inactiveTrackColor:
                isDark ? AppColors.darkSurface3 : AppColors.gray300,
          ),
        ],
      ),
    );
  }

  Widget _buildEscalatedChatCard(
      dynamic session, String pseudonym, String risk, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: context.rs(12), left: context.rs(20), right: context.rs(20)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(context.rs(16)),
        border: Border.all(color: AppColors.red500.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.red500.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(context.rs(16)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: context.rs(24),
                  backgroundColor: AppColors.red50,
                  child: Text(pseudonym[0].toUpperCase(),
                      style: TextStyle(
                          color: AppColors.red500,
                          fontWeight: FontWeight.bold,
                          fontSize: context.rf(20))),
                ),
                SizedBox(width: context.rs(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pseudonym,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: context.rf(18),
                              color:
                                  isDark ? Colors.white : AppColors.gray900)),
                      const SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: context.rs(8), vertical: context.rs(4)),
                        decoration: BoxDecoration(
                          color: AppColors.red500,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_rounded,
                                color: Colors.white, size: context.rs(14)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'ESCALATED',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.rf(12),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(context.rs(16), 0, context.rs(16), context.rs(16)),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _acceptChat(session.id),
                icon: Icon(Icons.medical_services_rounded, size: context.rs(20)),
                label: const Text('Take Over Session'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.red500,
                  padding: EdgeInsets.symmetric(vertical: context.rs(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.rs(12)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatMini({
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(context.rs(20)),
        decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(context.rs(20)),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.gray200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(context.rs(12)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: context.rs(24)),
            ),
            SizedBox(height: context.rs(16)),
            Text(value,
                style: TextStyle(
                    fontSize: context.rf(28),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.gray900)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: context.rf(14),
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                    fontWeight: FontWeight.w600)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!,
                  style: TextStyle(
                      fontSize: context.rf(12),
                      color: AppColors.blue500,
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

// lib/features/volunteer/screens/volunteer_home_screen.dart
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
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_loading_state.dart';

class VolunteerHomeScreen extends ConsumerStatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  ConsumerState<VolunteerHomeScreen> createState() =>
      _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends ConsumerState<VolunteerHomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isOnline = false;
  String _myDisplayName = '';
  late AnimationController _pulseController;
  StreamSubscription? _alertSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadStatus();
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
        .watchRoleAlerts('volunteer')
        .listen((alerts) {
      if (!_isOnline) return;
      if (alerts.isNotEmpty && mounted) {
        final last = alerts.last;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.notification_important_rounded,
                    color: Colors.white, size: context.rs(22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(last['title'] ?? 'New Alert',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.rf(14))),
                      Text(last['body'] ?? '',
                          style: TextStyle(fontSize: context.rf(12))),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.blue600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _loadStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      if (mounted) {
        setState(() {
          _isOnline = doc.data()?['isOnline'] ?? false;
          _myDisplayName = doc.data()?['displayName'] ?? 'Volunteer';
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleOnline(bool value) async {
    final oldVal = _isOnline;
    setState(() => _isOnline = value);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'isOnline': value});
    } catch (e) {
      if (mounted) {
        setState(() => _isOnline = oldVal);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update online status: $e')),
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
            .showSnackBar(SnackBar(content: Text('Error accepting chat: $e', style: TextStyle(fontSize: context.rf(13)))));
      }
    }
  }

  Color _riskColor(String? risk) {
    switch (risk) {
      case 'red':
        return AppColors.red500;
      case 'yellow':
        return AppColors.amber600;
      default:
        return AppColors.sage600;
    }
  }

  Color _riskBgColor(String? risk) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (risk) {
      case 'red':
        return isDark ? AppColors.riskRedBgDark : AppColors.red50;
      case 'yellow':
        return isDark ? AppColors.riskYellowBgDark : AppColors.amber50;
      default:
        return isDark ? AppColors.riskGreenBgDark : AppColors.sage50;
    }
  }

  String _riskLabel(String? risk) {
    switch (risk) {
      case 'red':
        return 'High Risk';
      case 'yellow':
        return 'Moderate Risk';
      default:
        return 'Low Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waitingAsync = ref.watch(waitingVolunteerSessionsProvider);
    final activeAsync = ref.watch(activeVolunteerSessionsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: Text('Volunteer',
            style: TextStyle(fontSize: context.rf(17), fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, size: context.rs(22)),
            onPressed: () => context.go('/chat-history'),
            tooltip: 'Support Sessions',
          ),
          IconButton(
            icon: Icon(Icons.person_outline_rounded, size: context.rs(22)),
            onPressed: () => context.push('/volunteer/profile'),
            tooltip: 'Edit Profile',
          ),
          SizedBox(width: context.rs(8)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              _buildOnlineStatusToggle(isDark),
              _buildArchiveBanner(isDark),
              Expanded(
                child: !_isOnline
                    ? _buildOfflineState(isDark)
                    : CustomScrollView(
                        slivers: [
                          // Active Chats Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(context.rs(20), context.rs(24), context.rs(20), context.rs(12)),
                              child: Row(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: context.rs(20)),
                                  SizedBox(width: context.rs(8)),
                                  Text(
                                    'Active Chats',
                                    style: TextStyle(
                                      fontSize: context.rf(18),
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark ? Colors.white : AppColors.gray900,
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
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: context.rs(20), vertical: context.rs(8)),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_outline_rounded,
                                            size: context.rs(16),
                                            color: isDark
                                                ? AppColors.gray400
                                                : AppColors.gray500),
                                        SizedBox(width: context.rs(8)),
                                        Text('No active chats right now.',
                                            style: TextStyle(
                                                fontSize: context.rf(14),
                                                color: isDark
                                                    ? AppColors.gray400
                                                    : AppColors.gray500)),
                                      ],
                                    ),
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

                                    return AppSurface(
                                      margin: EdgeInsets.only(
                                          bottom: context.rs(12), left: context.rs(20), right: context.rs(20)),
                                      padding: EdgeInsets.zero,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(context.rs(12)),
                                        leading: Container(
                                          width: context.rs(48),
                                          height: context.rs(48),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                                              borderRadius:
                                                  BorderRadius.circular(context.rs(12))),
                                          child: Icon(
                                              Icons.chat_bubble_rounded,
                                              color: Theme.of(context).colorScheme.primary,
                                              size: context.rs(24)),
                                        ),
                                        title: Text(
                                            session.studentPseudonym ?? 'Student',
                                            style: TextStyle(
                                                fontSize: context.rf(16),
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.gray900)),
                                        subtitle: Text(waitTimeStr,
                                            style: TextStyle(
                                                fontSize: context.rf(13),
                                                color: isDark
                                                    ? AppColors.gray400
                                                    : AppColors.gray500)),
                                        trailing: Icon(Icons.chevron_right_rounded,
                                            size: context.rs(20),
                                            color: isDark
                                                ? AppColors.gray600
                                                : AppColors.gray400),
                                        onTap: () =>
                                            context.push('/chat/${session.id}'),
                                      ),
                                    );
                                  },
                                  childCount: sessions.length,
                                ),
                              );
                            },
                            loading: () => SliverToBoxAdapter(
                                child:
                                    Center(child: AppLoadingState(itemCount: 2, height: context.rs(60)))),
                            error: (e, _) => SliverToBoxAdapter(
                                child: Center(child: Text('Error: $e', style: TextStyle(fontSize: context.rf(14))))),
                          ),

                          // Waiting Queue Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(context.rs(20), context.rs(32), context.rs(20), context.rs(12)),
                              child: Row(
                                children: [
                                  Icon(Icons.people_outline_rounded,
                                      color: AppColors.amber600, size: context.rs(20)),
                                  SizedBox(width: context.rs(8)),
                                  Text(
                                    'Waiting Queue',
                                    style: TextStyle(
                                      fontSize: context.rf(18),
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark ? Colors.white : AppColors.gray900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          waitingAsync.when(
                            data: (sessions) {
                              if (sessions.isEmpty) {
                                return SliverToBoxAdapter(
                                  child: const AppEmptyState(
                                    title: 'Queue is empty',
                                    message:
                                        'No students waiting right now.\nStay online - someone may reach out.',
                                    icon: Icons.coffee_rounded,
                                  ),
                                );
                              }
                              final sortedSessions = List.of(sessions);
                              sortedSessions.sort((a, b) {
                                int riskScore(String? r) =>
                                    r == 'red' ? 3 : (r == 'yellow' ? 2 : 1);
                                final scoreA = riskScore(a.riskLevel);
                                final scoreB = riskScore(b.riskLevel);
                                if (scoreA != scoreB) {
                                  return scoreB.compareTo(scoreA);
                                }
                                final timeA = a.startedAt ?? DateTime.now();
                                final timeB = b.startedAt ?? DateTime.now();
                                return timeA
                                    .compareTo(timeB); // Older requests first
                              });

                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return _buildWaitingChatCard(
                                        sortedSessions[index], isDark);
                                  },
                                  childCount: sortedSessions.length,
                                ),
                              );
                            },
                            loading: () => SliverToBoxAdapter(
                                child:
                                    Center(child: AppLoadingState(itemCount: 3, height: context.rs(100)))),
                            error: (e, _) => SliverToBoxAdapter(
                                child: Center(child: Text('Error: $e', style: TextStyle(fontSize: context.rf(14))))),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: context.rs(40))),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveBanner(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.rs(20), context.rs(4), context.rs(20), context.rs(8)),
      child: Container(
        padding: EdgeInsets.all(context.rs(16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.blue900.withValues(alpha: 0.3), AppColors.darkSurface]
                : [AppColors.blue50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(context.rs(16)),
          border: Border.all(color: isDark ? AppColors.blue500.withValues(alpha: 0.3) : AppColors.blue200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.rs(12)),
              decoration: BoxDecoration(
                color: AppColors.blue500.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_edu_rounded, color: AppColors.blue600, size: context.rs(24)),
            ),
            SizedBox(width: context.rs(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support Sessions Archive',
                    style: TextStyle(
                      fontSize: context.rf(15),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: context.rs(4)),
                  Text(
                    'Review past peer chats, feedback, and support history.',
                    style: TextStyle(
                      fontSize: context.rf(12),
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
                backgroundColor: AppColors.blue600,
                padding: EdgeInsets.symmetric(horizontal: context.rs(16), vertical: context.rs(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineStatusToggle(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: context.rs(20), vertical: context.rs(8)),
      padding: EdgeInsets.symmetric(horizontal: context.rs(20), vertical: context.rs(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isOnline
              ? [AppColors.sage500, AppColors.sage600]
              : [AppColors.gray400, AppColors.gray500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.rs(24)),
        boxShadow: [
          if (_isOnline)
            BoxShadow(
              color: AppColors.sage500.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (_isOnline)
                FadeTransition(
                  opacity: _pulseController,
                  child: Container(
                    width: context.rs(12),
                    height: context.rs(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                Container(
                  width: context.rs(12),
                  height: context.rs(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              SizedBox(width: context.rs(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOnline ? 'You are Online' : 'You are Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rf(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _myDisplayName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: context.rf(14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isOnline,
            onChanged: _toggleOnline,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.sage600.withValues(alpha: 0.5),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.gray600.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineState(bool isDark) {
    return const AppEmptyState(
      title: 'Take a break.',
      message:
          'Toggle the switch above to go online\nand start accepting chat requests.',
      icon: Icons.nights_stay_rounded,
    );
  }

  Widget _buildWaitingChatCard(dynamic session, bool isDark) {
    final risk = session.riskLevel;
    final pseudonym = session.studentPseudonym ?? 'Anonymous';
    final waitTimeStr = session.startedAt != null
        ? 'Waiting since ${DateFormat('h:mm a').format(session.startedAt!)}'
        : '';

    return AppSurface(
      margin: EdgeInsets.only(bottom: context.rs(12), left: context.rs(20), right: context.rs(20)),
      padding: EdgeInsets.all(context.rs(16)),
      borderColor:
          risk == 'red' ? AppColors.red500.withValues(alpha: 0.5) : null,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: context.rs(24),
                backgroundColor: _riskBgColor(risk),
                child: Text(
                  pseudonym[0].toUpperCase(),
                  style: TextStyle(
                    color: _riskColor(risk),
                    fontWeight: FontWeight.bold,
                    fontSize: context.rf(20),
                  ),
                ),
              ),
              SizedBox(width: context.rs(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pseudonym,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: context.rf(18),
                        color: isDark ? Colors.white : AppColors.gray900,
                      ),
                    ),
                    SizedBox(height: context.rs(6)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.rs(10), vertical: context.rs(4)),
                      decoration: BoxDecoration(
                        color: _riskBgColor(risk),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            risk == 'red'
                                ? Icons.warning_rounded
                                : Icons.shield_rounded,
                            size: context.rs(14),
                            color: _riskColor(risk),
                          ),
                          SizedBox(width: context.rs(4)),
                          Flexible(
                            child: Text(
                              _riskLabel(risk),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.rf(12),
                                color: _riskColor(risk),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (waitTimeStr.isNotEmpty) ...[
                      SizedBox(height: context.rs(6)),
                      Text(waitTimeStr,
                          style: TextStyle(
                              fontSize: context.rf(12),
                              color: isDark
                                  ? AppColors.gray500
                                  : AppColors.gray600,
                              fontWeight: FontWeight.w600)),
                    ]
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.rs(16)),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _acceptChat(session.id),
              icon: Icon(Icons.check_rounded, size: context.rs(20)),
              label: const Text('Accept Request'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: context.rs(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.rs(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'widgets/risk_banner_card.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/utils/responsive_util.dart';
import 'package:intl/intl.dart';
// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/firestore_paths.dart';
import '../auth/providers/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../chat/providers/chat_providers.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_loading_state.dart';
import 'widgets/quick_action_grid.dart';
import '../../../core/services/notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<AsyncValue<UserModel?>>(currentUserProvider,
          (prev, next) {
        final prevRisk = prev?.valueOrNull?.latestRiskLevel;
        final currRisk = next.valueOrNull?.latestRiskLevel;
        if (currRisk == 'red' && prevRisk != 'red' && mounted) {
          context.go('/crisis');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: AppLoadingState(itemCount: 4)));
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestorePaths.users)
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: AppLoadingState(itemCount: 4));
          }
          final d = snapshot.data!.data() as Map<String, dynamic>?;
          if (d == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLoadingState(itemCount: 1),
                    const SizedBox(height: 16),
                    Text('Initializing your profile...',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            );
          }

          final pseudonym = d['pseudonym'] as String? ?? 'Friend';
          final displayName = d['displayName'] as String? ?? pseudonym;
          final riskLevel = d['latestRiskLevel'] as String?;
          final isDiuStudent = d['isDiuStudent'] as bool? ?? false;

          return CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverToBoxAdapter(
                child: _HomeSection(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MindCare',
                                style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 22, color: AppColors.blue500)),
                            Row(
                              children: [
                                if (isDiuStudent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.riskGreenBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.school_rounded,
                                            size: 12,
                                            color: AppColors.riskGreenFg),
                                        const SizedBox(width: 4),
                                        const Text('DIU Free',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.riskGreenFg,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => context.push('/chat-history'),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                        Icons.history_rounded,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => context.push('/notifications'),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                            Icons.notifications_outlined,
                                            size: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant),
                                      ),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final unreadAsync = ref
                                              .watch(unreadCountProvider(uid));
                                          return unreadAsync.maybeWhen(
                                            data: (unreadCount) {
                                              if (unreadCount == 0) {
                                                return const SizedBox.shrink();
                                              }
                                              return Positioned(
                                                top: -2,
                                                right: -2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.red500,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    unreadCount > 9
                                                        ? '9+'
                                                        : unreadCount
                                                            .toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              );
                                            },
                                            orElse: () =>
                                                const SizedBox.shrink(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => context.go('/settings'),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.settings_outlined,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Builder(builder: (context) {
                                      final hour = DateTime.now().hour;
                                      String greeting;
                                      if (hour >= 5 && hour < 12) {
                                        greeting = 'Good morning,';
                                      } else if (hour >= 12 && hour < 17) {
                                        greeting = 'Good afternoon,';
                                      } else if (hour >= 17 && hour < 21) {
                                        greeting = 'Good evening,';
                                      } else if (hour >= 21 || hour < 4) {
                                        greeting = 'Good night,';
                                      } else {
                                        greeting = 'Early morning,';
                                      }
                                      return Text(greeting,
                                          style: GoogleFonts.dmSerifDisplay(
                                              fontSize: context.rf(26),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              height: 1.1));
                                    }),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push('/profile'),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              displayName,
                                              style: GoogleFonts.dmSerifDisplay(
                                                  fontSize: context.rf(32),
                                                  color: AppColors.blue500,
                                                  height: 1.1),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.chevron_right_rounded,
                                            color: AppColors.blue500,
                                            size: context.rs(20)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                                    style: TextStyle(
                                      fontSize: context.rf(13),
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => context.push('/profile'),
                              child: AppAvatar(
                                name: displayName,
                                photoBase64: d['photoBase64Thumb'] as String?,
                                radius: context.rs(32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Risk Banner (if applicable)
              if (riskLevel != null && riskLevel != 'green')
                SliverToBoxAdapter(
                    child: _HomeSection(
                        child: RiskBannerCard(
                            riskLevel: riskLevel, isCompact: true))),

              // Active Chat Banner
              Consumer(
                builder: (context, ref, child) {
                  final activeChatAsync = ref.watch(studentActiveChatProvider);
                  return activeChatAsync.when(
                    data: (chat) {
                      if (chat == null) {
                        return const SliverToBoxAdapter(
                            child: SizedBox.shrink());
                      }
                      return SliverToBoxAdapter(
                        child: _HomeSection(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                context.rs(20), context.rs(12), context.rs(20), 0),
                            child: GestureDetector(
                              onTap: () => context.push('/chat/${chat.id}'),
                              child: Container(
                                padding: EdgeInsets.all(context.rs(16)),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.sage500, AppColors.sage600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(context.rs(24)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.sage600.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: context.rs(48),
                                      height: context.rs(48),
                                      decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(context.rs(14))),
                                      child: Icon(Icons.forum_rounded,
                                          color: Colors.white, size: context.rs(26)),
                                    ),
                                    SizedBox(width: context.rs(16)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Return to Active Chat',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: context.rf(15))),
                                          const SizedBox(height: 2),
                                          Text(
                                              'Tap to continue your conversation.',
                                              style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.8),
                                                  fontSize: context.rf(13))),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        color: Colors.white, size: context.rs(18)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () =>
                        const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, __) =>
                        const SliverToBoxAdapter(child: SizedBox.shrink()),
                  );
                },
              ),

              // Crisis Card (always visible)
              SliverToBoxAdapter(
                child: _HomeSection(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        context.rs(20), context.rs(12), context.rs(20), 0),
                    child: GestureDetector(
                      onTap: () => context.go('/crisis'),
                      child: Container(
                        padding: EdgeInsets.all(context.rs(16)),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blue800, AppColors.blue900],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(context.rs(24)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue900.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: context.rs(48),
                              height: context.rs(48),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(context.rs(14)),
                              ),
                              child: Icon(Icons.shield_rounded,
                                  color: Colors.white, size: context.rs(26)),
                            ),
                            SizedBox(width: context.rs(16)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Crisis Support',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: context.rf(15))),
                                  const SizedBox(height: 2),
                                  Text('Always here. Tap anytime.',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.65),
                                          fontSize: context.rf(12))),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: Colors.white, size: context.rs(22)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: _HomeSection(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        context.rs(24), context.rs(28), context.rs(20), context.rs(12)),
                    child: Text('Quick Actions',
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: context.rf(22),
                            color: Theme.of(context).colorScheme.onSurface)),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _HomeSection(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.rs(20)),
                    child: const QuickActionGrid(),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: context.rs(32))),
            ],
          );
        },
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  final Widget child;

  const _HomeSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: child,
      ),
    );
  }
}

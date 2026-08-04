// lib/features/crisis/crisis_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/responsive_util.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/responsive_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/firestore_paths.dart';
import 'widgets/crisis_call_card.dart';

class CrisisScreen extends StatefulWidget {
  const CrisisScreen({super.key});
  @override
  State<CrisisScreen> createState() => _CrisisScreenState();
}

class _CrisisScreenState extends State<CrisisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _pulseOpacity = Tween<double>(begin: 1.0, end: 0.3)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.crisisBg,
        body: SafeArea(
          child: ResponsivePage(
            maxWidth: 860,
            padding: EdgeInsets.all(context.rs(24)),
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MindCare',
                          style: GoogleFonts.dmSerifDisplay(
                              fontSize: context.rf(20), color: Colors.white)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pulsing red dot
                          AnimatedBuilder(
                            animation: _pulseOpacity,
                            builder: (context, _) => Opacity(
                              opacity: _pulseOpacity.value,
                              child: Container(
                                width: context.rs(8),
                                height: context.rs(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.crisisAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: context.rs(6)),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.rs(10), vertical: context.rs(5)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Crisis Support',
                                style: TextStyle(
                                    color: AppColors.blue200,
                                    fontSize: context.rf(12),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: context.rs(40)),
                  Text('You are not\nalone right now.',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: context.rf(36), color: Colors.white, height: 1.2)),
                  SizedBox(height: context.rs(12)),
                  Text(
                      'This page works without internet. Help is always here.',
                      style: TextStyle(
                          color: AppColors.blue200, fontSize: context.rf(15), height: 1.6)),
                  SizedBox(height: context.rs(24)),

                  // Breathing Pulse Animation
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (context, child) {
                        final scale =
                            1.0 + (_pulseCtrl.value * 0.2); // expands up to 20%
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: context.rs(120),
                            height: context.rs(120),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.blue500.withValues(alpha: 0.15),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blue400
                                      .withValues(alpha: 0.2 * _pulseCtrl.value),
                                  blurRadius: 40 * _pulseCtrl.value,
                                  spreadRadius: 20 * _pulseCtrl.value,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(Icons.air_rounded,
                                  size: context.rs(48), color: AppColors.blue200),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: context.rs(12)),
                  Center(
                    child: Text('Breathe in... Breathe out...',
                        style: TextStyle(
                            color: AppColors.blue200.withValues(alpha: 0.8),
                            fontSize: context.rf(16))),
                  ),

                  SizedBox(height: context.rs(36)),

                  // Personal Emergency Contact Card
                  if (FirebaseAuth.instance.currentUser != null) ...[
                    Text('PERSONAL EMERGENCY GUARDIAN',
                        style: TextStyle(
                            color: AppColors.red400,
                            fontSize: context.rf(11),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2)),
                    SizedBox(height: context.rs(12)),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(FirestorePaths.users)
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snap) {
                        final data = snap.data?.data() as Map<String, dynamic>?;
                        final name = data?['emergencyContactName'] as String?;
                        final phone = data?['emergencyContactPhone'] as String?;
                        if (name != null && name.isNotEmpty && phone != null && phone.isNotEmpty) {
                          return CrisisCallCard(
                            name: '🚨 $name (Trusted Guardian)',
                            number: phone,
                            subtitle: 'Personal Emergency Contact',
                          );
                        }
                        return Container(
                          padding: EdgeInsets.all(context.rs(16)),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.red400),
                              SizedBox(width: context.rs(12)),
                              Expanded(
                                child: Text(
                                  'No trusted emergency contact set. Set one in Profile for instant SOS dialing.',
                                  style: TextStyle(color: Colors.white, fontSize: context.rf(13)),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  final role = (snap.data?.data() as Map<String, dynamic>?)?['role'] as String? ?? 'student';
                                  if (role == 'volunteer') {
                                    context.push('/volunteer/profile');
                                  } else if (role == 'psychologist') {
                                    context.push('/psychologist/profile');
                                  } else {
                                    context.push('/profile');
                                  }
                                },
                                child: const Text('Setup', style: TextStyle(color: AppColors.blue200, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: context.rs(24)),
                  ],

                  // Call cards
                  Text('NATIONAL & DIU CAMPUS HELPLINES',
                      style: TextStyle(
                          color: AppColors.crisisAccent,
                          fontSize: context.rf(11),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2)),
                  SizedBox(height: context.rs(12)),
                  const CrisisCallCard(
                    name: 'DIU Proctor Office Helpline',
                    number: '01811-458841',
                    subtitle: 'DIU DSC Campus Emergency & Security',
                  ),
                  SizedBox(height: context.rs(10)),
                  const CrisisCallCard(
                    name: 'DIU Medical Center',
                    number: '01847-334700',
                    subtitle: 'First Aid & Emergency Medical Care',
                  ),
                  SizedBox(height: context.rs(10)),
                  const CrisisCallCard(
                    name: 'Kaan Pete Roi',
                    number: '01779-554391',
                    subtitle: 'Free - Confidential - Emotional Support 24/7',
                  ),
                  SizedBox(height: context.rs(10)),
                  const CrisisCallCard(
                    name: 'National Emergency',
                    number: '999',
                    subtitle: 'Police, Ambulance, Fire Service',
                  ),
                  SizedBox(height: context.rs(36)),

                  // Grounding steps
                  Text('IMMEDIATE STEPS',
                      style: TextStyle(
                          color: AppColors.blue200,
                          fontSize: context.rf(11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2)),
                  SizedBox(height: context.rs(12)),
                  ..._buildGroundingSteps(),
                  SizedBox(height: context.rs(32)),

                  // Back button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.7),
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                        minimumSize: Size(double.infinity, context.rs(56)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.rs(16))),
                      ),
                      child: Text("I'm safe - take me back", style: TextStyle(fontSize: context.rf(15))),
                    ),
                  ),

                  SizedBox(height: context.rs(16)),
                  Center(
                    child: Text(
                      'This page is always accessible. No account needed.',
                      style: TextStyle(
                          color: AppColors.blue200.withValues(alpha: 0.6),
                          fontSize: context.rf(12)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.rs(8)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroundingSteps() {
    final steps = [
      (
        1,
        Icons.air_rounded,
        'Breathe: 4 - 7 - 8',
        'Inhale for 4 seconds. Hold for 7. Exhale slowly for 8. Repeat 3 times.'
      ),
      (
        2,
        Icons.people_outline_rounded,
        'Move toward a person',
        'Go to a friend, family member, or any public space where people are present.'
      ),
      (
        3,
        Icons.shield_outlined,
        'Create distance from risk',
        'Put distance between yourself and anything that could cause harm right now.'
      ),
    ];

    return steps.asMap().entries.map((entry) {
      final s = entry.value;
      return Padding(
        padding: EdgeInsets.only(bottom: context.rs(10)),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (ctx, val, child) => Opacity(
            opacity: val,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - val)),
              child: child,
            ),
          ),
          child:
              _GroundingStep(step: s.$1, icon: s.$2, title: s.$3, body: s.$4),
        ),
      );
    }).toList();
  }
}

class _GroundingStep extends StatelessWidget {
  final int step;
  final IconData icon;
  final String title, body;
  const _GroundingStep(
      {required this.step,
      required this.icon,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rs(16)),
      decoration: BoxDecoration(
        color: AppColors.crisisSurface,
        borderRadius: BorderRadius.circular(context.rs(14)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.rs(40),
            height: context.rs(40),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.rs(10)),
            ),
            child: Center(
              child: Semantics(
                label: 'Step $step icon',
                child: Icon(icon, color: AppColors.blue200, size: context.rs(20)),
              ),
            ),
          ),
          SizedBox(width: context.rs(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: context.rf(14))),
                SizedBox(height: context.rs(4)),
                Text(body,
                    style: TextStyle(
                        color: AppColors.blue200, fontSize: context.rf(13), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

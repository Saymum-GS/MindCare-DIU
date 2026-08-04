// lib/features/auth/screens/student_profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/responsive_util.dart';
import '../providers/auth_providers.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_loading_state.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: Text('My Profile',
            style: TextStyle(fontSize: context.rf(17), fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: AppLoadingState(itemCount: 4));
          }
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.all(context.rs(24)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Avatar + name
              Center(
                child: Column(children: [
                  Container(
                    width: context.rs(100),
                    height: context.rs(100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.blue700, AppColors.blue900]
                            : [AppColors.blue400, AppColors.blue600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(context.rs(32)),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.blue500.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?'),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rf(42),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: context.rs(20)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(user.displayName,
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: context.rf(32),
                                color: isDark ? Colors.white : AppColors.gray900)),
                        SizedBox(width: context.rs(8)),
                        IconButton(
                          onPressed: () => _editDisplayName(context, ref, uid, user.displayName),
                          icon: Icon(Icons.edit_rounded, size: context.rs(20), color: AppColors.blue500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.rs(8)),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (user.isDiuStudent == true && user.studentIdVerified == true) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: context.rs(14), vertical: context.rs(6)),
                        decoration: BoxDecoration(
                            color: AppColors.riskGreenBg
                                .withValues(alpha: isDark ? 0.2 : 1.0),
                            borderRadius: BorderRadius.circular(20),
                            border: isDark
                                ? Border.all(
                                    color: AppColors.riskGreenFg
                                        .withValues(alpha: 0.3))
                                : null),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.school_rounded,
                                  size: context.rs(14), color: AppColors.riskGreenFg),
                              SizedBox(width: context.rs(6)),
                              Text('DIU Student · Free Access',
                                  style: TextStyle(
                                      fontSize: context.rf(12),
                                      color: AppColors.riskGreenFg,
                                      fontWeight: FontWeight.w700)),
                            ]),
                      ),
                    ] else if (user.isDiuStudent == true && user.studentIdVerified == false) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: context.rs(14), vertical: context.rs(6)),
                        decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.amber600.withValues(alpha: 0.2)
                                : AppColors.amber50,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('Verification Pending',
                            style: TextStyle(
                                fontSize: context.rf(12),
                                color: AppColors.amber600,
                                fontWeight: FontWeight.w600)),
                      ),
                    ] else ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.rs(14), vertical: context.rs(6)),
                            decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurface2
                                    : AppColors.gray100,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text('External User',
                                style: TextStyle(
                                    fontSize: context.rf(12),
                                    color: isDark
                                        ? AppColors.gray300
                                        : AppColors.gray600,
                                    fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(width: context.rs(8)),
                          TextButton(
                            onPressed: () =>
                                _showVerificationDialog(context, ref, uid),
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: context.rs(12), vertical: 0),
                                minimumSize: const Size(0, 32),
                                foregroundColor: AppColors.blue500),
                            child: Text('Verify DIU ID',
                                style: TextStyle(
                                    fontSize: context.rf(12), fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ],
                  ]),
                ]),
              ),
              SizedBox(height: context.rs(32)),

              // Academic Info Card
              _InfoCard(
                icon: Icons.school_outlined,
                title: 'DIU Academic Context',
                isDark: isDark,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.department ?? 'Dept. not set',
                              style: TextStyle(
                                  fontSize: context.rf(16),
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.gray900)),
                          Text(user.academicYear ?? 'Year not set',
                              style: TextStyle(
                                  fontSize: context.rf(13),
                                  color: isDark ? AppColors.gray400 : AppColors.gray600)),
                          if (user.campus != null && user.campus!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Campus: ${user.campus}',
                                  style: TextStyle(fontSize: context.rf(13), color: AppColors.blue500)),
                            ),
                          if (user.batch != null && user.batch!.isNotEmpty)
                            Text('Batch: ${user.batch}',
                                style: TextStyle(fontSize: context.rf(13), color: isDark ? AppColors.gray400 : AppColors.gray600)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editAcademicInfo(context, ref, uid, user),
                      icon: Icon(Icons.edit_outlined, size: context.rs(20), color: AppColors.blue500),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.rs(16)),

              // Support Preferences Card
              _InfoCard(
                icon: Icons.psychology_outlined,
                title: 'Support Preferences',
                isDark: isDark,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Language: ${user.preferredLanguage ?? 'Not specified'}',
                              style: TextStyle(
                                  fontSize: context.rf(14),
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.gray900)),
                          const SizedBox(height: 4),
                          Text(
                            (user.supportInterests != null && user.supportInterests!.isNotEmpty)
                                ? 'Interests: ${user.supportInterests!.join(', ')}'
                                : 'Interests: Academic Stress, General Wellbeing',
                            style: TextStyle(fontSize: context.rf(13), color: isDark ? AppColors.gray400 : AppColors.gray600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editSupportPreferences(context, ref, uid, user),
                      icon: Icon(Icons.edit_outlined, size: context.rs(20), color: AppColors.blue500),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.rs(16)),

              // Personal Emergency Contact Card
              _InfoCard(
                icon: Icons.contact_emergency_rounded,
                title: 'Trusted Emergency Contact / Guardian',
                isDark: isDark,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              (user.emergencyContactName != null && user.emergencyContactName!.isNotEmpty)
                                  ? 'Name: ${user.emergencyContactName}'
                                  : 'Contact not set',
                              style: TextStyle(
                                  fontSize: context.rf(15),
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.gray900)),
                          const SizedBox(height: 4),
                          Text(
                              (user.emergencyContactPhone != null && user.emergencyContactPhone!.isNotEmpty)
                                  ? 'Phone: ${user.emergencyContactPhone}'
                                  : 'Tap edit to add a trusted parent/friend for emergency SOS alerts.',
                              style: TextStyle(fontSize: context.rf(13), color: isDark ? AppColors.gray400 : AppColors.gray600)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editEmergencyContact(context, ref, uid, user),
                      icon: Icon(Icons.edit_outlined, size: context.rs(20), color: AppColors.red500),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.rs(16)),

              // Current risk level
              if (user.latestRiskLevel != null) ...[
                _InfoCard(
                  icon: Icons.monitor_heart_rounded,
                  title: 'Current Wellbeing Status',
                  isDark: isDark,
                  child: Row(children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.rs(12), vertical: context.rs(6)),
                      decoration: BoxDecoration(
                        color: user.latestRiskLevel == 'red'
                            ? AppColors.riskRedBg
                                .withValues(alpha: isDark ? 0.2 : 1.0)
                            : user.latestRiskLevel == 'yellow'
                                ? AppColors.riskYellowBg
                                    .withValues(alpha: isDark ? 0.2 : 1.0)
                                : AppColors.riskGreenBg
                                    .withValues(alpha: isDark ? 0.2 : 1.0),
                        borderRadius: BorderRadius.circular(10),
                        border: isDark
                            ? Border.all(
                                color: user.latestRiskLevel == 'red'
                                    ? AppColors.riskRedFg.withValues(alpha: 0.3)
                                    : user.latestRiskLevel == 'yellow'
                                        ? AppColors.riskYellowFg
                                            .withValues(alpha: 0.3)
                                        : AppColors.riskGreenFg
                                            .withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Text(
                        user.latestRiskLevel == 'red'
                            ? '🔴 High Risk'
                            : user.latestRiskLevel == 'yellow'
                                ? '🟡 Moderate Risk'
                                : '🟢 Low Risk',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: context.rf(13),
                          color: user.latestRiskLevel == 'red'
                              ? AppColors.riskRedFg
                              : user.latestRiskLevel == 'yellow'
                                  ? AppColors.riskYellowFg
                                  : AppColors.riskGreenFg,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/screening'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.blue500),
                      child: Text('Check again',
                          style: TextStyle(fontSize: context.rf(14), fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ),
                SizedBox(height: context.rs(16)),
              ],

              // Screening count
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(FirestorePaths.screenings)
                    .where('studentUid', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snap) {
                  final count = snap.data?.docs.length ?? 0;
                  return _InfoCard(
                    icon: Icons.assignment_rounded,
                    title: 'Screenings Completed',
                    isDark: isDark,
                    child: Row(
                      children: [
                        Text('$count',
                            style: TextStyle(
                                fontSize: context.rf(32),
                                fontWeight: FontWeight.w800,
                                color: AppColors.blue500)),
                        SizedBox(width: context.rs(8)),
                        Text('total',
                            style: TextStyle(
                                fontSize: context.rf(14),
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray500,
                                fontWeight: FontWeight.w500)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/screening-history'),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.blue500),
                          child: Text('View all',
                              style: TextStyle(fontSize: context.rf(14), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: context.rs(16)),

              // Account info
              _InfoCard(
                icon: Icons.account_circle_rounded,
                title: 'Account Details',
                isDark: isDark,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LabelRow(
                          'Type', user.isAnonymous ? 'Anonymous' : 'Secured',
                          isDark: isDark),
                      if (user.email != null)
                        _LabelRow('Email', user.email!, isDark: isDark),
                      if (user.createdAt != null)
                        _LabelRow('Member since',
                            DateFormat('MMMM yyyy').format(user.createdAt!),
                            isDark: isDark),
                    ]),
              ),
              SizedBox(height: context.rs(32)),

              FilledButton.icon(
                onPressed: () => context.go('/settings'),
                icon: Icon(Icons.settings_rounded, size: context.rs(20)),
                label: Text('Go to Settings',
                    style:
                        TextStyle(fontSize: context.rf(16), fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  minimumSize: Size(double.infinity, context.rs(56)),
                  backgroundColor:
                      isDark ? AppColors.darkSurface2 : AppColors.gray900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.rs(16)),
                      side: isDark
                          ? const BorderSide(color: AppColors.darkBorder)
                          : BorderSide.none),
                ),
              ),
            ]),
          );
        },
        loading: () => const Center(child: AppLoadingState(itemCount: 4)),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.red500))),
      ),
    );
  }

  void _showVerificationDialog(
      BuildContext context, WidgetRef ref, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify DIU Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your DIU Student ID to request free access to professional psychologists.',
              style: TextStyle(fontSize: 14, color: AppColors.gray600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                hintText: 'e.g. 222-15-1234',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final val = controller.text.trim();
              if (val.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection(FirestorePaths.users)
                    .doc(uid)
                    .update({
                  'studentId': val,
                  'isDiuStudent': true,
                  'studentIdVerified': false, // Marks as pending for admin
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification request sent!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  void _editDisplayName(BuildContext context, WidgetRef ref, String uid, String current) async {
    final ctrl = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Name', style: TextStyle(fontSize: context.rf(18))),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Display Name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != current) {
      await FirebaseFirestore.instance.collection(FirestorePaths.users).doc(uid).update({'displayName': newName});
    }
  }

  void _editAcademicInfo(BuildContext context, WidgetRef ref, String uid, dynamic user) async {
    final deptCtrl = TextEditingController(text: user.department);
    final yearCtrl = TextEditingController(text: user.academicYear);
    final campusCtrl = TextEditingController(text: user.campus ?? 'Daffodil Smart City (DSC)');
    final batchCtrl = TextEditingController(text: user.batch ?? 'Batch 62');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('DIU Academic Context', style: TextStyle(fontSize: context.rf(18))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deptCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Department (e.g. CSE, EEE, SWE)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Academic Year / Semester', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: campusCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'DIU Campus (e.g. DSC Ashulia)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: batchCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Batch (e.g. Batch 62)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (result == true) {
      await FirebaseFirestore.instance.collection(FirestorePaths.users).doc(uid).update({
        'department': deptCtrl.text.trim(),
        'academicYear': yearCtrl.text.trim(),
        'campus': campusCtrl.text.trim(),
        'batch': batchCtrl.text.trim(),
      });
    }
  }

  void _editSupportPreferences(BuildContext context, WidgetRef ref, String uid, dynamic user) async {
    final langCtrl = TextEditingController(text: user.preferredLanguage ?? 'Bengali & English');
    final interestsCtrl = TextEditingController(
      text: (user.supportInterests != null && user.supportInterests!.isNotEmpty)
          ? user.supportInterests!.join(', ')
          : 'Academic Stress, Exam Anxiety, Sleep Issues',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Support Preferences', style: TextStyle(fontSize: context.rf(18))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: langCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Preferred Counseling Language', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: interestsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Support Topics / Interests (comma-separated)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (result == true) {
      final list = interestsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      await FirebaseFirestore.instance.collection(FirestorePaths.users).doc(uid).update({
        'preferredLanguage': langCtrl.text.trim(),
        'supportInterests': list,
      });
    }
  }

  Future<void> _editEmergencyContact(BuildContext context, WidgetRef ref, String uid, dynamic user) async {
    final nameCtrl = TextEditingController(text: user.emergencyContactName ?? '');
    final phoneCtrl = TextEditingController(text: user.emergencyContactPhone ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency Guardian / Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This trusted contact can be quickly reached during SOS or panic moments via the crisis page.', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Contact Name (e.g. Father, Roommate)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number (e.g. 017XXXXXXX)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save Contact')),
        ],
      ),
    );

    if (result == true) {
      await FirebaseFirestore.instance.collection(FirestorePaths.users).doc(uid).update({
        'emergencyContactName': nameCtrl.text.trim(),
        'emergencyContactPhone': phoneCtrl.text.trim(),
      });
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool isDark;

  const _InfoCard(
      {required this.icon,
      required this.title,
      required this.child,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon,
              size: 18, color: isDark ? AppColors.gray400 : AppColors.gray500),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  textBaseline: TextBaseline.alphabetic)),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

class _LabelRow extends StatelessWidget {
  final String label, value;
  final bool isDark;

  const _LabelRow(this.label, this.value, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                  fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.gray900,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/pseudonym_generator.dart';
import '../../../core/utils/responsive_util.dart';
import '../providers/auth_providers.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/responsive_page.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final String? initialPseudonym;
  const SignUpScreen({super.key, this.initialPseudonym});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _applyVerification = false;

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final studentId = _studentIdController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    if (_applyVerification) {
      if (!email.endsWith('@diu.edu.bd')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sign up with your student email to verify')),
        );
        return;
      }
      if (studentId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student ID is required for verification')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final cred =
          await ref.read(authRepositoryProvider).createAccount(email, password);

      // Generate initial pseudonym for chat
      final pseudonym = widget.initialPseudonym ?? generatePseudonym();

      // Create the user document in Firestore
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'role': 'student',
        'displayName': name,
        'pseudonym': pseudonym,
        'email': email,
        'isAnonymous': false,
        'language': 'en',
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'fcmToken': null,
        'isActive': true,
        'onboardingComplete': true,
        'studentId': studentId.isEmpty ? null : studentId,
        'isDiuStudent': _applyVerification,
        'studentIdVerified': false,
        'latestRiskLevel': null,
        'latestScreeningAt': null,
        'consentGiven': true,
        'consentVersion': AppConstants.consentVersion,
      });

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ResponsivePage(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.rs(4)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => context.go('/welcome'),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        padding: EdgeInsets.all(context.rs(8)),
                      ),
                      icon: Icon(Icons.arrow_back_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: context.rs(24)),
                    ),
                  ),
                  SizedBox(height: context.rs(16)),
                  Icon(Icons.person_add_rounded,
                      size: context.rs(64),
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(height: context.rs(16)),
                  Text(
                    'Join MindCare',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: context.rf(32),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.rs(8)),
                  Text(
                    'Create an account to save your progress. Your real name is kept private, while a generated Chat Pseudonym will be used for anonymous peer-support.',
                    style: TextStyle(
                        fontSize: context.rf(14),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.rs(32)),
                  AppSurface(
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(fontSize: context.rf(16)),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(fontSize: context.rf(16)),
                            prefixIcon: Icon(Icons.person_outline, size: context.rs(22)),
                          ),
                        ),
                        SizedBox(height: context.rs(16)),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: TextStyle(fontSize: context.rf(16)),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(fontSize: context.rf(16)),
                            prefixIcon: Icon(Icons.email_outlined, size: context.rs(22)),
                          ),
                        ),
                        SizedBox(height: context.rs(16)),
                        TextField(
                          controller: _studentIdController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: context.rf(16)),
                          decoration: InputDecoration(
                            labelText: 'Student ID (Optional)',
                            labelStyle: TextStyle(fontSize: context.rf(16)),
                            prefixIcon: Icon(Icons.badge_outlined, size: context.rs(22)),
                          ),
                        ),
                        SizedBox(height: context.rs(16)),
                        CheckboxListTile(
                          value: _applyVerification,
                          onChanged: (val) =>
                              setState(() => _applyVerification = val ?? false),
                          title: const Text('Apply for DIU Student Verification'),
                          subtitle: const Text(
                              'Requires @diu.edu.bd email and Student ID'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        SizedBox(height: context.rs(8)),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(fontSize: context.rf(16)),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(fontSize: context.rf(16)),
                            prefixIcon: Icon(Icons.lock_outlined, size: context.rs(22)),
                          ),
                        ),
                        SizedBox(height: context.rs(32)),
                        FilledButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: FilledButton.styleFrom(
                            minimumSize: Size(double.infinity, context.rs(56)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.rs(16))),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: context.rs(20),
                                  width: context.rs(20),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('Sign Up',
                                  style: TextStyle(
                                      fontSize: context.rf(16),
                                      fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: context.rs(24)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ',
                                style: TextStyle(
                                    fontSize: context.rf(14),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                            TextButton(
                              onPressed: () => context.go('/sign-in'),
                              style: TextButton.styleFrom(
                                minimumSize: Size(context.rs(48), context.rs(48)),
                              ),
                              child: Text('Sign In',
                                  style: TextStyle(
                                      fontSize: context.rf(14),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

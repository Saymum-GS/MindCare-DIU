import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/responsive_util.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _continueAnonymously() async {
    setState(() => _isLoading = true);
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      } else {
        context.push('/onboarding');
      }
      // Note: The GoRouter refresh listener will automatically redirect
      // to /onboarding when signInAnonymously completes if they don't
      // have a Firestore document yet.
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start anonymous session: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: context.rs(24), vertical: context.rs(32)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Illustration
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: context.rs(280)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(context.rs(32)),
                        child: Image.asset(
                          'assets/images/welcome_hero.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.rs(32)),
                  Text(
                    'MindCare@DIU',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: context.rf(36),
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: context.rs(16)),
                  Text(
                    'Mental health support, peer counseling, and safe spaces for Daffodil International University students.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.rf(16),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: context.rs(48)),

                  // Actions
                  FilledButton(
                    onPressed: _isLoading ? null : _continueAnonymously,
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, context.rs(56)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.rs(16))),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: context.rs(24),
                            height: context.rs(24),
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Get Started Anonymously',
                            style: TextStyle(
                                fontSize: context.rf(16),
                                fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: context.rs(16)),
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => context.push('/sign-up'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, context.rs(56)),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.3),
                          width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.rs(16))),
                    ),
                    child: Text('Create an Account',
                        style: TextStyle(
                            fontSize: context.rf(16),
                            fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: context.rs(16)),
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
                        onPressed: _isLoading ? null : () => context.push('/sign-in'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          textStyle: TextStyle(
                              fontSize: context.rf(14),
                              fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Sign In'),
                      ),
                    ],
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

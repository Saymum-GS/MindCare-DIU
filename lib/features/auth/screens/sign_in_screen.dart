// lib/features/auth/screens/sign_in_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/responsive_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    
    final navigator = GoRouter.of(context);
    
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted && cred.user != null) {
        final doc = await FirebaseFirestore.instance
            .collection(FirestorePaths.users)
            .doc(cred.user!.uid)
            .get();
        final role = doc.data()?['role'] as String? ?? 'student';
        if (role == 'admin') {
          navigator.go('/admin');
        } else if (role == 'volunteer') {
          navigator.go('/volunteer');
        } else if (role == 'psychologist') {
          navigator.go('/psychologist/home');
        } else {
          navigator.go('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ResponsivePage(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => context.go('/onboarding'),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    icon: Icon(Icons.arrow_back_rounded,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                const SizedBox(height: 24),
                Icon(
                  Icons.health_and_safety_rounded,
                  size: context.rs(64),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'MINDCARE@DIU',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: context.rf(28),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: context.rf(16),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                AppSurface(
                  child: Column(
                    children: [
                      if (_error != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.riskRedBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    AppColors.riskRedFg.withValues(alpha: 0.3)),
                          ),
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: AppColors.riskRedFg, fontSize: 13)),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                labelText: 'Email address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) => (v?.contains('@') == true)
                                  ? null
                                  : 'Enter a valid email',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v?.length ?? 0) >= 6
                                  ? null
                                  : 'Password too short',
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    context.push('/forgot-password'),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                ),
                                child: Text('Forgot Password?',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 32),
                            FilledButton(
                              onPressed: _loading ? null : _submit,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Sign In',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Don\'t have an account? ',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                                TextButton(
                                  onPressed: () => context.push('/sign-up'),
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(48, 48),
                                  ),
                                  child: Text('Sign Up',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color:
                                Theme.of(context).colorScheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                        child: Divider(
                            color:
                                Theme.of(context).colorScheme.outlineVariant)),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _loading ? null : () async {
                    setState(() { _loading = true; _error = null; });
                    final navigator = GoRouter.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      if (FirebaseAuth.instance.currentUser == null) {
                        await FirebaseAuth.instance.signInAnonymously();
                        if (mounted) navigator.go('/onboarding');
                      } else {
                        if (mounted) navigator.go('/onboarding');
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _loading = false);
                        messenger.showSnackBar(
                          SnackBar(content: Text('Failed to start anonymous session: $e')),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, context.rs(56)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Continue as Student (Anonymous)', 
                      style: TextStyle(fontSize: context.rf(16), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

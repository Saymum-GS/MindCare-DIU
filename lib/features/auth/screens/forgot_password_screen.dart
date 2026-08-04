import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/responsive_page.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _success = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _email.text.trim());
      if (mounted) setState(() => _success = true);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.code == 'user-not-found'
              ? 'No account found with this email.'
              : 'Failed to send reset email. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password', style: TextStyle(fontSize: context.rf(17))),
      ),
      body: SafeArea(
        child: ResponsivePage(
          maxWidth: 560,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.rs(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.rs(24)),
                Icon(Icons.lock_reset_rounded,
                    size: context.rs(64),
                    color: Theme.of(context).colorScheme.primary),
                SizedBox(height: context.rs(24)),
                Text(
                  'Forgot your password?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: context.rf(28),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: context.rs(8)),
                Text(
                  'Enter your email address and we will send you instructions to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.rf(16),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: context.rs(32)),
                if (_success)
                  AppCard(
                    child: Column(
                      children: [
                        Icon(Icons.mark_email_read_rounded,
                            size: context.rs(48), color: AppColors.riskGreenFg),
                        SizedBox(height: context.rs(16)),
                        Text(
                          'Check your email',
                          style: TextStyle(
                              fontSize: context.rf(18),
                              fontWeight: FontWeight.bold,
                              color: AppColors.riskGreenFg),
                        ),
                        SizedBox(height: context.rs(8)),
                        Text(
                          'We have sent a password reset link to ${_email.text}. Please check your inbox.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: context.rf(15),
                              color: AppColors.gray700,
                              height: 1.5),
                        ),
                        SizedBox(height: context.rs(24)),
                        FilledButton(
                          onPressed: () => context.go('/sign-in'),
                          style: FilledButton.styleFrom(
                              minimumSize:
                                  Size(double.infinity, context.rs(56))),
                          child: Text('Back to Sign In',
                              style: TextStyle(
                                  fontSize: context.rf(16),
                                  fontWeight: FontWeight.w700)),
                        )
                      ],
                    ),
                  )
                else
                  AppCard(
                    child: Column(
                      children: [
                        if (_error != null) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(context.rs(14)),
                            decoration: BoxDecoration(
                              color: AppColors.riskRedBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.riskRedFg
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Text(_error!,
                                style: TextStyle(
                                    color: AppColors.riskRedFg,
                                    fontSize: context.rf(13))),
                          ),
                          SizedBox(height: context.rs(16)),
                        ],
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                style: TextStyle(fontSize: context.rf(16)),
                                decoration: InputDecoration(
                                  labelText: 'Email address',
                                  labelStyle:
                                      TextStyle(fontSize: context.rf(16)),
                                  prefixIcon:
                                      Icon(Icons.email_outlined, size: context.rs(22)),
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                ),
                                validator: (v) => (v?.contains('@') == true)
                                    ? null
                                    : 'Enter a valid email',
                              ),
                              SizedBox(height: context.rs(32)),
                              FilledButton(
                                onPressed: _loading ? null : _submit,
                                style: FilledButton.styleFrom(
                                  minimumSize:
                                      Size(double.infinity, context.rs(56)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(context.rs(16))),
                                ),
                                child: _loading
                                    ? SizedBox(
                                        height: context.rs(20),
                                        width: context.rs(20),
                                        child: const CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2))
                                    : Text('Send Reset Link',
                                        style: TextStyle(
                                            fontSize: context.rf(16),
                                            fontWeight: FontWeight.bold)),
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
        ),
      ),
    );
  }
}

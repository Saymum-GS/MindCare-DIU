// lib/features/auth/screens/splash_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/utils/responsive_util.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    _resolve();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _resolve() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/welcome');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();
      if (!mounted) return;

      if (!doc.exists ||
          !(doc.data()?['onboardingComplete'] as bool? ?? false)) {
        context.go('/onboarding');
        return;
      }

      // Update FCM token
      try {
        final token = await FirebaseMessaging.instance.getToken();
        await FirebaseFirestore.instance
            .collection(FirestorePaths.users)
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      if (!mounted) return;
      final role = doc.data()?['role'] as String? ?? 'student';
      
      // Route based on role
      if (role == 'admin') {
        context.go('/admin');
      } else if (role == 'volunteer') {
        context.go('/volunteer');
      } else if (role == 'psychologist') {
        context.go('/psychologist/home');
      } else {
        context.go('/home');
      }
    } catch (_) {
      if (mounted) context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: context.rs(90),
                  height: context.rs(90),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(context.rs(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.favorite_rounded,
                      color: Colors.white, size: context.rs(48)),
                ),
                const SizedBox(height: 24),
                Text('MindCare',
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: context.rf(42),
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w400)),
                Text('@DIU',
                    style: GoogleFonts.outfit(
                        fontSize: context.rf(16),
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 4)),
                const SizedBox(height: 64),
                SizedBox(
                  width: context.rs(28),
                  height: context.rs(28),
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

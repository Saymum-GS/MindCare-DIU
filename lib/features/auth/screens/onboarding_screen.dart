import '../../../core/utils/pseudonym_generator.dart';
import '../../../core/utils/responsive_util.dart';
// lib/features/auth/screens/onboarding_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  late String _pseudonym;
  bool _loading = false;
  late AnimationController _pseudonymCtrl;
  late Animation<double> _pseudonymFade;
  late Animation<Offset> _pseudonymSlide;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _pseudonym = generatePseudonym();
    _nameController = TextEditingController(text: _pseudonym);
    _pseudonymCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pseudonymFade =
        CurvedAnimation(parent: _pseudonymCtrl, curve: Curves.easeOut);
    _pseudonymSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _pseudonymCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pseudonymCtrl.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 0) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _page = 1);
      Future.delayed(
          const Duration(milliseconds: 400), () => _pseudonymCtrl.forward());
    } else if (_page == 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _page = 2);
      _createAccount();
    }
  }

  Future<void> _createAccount() async {
    setState(() => _loading = true);
    final displayName = _nameController.text.trim().isEmpty
        ? 'Anonymous'
        : _nameController.text.trim();
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final cred = await FirebaseAuth.instance.signInAnonymously();
        user = cred.user;
      }

      if (user == null) throw 'Authentication failed';
      final uid = user.uid;

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        // Ignore token errors on web
      }

      // Check if document already exists to avoid overwriting verified status
      final doc = await FirebaseFirestore.instance.collection(FirestorePaths.users).doc(uid).get();
      final existingData = doc.data() ?? {};

      await FirebaseFirestore.instance.collection(FirestorePaths.users).doc(uid).set({
        'uid': uid,
        'role': existingData['role'] ?? 'student',
        'displayName': displayName,
        'pseudonym': displayName,
        'email': user.email,
        'isAnonymous': user.isAnonymous,
        'isActive': true,
        'onboardingComplete': true,
        'fcmToken': fcmToken,
        'createdAt': existingData['createdAt'] ?? FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'isDiuStudent': existingData['isDiuStudent'] ?? false,
        'studentIdVerified': existingData['studentIdVerified'] ?? false,
        'latestRiskLevel': existingData['latestRiskLevel'],
        'latestScreeningAt': existingData['latestScreeningAt'],
        'consentGiven': true,
        'consentVersion': '2026-01',
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _page = 0;
        });
        _pageCtrl.animateToPage(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip to crisis
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MindCare@DIU',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18, color: AppColors.blue500)),
                  TextButton.icon(
                    onPressed: () => context.go('/crisis'),
                    icon: const Icon(Icons.shield_outlined,
                        size: 16, color: AppColors.red500),
                    label: const Text('Crisis Help',
                        style: TextStyle(
                            color: AppColors.red500,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
            // Step indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _page == i ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _page == i
                                ? AppColors.blue500
                                : AppColors.blue700.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildConsentPage(),
                  _buildPseudonymPage(),
                  _buildLoadingPage()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue800, AppColors.blue900],
          stops: [0.0, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: context.rs(220)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/onboarding_peer.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Your privacy matters\nhere.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: context.rf(32), height: 1.2, color: Colors.white)),
            const SizedBox(height: 16),
            Text(
                'You can use this app completely anonymously - no email, no real name, no tracking.',
                style: TextStyle(
                    fontSize: context.rf(16), color: AppColors.blue200, height: 1.6)),
            const SizedBox(height: 32),
            _consentItem(
                Icons.person_outline_rounded,
                'A private Chat Pseudonym',
                'Used only for anonymous peer-support chats'),
            _consentItem(Icons.assignment_outlined, 'Your screening answers',
                'Shared only with your care team'),
            _consentItem(Icons.chat_bubble_outline, 'Chat messages',
                'Never linked to your real identity'),
            _consentItem(Icons.sentiment_satisfied_outlined, 'Mood entries',
                'Visible only to you'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded,
                      color: AppColors.blue200, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'We never collect your real name, phone, location, or device ID.',
                        style: TextStyle(
                            color: AppColors.blue200,
                            fontSize: 13,
                            height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _next,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.blue800,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('I understand and agree'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _consentItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.riskGreenBgDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.riskGreenFgDark, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.blue200)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPseudonymPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _pseudonymFade,
            child: SlideTransition(
              position: _pseudonymSlide,
              child: Column(
                children: [
                  Container(
                    width: context.rs(80),
                    height: context.rs(80),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.blue400, AppColors.blue600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.blue500.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Icon(Icons.person_rounded,
                        color: Colors.white, size: context.rs(44)),
                  ),
                  const SizedBox(height: 32),
                  Text('Your Chat Pseudonym\nfor MindCare is:',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: context.rf(28), height: 1.3, color: AppColors.gray900),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: context.rs(24), vertical: context.rs(16)),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(context.rs(24)),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8)),
                      ],
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: GoogleFonts.outfit(
                        fontSize: context.rf(32),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      'This is your anonymous alias.\nYour real profile name can be added later.',
                      style: TextStyle(
                          fontSize: context.rf(14), color: AppColors.gray500, height: 1.6),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _pseudonym = generatePseudonym();
                      _nameController.text = _pseudonym;
                      _pseudonymCtrl.reset();
                      _pseudonymCtrl.forward();
                    }),
                    child: const Text('Generate a different name'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: _next,
            style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52)),
            child: const Text("Continue with this name"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.blue50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                        color: AppColors.blue500, strokeWidth: 3),
                  )
                : const Icon(Icons.check_rounded,
                    color: AppColors.blue500, size: 44),
          ),
          const SizedBox(height: 24),
          Text('Setting up your private space...',
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22, color: AppColors.gray900),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('This only takes a moment.',
              style: TextStyle(color: AppColors.gray500, fontSize: 14)),
        ],
      ),
    );
  }
}

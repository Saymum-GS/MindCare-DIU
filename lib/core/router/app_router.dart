import '../../shared/models/content_model.dart';
import '../../shared/models/booking_model.dart';
// lib/core/router/app_router.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/firestore_paths.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/crisis/crisis_screen.dart';
import '../../features/screening/screening_select_screen.dart';
import '../../features/screening/screening_screen.dart';
import '../../features/screening/screening_result_screen.dart';
import '../../core/utils/risk_engine.dart';
import '../../core/router/role_scaffold.dart';
import '../../features/mood/screens/mood_tracker_screen.dart';
import '../../features/content/screens/content_library_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/chat/screens/chat_request_screen.dart';
import '../../features/chat/screens/chat_session_screen.dart';
import '../../features/chat/screens/session_summary_screen.dart';
import '../../features/chat/screens/rating_screen.dart';
import '../../features/chat/screens/chat_history_screen.dart';
import '../../features/psychologist/screens/psychologist_session_note_screen.dart';
import '../../features/psychologist/screens/psychologist_profile_edit_screen.dart';
import '../../features/notifications/notification_center_screen.dart';
import '../../features/booking/screens/psychologist_list_screen.dart';
import '../../features/booking/screens/psychologist_profile_screen.dart';
import '../../features/booking/screens/slot_picker_screen.dart';
import '../../features/booking/screens/payment_simulation_screen.dart';
import '../../features/booking/screens/bookings_list_screen.dart';
import '../../features/booking/screens/booking_detail_screen.dart';
import '../../features/booking/screens/payment_history_screen.dart';
import '../../features/mood/screens/mood_history_screen.dart';
import '../../features/content/screens/content_detail_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/admin_incidents_screen.dart';
import '../../features/admin/admin_users_screen.dart';
import '../../features/admin/admin_verify_student_screen.dart';
import '../../features/admin/admin_audit_screen.dart';
import '../../features/admin/admin_content_screen.dart';
import '../../features/info/privacy_policy_screen.dart';
import '../../features/info/help_faq_screen.dart';
import '../../features/info/about_screen.dart';
import '../../features/auth/screens/student_profile_screen.dart';
import '../../features/screening/screening_history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/volunteer/screens/volunteer_home_screen.dart';
import '../../features/volunteer/screens/volunteer_profile_edit_screen.dart';
import '../../features/psychologist/screens/psychologist_home_screen.dart';
import '../../features/psychologist/screens/psychologist_calendar_screen.dart';
import '../../features/psychologist/screens/psychologist_bookings_screen.dart';

import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';

// Transition helpers
CustomTransitionPage fadeTransition(Widget child, LocalKey? key) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage slideUpTransition(Widget child, LocalKey? key) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((dynamic _) => notifyListeners());
  }
  late final StreamSubscription _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable:
        GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) async {
      final path = state.uri.path;
      // RULE 1 (ABSOLUTE): Crisis screen is ALWAYS accessible
      if (path == '/crisis') return null;

      final user = FirebaseAuth.instance.currentUser;

      // Public routes that should always be accessible to non-auth users
      final isAuthRoute = path == '/' ||
          path == '/welcome' ||
          path == '/sign-in' ||
          path == '/sign-up' ||
          path == '/forgot-password';

      if (user == null) {
        return isAuthRoute ? null : '/welcome';
      }

      // If user is authenticated, check their state
      try {
        final doc = await FirebaseFirestore.instance
            .collection(FirestorePaths.users)
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          // Profile doesn't exist yet. 
          // If they are on Onboarding, let them finish.
          if (path == '/onboarding') return null;
          // If they are actively signing up, let them finish.
          if (path == '/sign-up') return null;
          // If they just signed up/signed in but have no doc, they MUST go to onboarding
          return '/onboarding';
        }

        final data = doc.data()!;
        final bool onboardingComplete = data['onboardingComplete'] ?? false;
        final String role = data['role'] ?? 'student';

        if (!onboardingComplete) {
          if (path == '/onboarding') return null;
          return '/onboarding';
        }

        // If they are on a public auth route but already have a complete profile,
        // send them to their role-appropriate dashboard.
        if (isAuthRoute) {
          if (role == 'admin') return '/admin';
          if (role == 'volunteer') return '/volunteer';
          if (role == 'psychologist') return '/psychologist/home';
          return '/home';
        }

        // Role-based access control (RBAC)
        if ((path == '/admin' || path.startsWith('/admin/')) && role != 'admin') {
          return '/home';
        }
        if ((path == '/volunteer' || path.startsWith('/volunteer/')) &&
            role != 'volunteer') {
          return '/home';
        }
        if ((path == '/psychologist' || path.startsWith('/psychologist/')) &&
            role != 'psychologist') {
          return '/home';
        }

      } catch (e) {
        // If there's an error (e.g. network), allow current path to avoid infinite loops
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
          path: '/',
          pageBuilder: (c, s) =>
              fadeTransition(const SplashScreen(), s.pageKey)),
      GoRoute(
          path: '/welcome',
          pageBuilder: (c, s) =>
              slideUpTransition(const WelcomeScreen(), s.pageKey)),
      GoRoute(
          path: '/onboarding',
          pageBuilder: (c, s) =>
              slideUpTransition(const OnboardingScreen(), s.pageKey)),
      GoRoute(
          path: '/sign-in',
          pageBuilder: (c, s) =>
              fadeTransition(const SignInScreen(), s.pageKey)),
      GoRoute(
          path: '/sign-up',
          pageBuilder: (c, s) =>
              fadeTransition(const SignUpScreen(), s.pageKey)),
      GoRoute(
          path: '/forgot-password',
          pageBuilder: (c, s) =>
              slideUpTransition(const ForgotPasswordScreen(), s.pageKey)),

      // CRISIS - zero auth required, always renders
      GoRoute(
          path: '/crisis',
          pageBuilder: (c, s) =>
              slideUpTransition(const CrisisScreen(), s.pageKey)),

      // Main Shell for Authenticated Users
      ShellRoute(
        builder: (context, state, child) => RoleScaffold(child: child),
        routes: [
          // Student Dashboard Tabs
          GoRoute(
              path: '/home',
              pageBuilder: (c, s) =>
                  fadeTransition(const HomeScreen(), s.pageKey)),
          GoRoute(
              path: '/screening',
              pageBuilder: (c, s) =>
                  fadeTransition(const ScreeningSelectScreen(), s.pageKey)),
          GoRoute(
              path: '/chat-request',
              pageBuilder: (c, s) =>
                  fadeTransition(const ChatRequestScreen(), s.pageKey)),
          GoRoute(
              path: '/content',
              pageBuilder: (c, s) =>
                  fadeTransition(const ContentLibraryScreen(), s.pageKey)),
          GoRoute(
              path: '/settings',
              pageBuilder: (c, s) =>
                  fadeTransition(const SettingsScreen(), s.pageKey)),
          GoRoute(
              path: '/chat-history',
              pageBuilder: (c, s) =>
                  fadeTransition(const ChatHistoryScreen(), s.pageKey)),

          // Volunteer Dashboard Tabs
          GoRoute(
              path: '/volunteer',
              pageBuilder: (c, s) =>
                  fadeTransition(const VolunteerHomeScreen(), s.pageKey)),

          // Psychologist Dashboard Tabs
          GoRoute(
              path: '/psychologist/home',
              pageBuilder: (c, s) =>
                  fadeTransition(const PsychologistHomeScreen(), s.pageKey)),
          GoRoute(
              path: '/psychologist/calendar',
              pageBuilder: (c, s) => fadeTransition(
                  const PsychologistCalendarScreen(), s.pageKey)),
          GoRoute(
              path: '/psychologist/bookings',
              pageBuilder: (c, s) => fadeTransition(
                  const PsychologistBookingsScreen(), s.pageKey)),

          // Admin Dashboard Tabs
          GoRoute(
              path: '/admin',
              pageBuilder: (c, s) =>
                  fadeTransition(const AdminDashboardScreen(), s.pageKey)),
          GoRoute(
              path: '/admin/incidents',
              pageBuilder: (c, s) =>
                  fadeTransition(const AdminIncidentsScreen(), s.pageKey)),
          GoRoute(
              path: '/admin/users',
              pageBuilder: (c, s) =>
                  fadeTransition(const AdminUsersScreen(), s.pageKey)),
          GoRoute(
              path: '/admin/verify',
              pageBuilder: (c, s) =>
                  fadeTransition(const AdminVerifyStudentScreen(), s.pageKey)),
          GoRoute(
              path: '/admin/content',
              pageBuilder: (c, s) =>
                  fadeTransition(const AdminContentScreen(), s.pageKey)),
          GoRoute(
              path: '/admin/audit',
              pageBuilder: (c, s) =>
                  fadeTransition(const AdminAuditScreen(), s.pageKey)),
        ],
      ),

      // Full-screen routes (Pushed on top of the shell)
      GoRoute(
          path: '/notifications',
          pageBuilder: (c, s) =>
              slideUpTransition(const NotificationCenterScreen(), s.pageKey)),
      GoRoute(
        path: '/screening/:instrument',
        pageBuilder: (c, s) => slideUpTransition(
            ScreeningScreen(instrument: s.pathParameters['instrument']!),
            s.pageKey),
      ),
      GoRoute(
        path: '/screening-result',
        pageBuilder: (c, s) => slideUpTransition(
            ScreeningResultScreen(result: s.extra as RiskResult), s.pageKey),
      ),
      GoRoute(
          path: '/mood',
          pageBuilder: (c, s) =>
              slideUpTransition(const MoodTrackerScreen(), s.pageKey)),
      GoRoute(
          path: '/mood/history',
          pageBuilder: (c, s) =>
              slideUpTransition(const MoodHistoryScreen(), s.pageKey)),
      GoRoute(
        path: '/content/detail',
        pageBuilder: (c, s) => slideUpTransition(
            ContentDetailScreen(content: s.extra as ContentItem), s.pageKey),
      ),
      GoRoute(
        path: '/chat/:sessionId',
        pageBuilder: (c, s) => fadeTransition(
            ChatSessionScreen(sessionId: s.pathParameters['sessionId']!),
            s.pageKey),
      ),
      GoRoute(
        path: '/summary/:sessionId',
        pageBuilder: (c, s) => slideUpTransition(
            SessionSummaryScreen(sessionId: s.pathParameters['sessionId']!),
            s.pageKey),
      ),
      GoRoute(
        path: '/rating/:sessionId',
        pageBuilder: (c, s) => slideUpTransition(
            RatingScreen(sessionId: s.pathParameters['sessionId']!), s.pageKey),
      ),
      GoRoute(
          path: '/psychologists',
          pageBuilder: (c, s) =>
              slideUpTransition(const PsychologistListScreen(), s.pageKey)),
      GoRoute(
        path: '/psychologists/:id',
        redirect: (c, s) => s.extra == null ? '/home' : null,
        pageBuilder: (c, s) => slideUpTransition(
            PsychologistProfileScreen(profile: s.extra as PsychologistProfile),
            s.pageKey),
      ),
      GoRoute(
        path: '/psychologists/:id/slots',
        redirect: (c, s) => s.extra == null ? '/home' : null,
        pageBuilder: (c, s) => slideUpTransition(
            SlotPickerScreen(profile: s.extra as PsychologistProfile),
            s.pageKey),
      ),
      GoRoute(
        path: '/checkout',
        redirect: (c, s) => s.extra == null ? '/home' : null,
        pageBuilder: (c, s) {
          final extra = s.extra as Map<String, dynamic>;
          return slideUpTransition(
              PaymentSimulationScreen(
                slot: extra['slot'] as BookingSlot,
                profile: extra['profile'] as PsychologistProfile,
                sessionType: extra['sessionType'] as String? ?? 'video',
                problemNote: extra['problemNote'] as String? ?? 'None',
              ),
              s.pageKey);
        },
      ),
      GoRoute(
          path: '/bookings',
          pageBuilder: (c, s) =>
              slideUpTransition(const BookingsListScreen(), s.pageKey)),
      GoRoute(
        path: '/booking-detail',
        pageBuilder: (c, s) => slideUpTransition(
            BookingDetailScreen(bookingId: s.extra as String), s.pageKey),
      ),
      GoRoute(
          path: '/payments',
          pageBuilder: (c, s) =>
              slideUpTransition(const PaymentHistoryScreen(), s.pageKey)),
      GoRoute(
          path: '/privacy',
          pageBuilder: (c, s) =>
              slideUpTransition(const PrivacyPolicyScreen(), s.pageKey)),
      GoRoute(
          path: '/help',
          pageBuilder: (c, s) =>
              slideUpTransition(const HelpFaqScreen(), s.pageKey)),
      GoRoute(
          path: '/about',
          pageBuilder: (c, s) =>
              slideUpTransition(const AboutScreen(), s.pageKey)),
      GoRoute(
          path: '/profile',
          pageBuilder: (c, s) =>
              slideUpTransition(const StudentProfileScreen(), s.pageKey)),
      GoRoute(
          path: '/screening-history',
          pageBuilder: (c, s) =>
              slideUpTransition(const ScreeningHistoryScreen(), s.pageKey)),
      GoRoute(
          path: '/volunteer/home',
          pageBuilder: (c, s) =>
              slideUpTransition(const VolunteerHomeScreen(), s.pageKey)),
      GoRoute(
          path: '/volunteer/profile',
          pageBuilder: (c, s) => slideUpTransition(
              const VolunteerProfileEditScreen(), s.pageKey)),
      GoRoute(
          path: '/psychologist/profile',
          pageBuilder: (c, s) => slideUpTransition(
              const PsychologistProfileEditScreen(), s.pageKey)),
      GoRoute(
        path: '/psychologist/bookings/:id/note',
        pageBuilder: (c, s) => slideUpTransition(
            PsychologistSessionNoteScreen(slotId: s.pathParameters['id']!),
            s.pageKey),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

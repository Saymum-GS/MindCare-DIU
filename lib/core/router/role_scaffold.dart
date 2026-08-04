import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_loading_state.dart';

class RoleScaffold extends ConsumerWidget {
  final Widget child;
  const RoleScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
              body: Center(child: Text('Initializing profile...')));
        }

        if (!user.isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authRepositoryProvider).signOut();
          });
          return const Scaffold(
            body: Center(
              child: Text(
                'Your account has been deactivated by an admin.',
                style: TextStyle(fontSize: 16, color: AppColors.red500),
              ),
            ),
          );
        }

        final location = GoRouterState.of(context).uri.path;

        if (user.role == 'student') {
          return _buildStudentScaffold(context, location);
        } else if (user.role == 'volunteer') {
          return _buildVolunteerScaffold(context, location);
        } else if (user.role == 'psychologist') {
          return _buildPsychologistScaffold(context, location);
        } else if (user.role == 'admin') {
          return _buildAdminScaffold(context, ref, location);
        }

        return const Scaffold(body: Center(child: Text('Unknown role')));
      },
      loading: () =>
          const Scaffold(body: Center(child: AppLoadingState(itemCount: 4))),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  int _getStudentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/screening')) return 1;
    if (location.startsWith('/chat-request') || location.startsWith('/chat')) {
      return 2;
    }
    if (location.startsWith('/content')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  Widget _buildStudentScaffold(BuildContext context, String location) {
    final index = _getStudentIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (idx) {
          switch (idx) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/screening');
              break;
            case 2:
              context.go('/chat-request');
              break;
            case 3:
              context.go('/content');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Check-in'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Talk'),
          NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: 'Learn'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }

  int _getVolunteerIndex(String location) {
    if (location == '/volunteer') return 0;
    if (location == '/chat-history') return 1;
    if (location == '/settings') return 2;
    return 0;
  }

  Widget _buildVolunteerScaffold(BuildContext context, String location) {
    final index = _getVolunteerIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (idx) {
          switch (idx) {
            case 0:
              context.go('/volunteer');
              break;
            case 1:
              context.go('/chat-history');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.queue_outlined),
              selectedIcon: Icon(Icons.queue),
              label: 'Queue'),
          NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }

  int _getPsychologistIndex(String location) {
    if (location == '/psychologist/home') return 0;
    if (location == '/psychologist/calendar') return 1;
    if (location == '/psychologist/bookings') return 2;
    if (location == '/chat-history') return 3;
    if (location == '/settings') return 4;
    return 0;
  }

  Widget _buildPsychologistScaffold(BuildContext context, String location) {
    final index = _getPsychologistIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (idx) {
          switch (idx) {
            case 0:
              context.go('/psychologist/home');
              break;
            case 1:
              context.go('/psychologist/calendar');
              break;
            case 2:
              context.go('/psychologist/bookings');
              break;
            case 3:
              context.go('/chat-history');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Slots'),
          NavigationDestination(
              icon: Icon(Icons.event_available_outlined),
              selectedIcon: Icon(Icons.event_available),
              label: 'Bookings'),
          NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }

  int _getAdminIndex(String location) {
    if (location == '/admin') return 0;
    if (location == '/admin/incidents') return 1;
    if (location == '/admin/users') return 2;
    if (location == '/admin/verify') return 3;
    if (location == '/admin/content') return 4;
    if (location == '/admin/audit') return 5;
    return 0;
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) {
      context.go('/welcome');
    }
  }

  Widget _buildAdminScaffold(
      BuildContext context, WidgetRef ref, String location) {
    final index = _getAdminIndex(location);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindCare Admin'),
        centerTitle: false,
        backgroundColor: AppColors.blue900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: index,
        onDestinationSelected: (i) {
          Navigator.pop(context); // Close drawer
          switch (i) {
            case 0:
              context.go('/admin');
              break;
            case 1:
              context.go('/admin/incidents');
              break;
            case 2:
              context.go('/admin/users');
              break;
            case 3:
              context.go('/admin/verify');
              break;
            case 4:
              context.go('/admin/content');
              break;
            case 5:
              context.go('/admin/audit');
              break;
          }
        },
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 20, 16, 10),
            child: Text(
              'Admin Panel',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber),
            label: Text('Incidents'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: Text('Users'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: Text('Verify Students'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: Text('Content'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: Text('Audit Logs'),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              _signOut(context, ref);
            },
          ),
        ],
      ),
      body: child,
    );
  }
}

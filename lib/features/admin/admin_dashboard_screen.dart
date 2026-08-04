// lib/features/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive_util.dart';
import 'providers/admin_providers.dart';
import '../../core/theme/app_colors.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(allIncidentsProvider);
    final usersAsync = ref.watch(allUsersProvider);
    final pendingStudentsAsync = ref.watch(pendingStudentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: Text('Admin Console',
            style: TextStyle(fontSize: context.rf(17), fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: EdgeInsets.all(context.rs(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: context.rf(22),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: context.rs(16)),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmall = constraints.maxWidth < 360;
                      final card1 = _buildGridCard(
                        context: context,
                        title: 'Open Incidents',
                        value: incidentsAsync.when(
                          data: (incidents) =>
                              '${incidents.where((i) => i.status == 'open').length}',
                          loading: () => '...',
                          error: (_, __) => '!',
                        ),
                        subtitle: incidentsAsync.when(
                          data: (incidents) {
                            final highRisk = incidents
                                .where((i) =>
                                    i.status == 'open' && i.riskLevel == 'red')
                                .length;
                            if (highRisk > 0) {
                              return '$highRisk High Risk\nRequires immediate action';
                            }
                            return 'All cases manageable';
                          },
                          loading: () => null,
                          error: (_, __) => null,
                        ),
                        color: AppColors.red500,
                        bgColor: isDark
                            ? AppColors.red900.withValues(alpha: 0.3)
                            : AppColors.red50,
                        icon: Icons.crisis_alert_rounded,
                        onTap: () => context.go('/admin/incidents'),
                        isDark: isDark,
                      );
                      final card2 = _buildGridCard(
                        context: context,
                        title: 'Pending ID Verify',
                        value: pendingStudentsAsync.when(
                          data: (users) => '${users.length}',
                          loading: () => '...',
                          error: (_, __) => '!',
                        ),
                        subtitle: pendingStudentsAsync.when(
                          data: (users) {
                            final now = DateTime.now();
                            final staleCount = users.where((u) {
                              if (u.createdAt == null) return false;
                              return now.difference(u.createdAt!).inDays > 3;
                            }).length;
                            if (staleCount > 0) {
                              return '$staleCount Overdue (> 3 days)\nPlease verify ASAP';
                            }
                            return 'Up to date';
                          },
                          loading: () => null,
                          error: (_, __) => null,
                        ),
                        color: AppColors.amber600,
                        bgColor: isDark
                            ? AppColors.amber600.withValues(alpha: 0.15)
                            : AppColors.amber50,
                        icon: Icons.how_to_reg_rounded,
                        onTap: () => context.go('/admin/verify'),
                        isDark: isDark,
                      );

                      if (isSmall) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            card1,
                            SizedBox(height: context.rs(16)),
                            card2,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: card1),
                          SizedBox(width: context.rs(16)),
                          Expanded(child: card2),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: context.rs(16)),
                  _buildListCard(
                    context: context,
                    title: 'User Management',
                    subtitle: usersAsync.when(
                      data: (users) => '${users.length} total users',
                      loading: () => 'Loading...',
                      error: (_, __) => 'Error loading',
                    ),
                    color: AppColors.blue500,
                    icon: Icons.people_alt_rounded,
                    onTap: () => context.go('/admin/users'),
                    isDark: isDark,
                  ),
                  SizedBox(height: context.rs(24)),
                  Text(
                    'System & Content',
                    style: TextStyle(
                      fontSize: context.rf(22),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: context.rs(16)),
                  _buildListCard(
                    context: context,
                    title: 'Content Library',
                    subtitle: 'Manage articles, videos & resources',
                    color: AppColors.sage600,
                    icon: Icons.library_books_rounded,
                    onTap: () => context.go('/admin/content'),
                    isDark: isDark,
                  ),
                  SizedBox(height: context.rs(16)),
                  _buildListCard(
                    context: context,
                    title: 'Audit Logs',
                    subtitle: 'View system logs and actions',
                    color: AppColors.gray600,
                    icon: Icons.receipt_long_rounded,
                    onTap: () => context.go('/admin/audit'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required BuildContext context,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
    required Color bgColor,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(context.rs(24)),
        border: Border.all(
            color: subtitle != null && subtitle.contains('High Risk')
                ? AppColors.red500
                : (isDark ? AppColors.darkBorder : AppColors.gray200)),
        boxShadow: [
          BoxShadow(
            color: subtitle != null && subtitle.contains('High Risk')
                ? AppColors.red500.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(24)),
          child: Padding(
            padding: EdgeInsets.all(context.rs(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(context.rs(12)),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: context.rs(28)),
                ),
                SizedBox(height: context.rs(20)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.rf(32),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.rf(15),
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: context.rs(8)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.rf(12),
                      height: 1.4,
                      color: subtitle.contains('High Risk') ||
                              subtitle.contains('Overdue')
                          ? AppColors.red500
                          : (isDark ? AppColors.gray400 : AppColors.gray500),
                      fontWeight: subtitle.contains('High Risk') ||
                              subtitle.contains('Overdue')
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(context.rs(20)),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(20)),
          child: Padding(
            padding: EdgeInsets.all(context.rs(20)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.rs(14)),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: context.rs(28)),
                ),
                SizedBox(width: context.rs(20)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: context.rf(18),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: context.rf(14),
                          color: isDark ? AppColors.gray400 : AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: context.rs(20),
                    color: isDark ? AppColors.gray600 : AppColors.gray400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// lib/features/admin/admin_users_screen.dart
import '../../../shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/admin_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/widgets/app_empty_state.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _roleFilter = 'all';
  String _searchQuery = '';

  static const _roles = [
    'all',
    'student',
    'volunteer',
    'psychologist',
    'admin'
  ];

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppColors.riskRedFg),
            tooltip: 'Delete All Anonymous Users',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete ALL Anonymous Users', style: TextStyle(color: AppColors.riskRedFg)),
                  content: const Text('Are you sure you want to permanently delete ALL anonymous users? This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.riskRedBg, foregroundColor: AppColors.riskRedFg),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete All'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await ref.read(adminRepositoryProvider).deleteAllAnonymousUsers();
                  await ref.read(adminRepositoryProvider).fixAdminEmail();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All anonymous users deleted & Admin email updated successfully.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              style:
                  TextStyle(color: isDark ? Colors.white : AppColors.gray900),
              decoration: InputDecoration(
                hintText: 'Search by email or pseudonym...',
                hintStyle: TextStyle(
                    color: isDark ? AppColors.gray400 : AppColors.gray500),
                prefixIcon: Icon(Icons.search_rounded,
                    color: isDark ? AppColors.gray400 : AppColors.gray500),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray500),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.blue500),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),

          // Role filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _roles.map((role) {
                final selected = _roleFilter == role;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      role == 'all'
                          ? 'All Users'
                          : role[0].toUpperCase() + role.substring(1),
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : (isDark ? AppColors.gray400 : AppColors.gray600),
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => setState(() => _roleFilter = role),
                    backgroundColor:
                        isDark ? AppColors.darkSurface : Colors.white,
                    selectedColor: AppColors.blue500,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: selected
                              ? AppColors.blue500
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.gray200)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filtered = users.where((u) {
                  final matchRole =
                      _roleFilter == 'all' || u.role == _roleFilter;
                  final matchSearch = _searchQuery.isEmpty ||
                      (u.email?.toLowerCase().contains(_searchQuery) ??
                          false) ||
                      u.pseudonym.toLowerCase().contains(_searchQuery);
                  return matchRole && matchSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    title: 'No users found',
                    message: 'Try adjusting your filters or search query.',
                    icon: Icons.search_off_rounded,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppSurface(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        child: _UserTile(user: user, ref: ref, isDark: isDark),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: AppLoadingState(itemCount: 4)),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final WidgetRef ref;
  final bool isDark;

  const _UserTile(
      {required this.user, required this.ref, required this.isDark});

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.red500;
      case 'psychologist':
        return AppColors.blue500;
      case 'volunteer':
        return AppColors.sage600;
      default:
        return AppColors.gray600;
    }
  }

  void _showRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Change Role'),
        children: ['student', 'volunteer', 'psychologist', 'admin'].map((r) {
          return SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              if (r != user.role) {
                try {
                  await ref.read(adminRepositoryProvider).updateUserRole(user.uid, r);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update role: $e')),
                    );
                  }
                }
              }
            },
            child: Text(r[0].toUpperCase() + r.substring(1)),
          );
        }).toList(),
      ),
    );
  }

  void _showBadgeDialog(BuildContext context) {
    final badges = [
      'Certified DIU Peer Listener',
      'Senior Peer Supporter',
      'Mental Health First Aider',
      'Crisis Intervention Trainee',
    ];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Assign Volunteer Badge Level'),
        children: badges.map((b) {
          return SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminRepositoryProvider).updateVolunteerBadgeLevel(user.uid, b);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Badge assigned: $b')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update badge: $e')),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(b, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(user.role);
    final joined = user.createdAt != null
        ? DateFormat("MMM d, yyyy").format(user.createdAt!)
        : 'Unknown';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: roleColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            user.role[0].toUpperCase(),
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      title: Text(
        user.displayName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isDark ? Colors.white : AppColors.gray900,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.email != null && user.email!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(user.email!,
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.gray400 : AppColors.gray600)),
              ),
            if (user.pseudonym != user.displayName)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('Alias: ${user.pseudonym}',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.gray500 : AppColors.gray500,
                        fontStyle: FontStyle.italic)),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.5,
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isActive ? AppColors.sage50 : AppColors.red50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.5,
                      color:
                          user.isActive ? AppColors.sage600 : AppColors.red500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isAnonymous
                        ? AppColors.amber100
                        : AppColors.blue100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.isAnonymous ? 'ANON' : 'LINKED',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.5,
                      color: user.isAnonymous
                          ? AppColors.amber600
                          : AppColors.blue600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (user.isDiuStudent == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.riskGreenBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DIU',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: AppColors.riskGreenFg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Joined: $joined',
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.gray500 : AppColors.gray600)),
          ],
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded,
            color: isDark ? AppColors.gray400 : AppColors.gray600),
        onSelected: (action) async {
          try {
            if (action == 'role') {
              _showRoleDialog(context);
            } else if (action == 'toggle_active') {
              await ref
                  .read(adminRepositoryProvider)
                  .toggleUserActive(user.uid, !user.isActive);
            } else if (action == 'toggle_diu') {
              await ref
                  .read(adminRepositoryProvider)
                  .updateDiuStatus(user.uid, !(user.isDiuStudent ?? false));
            } else if (action == 'toggle_verify') {
              await ref
                  .read(adminRepositoryProvider)
                  .updatePsychologistVerification(
                      user.uid, !(user.isVerified ?? false));
            } else if (action == 'badge_level') {
              _showBadgeDialog(context);
            } else if (action == 'delete_user') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete User', style: TextStyle(color: AppColors.red500)),
                  content: const Text('Are you sure you want to permanently delete this user? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.red500),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(adminRepositoryProvider).deleteUser(user.uid);
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Action failed: $e')),
              );
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'role', child: Text('Change Role')),
          PopupMenuItem(
            value: 'toggle_active',
            child: Text(user.isActive ? 'Deactivate User' : 'Activate User',
                style: TextStyle(
                    color:
                        user.isActive ? AppColors.red500 : AppColors.sage600)),
          ),
          if (user.role == 'student')
            PopupMenuItem(
                value: 'toggle_diu',
                child: Text(user.isDiuStudent == true
                    ? 'Revoke DIU Status'
                    : 'Grant DIU Status')),
          if (user.role == 'volunteer')
            const PopupMenuItem(
                value: 'badge_level',
                child: Text('Assign Badge Level', style: TextStyle(color: AppColors.sage600, fontWeight: FontWeight.bold))),
          if (user.role == 'psychologist')
            PopupMenuItem(
                value: 'toggle_verify',
                child: Text(user.isVerified == true
                    ? 'Revoke Verification'
                    : 'Verify Professional')),
          const PopupMenuItem(
            value: 'delete_user',
            child: Text('Delete User',
                style: TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );
  }
}

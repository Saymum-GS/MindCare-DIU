// lib/features/admin/admin_audit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/admin_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/audit_log_model.dart';

import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading_state.dart';

class AdminAuditScreen extends ConsumerWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allAuditLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        elevation: 0,
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No audit logs yet.',
              message: 'System events will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, i) => _AuditLogCard(log: logs[i]),
          );
        },
        loading: () => const AppLoadingState(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AuditLogModel log;
  const _AuditLogCard({required this.log});

  Color _actionColor(String action) {
    if (action.startsWith('crisis')) return AppColors.red500;
    if (action.startsWith('booking')) return AppColors.riskGreenFg;
    if (action.startsWith('screening')) return AppColors.blue500;
    if (action.startsWith('user')) return AppColors.amber500;
    if (action.startsWith('session')) return AppColors.sage500;
    return AppColors.gray500;
  }

  Color _actionBg(String action) {
    if (action.startsWith('crisis')) return AppColors.riskRedBg;
    if (action.startsWith('booking')) return AppColors.riskGreenBg;
    if (action.startsWith('screening')) return AppColors.blue50;
    if (action.startsWith('user')) return AppColors.amber50;
    if (action.startsWith('session')) return AppColors.sage50;
    return AppColors.gray100;
  }

  IconData _actionIcon(String action) {
    if (action.startsWith('crisis')) return Icons.warning_amber_rounded;
    if (action.startsWith('booking')) return Icons.event_available_outlined;
    if (action.startsWith('screening')) return Icons.assignment_outlined;
    if (action.startsWith('user')) return Icons.person_outline;
    if (action.startsWith('session')) return Icons.chat_bubble_outline;
    return Icons.receipt_long_outlined;
  }

  String _pretty(String action) =>
      action.replaceAll('.', ' › ').replaceAll('_', ' ');

  void _showDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_actionIcon(log.action), color: _actionColor(log.action)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _pretty(log.action),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow('Log ID', log.id),
            _DetailRow('Actor UID', log.actorUid),
            _DetailRow('Actor Role', log.actorRole.toUpperCase()),
            if (log.targetUid != null) _DetailRow('Target UID', log.targetUid!),
            if (log.targetCollection != null)
              _DetailRow('Target Collection', log.targetCollection!),
            if (log.targetDocId != null)
              _DetailRow('Target Doc ID', log.targetDocId!),
            if (log.createdAt != null)
              _DetailRow('Timestamp',
                  DateFormat('MMM d, yyyy - h:mm:ss a').format(log.createdAt!)),
            if (log.metadata.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Metadata:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.gray300 : AppColors.gray700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.gray200),
                ),
                child: Text(
                  log.metadata.toString(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () => _showDetails(context),
        child: AppSurface(
          padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _actionBg(log.action),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(_actionIcon(log.action),
                  color: _actionColor(log.action), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_pretty(log.action),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _actionColor(log.action))),
                  const SizedBox(height: 2),
                  Text(
                      '${log.actorRole} · ${log.actorUid.length > 8 ? log.actorUid.substring(0, 8) : log.actorUid}...',
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSub
                              : AppColors.gray500)),
                  if (log.createdAt != null)
                    Text(DateFormat('MMM d, h:mm a').format(log.createdAt!),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.gray500)),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.gray200 : AppColors.gray800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

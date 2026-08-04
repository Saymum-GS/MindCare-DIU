import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/admin_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/incident_model.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/widgets/app_empty_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminIncidentsScreen extends ConsumerWidget {
  const AdminIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(allIncidentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Management')),
      body: incidentsAsync.when(
        data: (incidents) {
          if (incidents.isEmpty) {
            return const AppEmptyState(
              title: 'No incidents recorded.',
              message: 'When escalations or crisis events occur, they will appear here.',
              icon: Icons.shield_outlined,
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView.builder(
                itemCount: incidents.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final incident = incidents[index];
                  return _IncidentCard(incident: incident);
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: AppLoadingState(itemCount: 4)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _IncidentCard extends ConsumerWidget {
  final IncidentModel incident;

  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isOpen = incident.status == 'open';
    final bool isAck = incident.status == 'acknowledged';
    final bool isResolved = incident.status == 'resolved';

    final Color statusColor = isOpen
        ? AppColors.riskRedFg
        : isAck
            ? AppColors.riskYellowFg
            : AppColors.riskGreenFg;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    incident.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                Text(
                  incident.createdAt != null
                      ? DateFormat('MMM d, h:mm a').format(incident.createdAt!)
                      : 'Unknown time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSub
                          : AppColors.gray500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Student: ${incident.studentPseudonym}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Trigger: ${incident.triggerType} (${incident.riskLevel})'),
            const SizedBox(height: 4),
            Text(
              incident.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.gray600),
            ),
            if (isResolved && incident.resolutionNote != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurface2
                      : AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.gray200,
                  ),
                ),
                child: Text('Resolution: ${incident.resolutionNote}'),
              ),
            ],
            const SizedBox(height: 16),
            if (!isResolved)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isOpen)
                    OutlinedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          try {
                            await ref
                                .read(adminRepositoryProvider)
                                .acknowledgeIncident(incident.id);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error acknowledging: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Acknowledge'),
                    ),
                  if (isOpen || isAck) ...[
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _showResolveDialog(context, ref),
                      child: const Text('Resolve'),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showResolveDialog(BuildContext context, WidgetRef ref) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Resolve Incident'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: 'Resolution Note'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  await ref.read(adminRepositoryProvider).resolveIncident(
                        incident.id,
                        noteController.text,
                      );
                  if (c.mounted) Navigator.pop(c);
                } catch (e) {
                  if (c.mounted) {
                    Navigator.pop(c);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error resolving: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}

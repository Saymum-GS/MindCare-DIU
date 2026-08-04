import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/responsive_util.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../shared/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../shared/widgets/app_loading_state.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Notifications', style: TextStyle(fontSize: context.rf(17)))),
        body: Center(child: Text('Please log in', style: TextStyle(fontSize: context.rf(16)))),
      );
    }

    final notificationsAsync = ref.watch(notificationsProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontSize: context.rf(17))),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all_rounded, size: context.rs(22)),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(notificationServiceProvider).markAllAsRead(uid);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return AppEmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'You\'re all caught up',
              message: 'You have no new notifications right now.',
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: context.rs(8)),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _NotificationTile(
                notification: notif,
                uid: uid,
                onTap: () {
                  if (!notif.isRead) {
                    ref
                        .read(notificationServiceProvider)
                        .markAsRead(uid, notif.id);
                  }

                  // Routing based on type and relatedId
                  if (notif.relatedId == null) return;
                  if (notif.type == 'chat') {
                    context.push('/chat/${notif.relatedId}');
                  } else if (notif.type == 'crisis') {
                    context.push('/admin/incidents');
                  } else if (notif.type == 'booking') {
                    context.push('/booking-detail', extra: notif.relatedId);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: AppLoadingState(itemCount: 4)),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(fontSize: context.rf(14)))),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final String uid;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.uid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    Color color;

    switch (notification.type) {
      case 'chat':
        icon = Icons.chat_bubble_outline_rounded;
        color = AppColors.sage500;
        break;
      case 'booking':
        icon = Icons.calendar_today_rounded;
        color = AppColors.blue500;
        break;
      case 'crisis':
        icon = Icons.warning_amber_rounded;
        color = AppColors.red500;
        break;
      default:
        icon = Icons.info_outline_rounded;
        color = AppColors.gray500;
    }

    return Material(
      color: notification.isRead
          ? (isDark ? AppColors.darkBg : Colors.white)
          : (isDark ? AppColors.darkSurface : AppColors.blue50),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(context.rs(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(context.rs(12)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: context.rs(24)),
              ),
              SizedBox(width: context.rs(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: context.rf(16),
                            ),
                          ),
                        ),
                        Text(
                          timeago.format(notification.createdAt),
                          style: TextStyle(
                            fontSize: context.rf(12),
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: context.rf(14),
                        color: isDark ? AppColors.gray300 : AppColors.gray700,
                      ),
                    ),
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

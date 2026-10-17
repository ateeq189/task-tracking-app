import 'package:flutter/material.dart';

import '../models/report_stats.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class AppNotification {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const AppNotification({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

/// Intern: overdue, newly assigned by admin, due within 48 hours.
List<AppNotification> internNotifications(String uid, List<TaskModel> tasks) {
  final now = DateTime.now();
  final overdue = <AppNotification>[];
  final fresh = <AppNotification>[];
  final soon = <AppNotification>[];

  for (final t in tasks) {
    if (t.status == 'completed') continue;
    if (t.isOverdue) {
      overdue.add(AppNotification(
        icon: Icons.warning_amber_rounded,
        color: AppColors.danger,
        title: 'Overdue: ${t.title}',
        subtitle: 'Was due ${formatDate(t.dueDate)}',
      ));
    } else if (t.deadline.difference(now).inHours <= 48) {
      soon.add(AppNotification(
        icon: Icons.schedule_rounded,
        color: AppColors.warning,
        title: 'Due soon: ${t.title}',
        subtitle: 'Due ${formatDate(t.dueDate)}',
      ));
    }
    if (t.assignedBy != uid && now.difference(t.createdAt).inDays < 3) {
      fresh.add(AppNotification(
        icon: Icons.assignment_ind_outlined,
        color: AppColors.primary,
        title: 'New task assigned',
        subtitle: t.title,
      ));
    }
  }
  return [...overdue, ...fresh, ...soon];
}

/// Admin: recently completed tasks and overdue tasks.
List<AppNotification> adminNotifications(
  List<TaskModel> tasks,
  Map<String, String> names,
) {
  final now = DateTime.now();
  final done = <AppNotification>[];
  final overdue = <AppNotification>[];

  for (final t in tasks) {
    final who = names[t.assignedTo] ?? 'An intern';
    if (t.status == 'completed') {
      final at = t.completedAt;
      if (at != null && now.difference(at).inDays < 3) {
        done.add(AppNotification(
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.secondary,
          title: '$who completed a task',
          subtitle: t.title,
        ));
      }
    } else if (t.isOverdue) {
      overdue.add(AppNotification(
        icon: Icons.warning_amber_rounded,
        color: AppColors.danger,
        title: '$who is overdue',
        subtitle: '${t.title} • due ${formatDate(t.dueDate)}',
      ));
    }
  }
  return [...overdue, ...done];
}

void showNotificationsSheet(BuildContext context, List<AppNotification> items) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 480),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.faint,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        "You're all caught up!",
                        style: TextStyle(color: AppColors.textSoft),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final n = items[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: n.color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(n.icon, color: n.color, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      n.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

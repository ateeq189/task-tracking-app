import 'package:flutter/material.dart';

import '../models/report_stats.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import 'common.dart';

/// Task card from the design, with compatibility for both older and newer usage.
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final String? assigneeName;
  final String? extraInfo;
  final List<Widget> actions;
  final VoidCallback? onTap;
  final VoidCallback? onDetails;
  final ValueChanged<String>? onStatusChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleDone;
  final VoidCallback? onStart;

  const TaskCard({
    super.key,
    required this.task,
    this.assigneeName,
    this.extraInfo,
    this.actions = const [],
    this.onTap,
    this.onDetails,
    this.onStatusChanged,
    this.onDelete,
    this.onToggleDone,
    this.onStart,
  });

  Color get _accent {
    switch (task.status) {
      case 'completed':
        return AppColors.secondary;
      case 'in_progress':
        return AppColors.warning;
      default:
        return AppColors.hint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tapHandler = onDetails ?? onTap ?? () {};
    final done = task.status == 'completed';
    final overdue = task.isOverdue;
    final dateColor = overdue ? AppColors.danger : AppColors.textSoft;
    final infoText = extraInfo ?? assigneeName;
    final useLegacyLayout = onStatusChanged != null || onDelete != null || onTap != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14312E81),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: tapHandler,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 5, color: _accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (useLegacyLayout)
                                StatusBadge(
                                  status: task.status,
                                  label: statusLabel(task.status),
                                )
                              else
                                StatusBadge(
                                  status: task.status,
                                  label: statusLabel(task.status),
                                ),
                              if (onStatusChanged != null || onDelete != null)
                                PopupMenuButton<String>(
                                  tooltip: 'Task actions',
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      onDelete?.call();
                                    } else {
                                      onStatusChanged?.call(value);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    for (final status in [
                                      ('pending', 'Pending'),
                                      ('in_progress', 'In Progress'),
                                      ('completed', 'Completed'),
                                    ])
                                      if (onStatusChanged != null &&
                                          status.$1 != task.status)
                                        PopupMenuItem(
                                          value: status.$1,
                                          child: Text(status.$2),
                                        ),
                                    if (onDelete != null)
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: AppColors.textSoft,
                              ),
                            ),
                          ],
                          if (infoText != null && infoText.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: AppColors.textSoft,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    infoText,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSoft,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 15,
                                color: dateColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Due: ${formatDate(task.dueDate)}${overdue ? ' • Overdue' : ''}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: dateColor,
                                  ),
                                ),
                              ),
                              if (onStart != null && task.status == 'pending') ...[
                                GestureDetector(
                                  onTap: onStart,
                                  child: const Text(
                                    'Start',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              if (onToggleDone != null) ...[
                                _CircleCheck(
                                  done: done,
                                  onTap: onToggleDone!,
                                ),
                                const SizedBox(width: 12),
                              ],
                              if (actions.isNotEmpty) ...[
                                for (var i = 0; i < actions.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  actions[i],
                                ],
                              ] else if (onTap != null || onDetails != null) ...[
                                const Text(
                                  'Details',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSoft,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: AppColors.textSoft,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleCheck extends StatelessWidget {
  final bool done;
  final VoidCallback onTap;
  const _CircleCheck({required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? AppColors.secondary : Colors.transparent,
          border: Border.all(
            color: done ? AppColors.secondary : AppColors.faint,
            width: 2,
          ),
        ),
        child: done
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

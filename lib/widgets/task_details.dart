import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

/// "Task Details" modal from the design.
/// Pass [onEdit] / [onDelete] to show the action buttons.
Future<void> showTaskDetails(
  BuildContext context,
  TaskModel task, {
  String? assigneeName,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  Color statusColor;
  switch (task.status) {
    case 'completed':
      statusColor = AppColors.green700;
      break;
    case 'in_progress':
      statusColor = AppColors.amber700;
      break;
    default:
      statusColor = AppColors.textMuted;
  }

  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: AppColors.hint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Field('Title', task.title),
              if (task.description.isNotEmpty)
                _Field(
                  'Description',
                  task.description,
                  valueColor: AppColors.textBody,
                  bold: false,
                ),
              _Row(
                _Field('Assigned To', assigneeName ?? 'Me'),
                _Field('Due Date', formatDate(task.dueDate)),
              ),
              _Row(
                _Field(
                  'Status',
                  statusLabel(task.status),
                  valueColor: statusColor,
                ),
                _Field('Priority', priorityLabel(task.priority)),
              ),
              _Row(
                _Field('Created At', formatDate(task.createdAt)),
                task.completedAt != null
                    ? _Field('Completed At', formatDate(task.completedAt!))
                    : const SizedBox.shrink(),
              ),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (onEdit != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onEdit();
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                        ),
                      ),
                    if (onEdit != null && onDelete != null)
                      const SizedBox(width: 12),
                    if (onDelete != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onDelete();
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Row(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  const _Field(
    this.label,
    this.value, {
    this.valueColor = AppColors.text,
    this.bold = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor,
              fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

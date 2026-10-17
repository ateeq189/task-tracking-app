import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_details.dart';

class InternTasksTab extends StatefulWidget {
  final UserModel user;
  final AsyncSnapshot<List<TaskModel>> snap;

  const InternTasksTab({super.key, required this.user, required this.snap});

  @override
  State<InternTasksTab> createState() => _InternTasksTabState();
}

class _InternTasksTabState extends State<InternTasksTab> {
  static const _filters = {
    'all': 'All',
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
  };

  String _filter = 'all';
  final _service = TaskService();

  Future<void> _setStatus(TaskModel t, String status) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.updateStatus(t.id, status);
      showToastOn(messenger, 'Task marked as ${statusLabel(status)}');
    } catch (e) {
      showToastOn(messenger, 'Could not update task: $e', error: true);
    }
  }

  Future<void> _delete(TaskModel t) async {
    if (!await confirmDelete(context)) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.deleteTask(t.id);
      showToastOn(messenger, 'Task deleted');
    } catch (e) {
      showToastOn(messenger, 'Could not delete task: $e', error: true);
    }
  }

  void _details(TaskModel t) {
    showTaskDetails(
      context,
      t,
      // Interns can only delete tasks they created themselves.
      onDelete: t.assignedBy == widget.user.uid ? () => _delete(t) : null,
    );
  }

  List<Widget> _actions(TaskModel t) {
    return [
      if (t.status == 'pending')
        SmallButton(
          label: 'Start',
          background: AppColors.warning,
          onPressed: () => _setStatus(t, 'in_progress'),
        ),
      if (t.status == 'in_progress')
        SmallButton(
          label: 'Complete',
          background: AppColors.secondary,
          onPressed: () => _setStatus(t, 'completed'),
        ),
      if (t.status == 'completed')
        SmallButton(
          label: 'Reopen',
          background: AppColors.warning,
          onPressed: () => _setStatus(t, 'pending'),
        ),
      if (t.status != 'completed')
        SmallButton(
          label: 'Details',
          background: AppColors.borderSoft,
          foreground: AppColors.textBody,
          onPressed: () => _details(t),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final status = asyncStatusView(widget.snap);
    if (status != null) return status;

    final all = widget.snap.data!;
    final list = _filter == 'all'
        ? all
        : all.where((t) => t.status == _filter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        FilterChipsRow(
          options: _filters,
          selected: _filter,
          onChanged: (v) => setState(() => _filter = v),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          const EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No tasks found',
            subtitle: "You're all caught up!",
          ),
        for (final t in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCard(
              task: t,
              actions: _actions(t),
              onTap: () => _details(t),
            ),
          ),
      ],
    );
  }
}

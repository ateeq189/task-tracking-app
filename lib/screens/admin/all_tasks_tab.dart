import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_details.dart';
import 'edit_task_screen.dart';

class AllTasksTab extends StatefulWidget {
  final UserModel admin;
  final AsyncSnapshot<List<TaskModel>> tasksSnap;
  final AsyncSnapshot<List<UserModel>> internsSnap;

  const AllTasksTab({
    super.key,
    required this.admin,
    required this.tasksSnap,
    required this.internsSnap,
  });

  @override
  State<AllTasksTab> createState() => _AllTasksTabState();
}

class _AllTasksTabState extends State<AllTasksTab> {
  static const _filters = {
    'all': 'All',
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
  };

  final _search = TextEditingController();
  final _service = TaskService();
  String _filter = 'all';
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _view(TaskModel t, Map<String, String> names, List<UserModel> interns) {
    showTaskDetails(
      context,
      t,
      assigneeName: names[t.assignedTo] ?? 'Unknown',
      onEdit: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EditTaskScreen(admin: widget.admin, task: t, interns: interns),
        ),
      ),
      onDelete: () => _delete(t),
    );
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

  @override
  Widget build(BuildContext context) {
    final status = asyncStatusView(widget.tasksSnap) ??
        asyncStatusView(widget.internsSnap);
    if (status != null) return status;

    final interns = widget.internsSnap.data!;
    final names = {for (final u in interns) u.uid: u.name};
    final all = widget.tasksSnap.data!;

    final counts = {
      'all': all.length,
      'pending': all.where((t) => t.status == 'pending').length,
      'in_progress': all.where((t) => t.status == 'in_progress').length,
      'completed': all.where((t) => t.status == 'completed').length,
    };
    final options = {
      for (final e in _filters.entries) e.key: '${e.value} (${counts[e.key]})',
    };

    var list = all;
    if (_filter != 'all') {
      list = list.where((t) => t.status == _filter).toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where(
            (t) =>
                t.title.toLowerCase().contains(_query) ||
                t.description.toLowerCase().contains(_query) ||
                (names[t.assignedTo] ?? '').toLowerCase().contains(_query),
          )
          .toList();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            prefixIcon: const Icon(Icons.search, color: AppColors.hint),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 16),
        FilterChipsRow(
          options: options,
          selected: _filter,
          onChanged: (v) => setState(() => _filter = v),
        ),
        const SizedBox(height: 20),
        if (list.isEmpty)
          const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No tasks found',
            subtitle: 'Try adjusting your filters',
          ),
        for (final t in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TaskCard(
              task: t,
              assigneeName: names[t.assignedTo] ?? 'Unknown',
              onDetails: () => _view(t, names, interns),
            ),
          ),
      ],
    );
  }
}

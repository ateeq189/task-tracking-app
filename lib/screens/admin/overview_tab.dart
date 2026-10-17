import 'package:flutter/material.dart';

import '../../models/report_stats.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/task_card.dart';
import 'assign_task_screen.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key, required this.admin});

  final UserModel admin;

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final _taskService = TaskService();
  late final Stream<List<TaskModel>> _tasks;
  late final Stream<List<UserModel>> _interns;

  @override
  void initState() {
    super.initState();
    _tasks = _taskService.allTasks();
    _interns = UserService().interns();
  }

  Future<void> _changeStatus(TaskModel task, String status) async {
    if (task.status == status) return;
    try {
      await _taskService.updateStatus(task.id, status);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task status update nahi hua: $error')),
      );
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    if (!await confirmDelete(context) || !mounted) return;
    try {
      await _taskService.deleteTask(task.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task delete nahi hua: $error')));
    }
  }

  Future<void> _editTask(TaskModel task) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AssignTaskScreen(admin: widget.admin, task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<TaskModel>>(
    stream: _tasks,
    builder: (context, taskSnapshot) {
      if (taskSnapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Tasks load nahi ho sake: ${taskSnapshot.error}'),
          ),
        );
      }
      if (!taskSnapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      return StreamBuilder<List<UserModel>>(
        stream: _interns,
        builder: (context, internSnapshot) {
          if (internSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Interns load nahi ho sake: ${internSnapshot.error}',
                ),
              ),
            );
          }
          if (!internSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = taskSnapshot.data!;
          final internNames = {
            for (final intern in internSnapshot.data!) intern.uid: intern.name,
          };
          final completed = tasks
              .where((task) => task.status == 'completed')
              .length;
          final inProgress = tasks
              .where((task) => task.status == 'in_progress')
              .length;
          final pending = tasks
              .where((task) => task.status == 'pending')
              .length;
          final overdue = tasks.where((task) => task.isOverdue).length;

          return ListView(
            padding: const EdgeInsets.only(bottom: 90),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatCard('Total', tasks.length, Colors.indigo),
                    _StatCard('Completed', completed, Colors.green),
                    _StatCard('In Progress', inProgress, Colors.blue),
                    _StatCard('Pending', pending, Colors.orange),
                    _StatCard('Overdue', overdue, Colors.red),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'All Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No tasks assigned yet')),
                ),
              for (final task in tasks)
                TaskCard(
                  task: task,
                  extraInfo:
                      'Assigned to: ${internNames[task.assignedTo]?.isNotEmpty == true ? internNames[task.assignedTo] : 'Unknown'}',
                  onStatusChanged: (status) => _changeStatus(task, status),
                  onTap: () => _editTask(task),
                  onDelete: () => _deleteTask(task),
                ),
            ],
          );
        },
      );
    },
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 40) / 3;
    return SizedBox(
      width: width,
      child: Card(
        color: color.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

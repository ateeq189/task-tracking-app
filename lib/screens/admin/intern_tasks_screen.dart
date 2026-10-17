import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/task_card.dart';
import 'assign_task_screen.dart';

class InternTasksScreen extends StatefulWidget {
  const InternTasksScreen({
    super.key,
    required this.intern,
    required this.admin,
  });

  final UserModel intern;
  final UserModel admin;

  @override
  State<InternTasksScreen> createState() => _InternTasksScreenState();
}

class _InternTasksScreenState extends State<InternTasksScreen> {
  final _taskService = TaskService();
  late final Stream<List<TaskModel>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = _taskService.internTasks(widget.intern.uid);
  }

  Future<void> _editTask(TaskModel task) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AssignTaskScreen(admin: widget.admin, task: task),
      ),
    );
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

  Future<void> _assignTask() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AssignTaskScreen(
          admin: widget.admin,
          assignedTo: widget.intern.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.intern.name)),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _assignTask,
      icon: const Icon(Icons.add),
      label: const Text('Assign Task'),
    ),
    body: Column(
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(widget.intern.name),
          subtitle: Text(widget.intern.email),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<TaskModel>>(
            stream: _tasks,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Tasks load nahi ho sake: ${snapshot.error}'),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = snapshot.data ?? const <TaskModel>[];
              if (tasks.isEmpty) {
                return const Center(child: Text('This intern has no tasks'));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 88, top: 8),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    task: task,
                    onStatusChanged: (status) => _changeStatus(task, status),
                    onDelete: () => _deleteTask(task),
                    onTap: () => _editTask(task),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

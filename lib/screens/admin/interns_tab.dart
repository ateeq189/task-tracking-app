import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import 'intern_tasks_screen.dart';

class InternsTab extends StatefulWidget {
  const InternsTab({super.key, required this.admin});

  final UserModel admin;

  @override
  State<InternsTab> createState() => _InternsTabState();
}

class _InternsTabState extends State<InternsTab> {
  late final Stream<List<UserModel>> _interns;
  late final Stream<List<TaskModel>> _tasks;

  @override
  void initState() {
    super.initState();
    _interns = UserService().interns();
    _tasks = TaskService().allTasks();
  }

  Future<void> _openIntern(UserModel intern) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => InternTasksScreen(intern: intern, admin: widget.admin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<UserModel>>(
    stream: _interns,
    builder: (context, internSnapshot) {
      if (internSnapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Interns load nahi ho sake: ${internSnapshot.error}'),
          ),
        );
      }
      if (!internSnapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      return StreamBuilder<List<TaskModel>>(
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

          final interns = internSnapshot.data!;
          final tasks = taskSnapshot.data!;
          if (interns.isEmpty) {
            return const Center(child: Text('No interns registered yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 90, top: 8),
            itemCount: interns.length,
            itemBuilder: (context, index) {
              final intern = interns[index];
              final internTasks = tasks
                  .where((task) => task.assignedTo == intern.uid)
                  .toList();
              final completed = internTasks
                  .where((task) => task.status == 'completed')
                  .length;
              final rate = internTasks.isEmpty
                  ? 0.0
                  : completed / internTasks.length;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () => _openIntern(intern),
                  leading: CircleAvatar(
                    child: Text(
                      intern.name.isEmpty
                          ? '?'
                          : intern.name.characters.first.toUpperCase(),
                    ),
                  ),
                  title: Text(
                    intern.name.isEmpty ? 'Unnamed intern' : intern.name,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(intern.email),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: rate, minHeight: 6),
                      const SizedBox(height: 4),
                      Text(
                        '$completed / ${internTasks.length} tasks completed',
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${(rate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../../widgets/notifications.dart';
import '../../widgets/page_header.dart';
import '../shell/main_shell.dart';
import 'all_tasks_tab.dart';
import 'assign_task_tab.dart';
import 'reports_tab.dart';

/// Admin app: Assign / Tasks / Reports.
class AdminHome extends StatefulWidget {
  final UserModel user;
  const AdminHome({super.key, required this.user});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late final Stream<List<TaskModel>> _tasks = TaskService().allTasks();
  late final Stream<List<UserModel>> _interns = UserService().interns();

  Widget _header(String title, List<AppNotification> notifs) => PageHeader(
        title: title,
        notifications: notifs,
        showThemeToggle: true,
        onLogout: () => AuthService().logout(),
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: _tasks,
      builder: (context, tasksSnap) {
        return StreamBuilder<List<UserModel>>(
          stream: _interns,
          builder: (context, internsSnap) {
            final names = {
              for (final u in internsSnap.data ?? const <UserModel>[]) u.uid: u.name,
            };
            final notifs = adminNotifications(
              tasksSnap.data ?? const <TaskModel>[],
              names,
            );

            return MainShell(
              tabs: [
                ShellTab(
                  label: 'Assign',
                  icon: Icons.add_circle_outline_rounded,
                  header: _header('Assign Task', notifs),
                  page: AssignTaskTab(
                    admin: widget.user,
                    internsSnap: internsSnap,
                  ),
                ),
                ShellTab(
                  label: 'Tasks',
                  icon: Icons.list_alt_rounded,
                  header: _header('All Tasks', notifs),
                  page: AllTasksTab(
                    admin: widget.user,
                    tasksSnap: tasksSnap,
                    internsSnap: internsSnap,
                  ),
                ),
                ShellTab(
                  label: 'Reports',
                  icon: Icons.bar_chart_rounded,
                  header: _header('Reports', notifs),
                  page: ReportsTab(
                    tasksSnap: tasksSnap,
                    internsSnap: internsSnap,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

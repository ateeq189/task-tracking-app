import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/common.dart';
import '../../widgets/notifications.dart';
import '../../widgets/page_header.dart';
import '../shell/main_shell.dart';
import 'add_task_screen.dart';
import 'intern_profile_tab.dart';
import 'intern_progress_tab.dart';
import 'intern_tasks_tab.dart';

/// Intern app: Tasks / Progress / Profile.
class InternHome extends StatefulWidget {
  final UserModel user;
  const InternHome({super.key, required this.user});

  @override
  State<InternHome> createState() => _InternHomeState();
}

class _InternHomeState extends State<InternHome> {
  late final Stream<List<TaskModel>> _stream =
      TaskService().internTasks(widget.user.uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: _stream,
      builder: (context, snap) {
        final tasks = snap.data ?? const <TaskModel>[];
        final notifs = internNotifications(widget.user.uid, tasks);
        final ini = initials(widget.user.name);

        return MainShell(
          tabs: [
            ShellTab(
              label: 'Tasks',
              icon: Icons.checklist_rounded,
              header: PageHeader(
                title: 'My Tasks',
                greetingName: ini,
                avatarText: ini,
                notifications: notifs,
              ),
              page: InternTasksTab(user: widget.user, snap: snap),
              fab: GradientFab(
                icon: Icons.add,
                label: 'Add Task',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTaskScreen(user: widget.user),
                  ),
                ),
              ),
            ),
            ShellTab(
              label: 'Progress',
              icon: Icons.show_chart_rounded,
              header: PageHeader(title: 'My Progress', notifications: notifs),
              page: InternProgressTab(snap: snap),
            ),
            ShellTab(
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              header: PageHeader(title: 'My Profile', notifications: notifs),
              page: InternProfileTab(
                user: widget.user,
                snap: snap,
                notifications: notifs,
              ),
            ),
          ],
        );
      },
    );
  }
}

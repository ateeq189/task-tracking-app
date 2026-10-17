import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import 'assign_task_screen.dart';
import 'interns_tab.dart';
import 'overview_tab.dart';
import 'reports_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, required this.user});

  final UserModel user;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  Future<void> _signOut() async {
    try {
      await AuthService().logout();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign out failed: $error')));
    }
  }

  Future<void> _openAssignTask() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AssignTaskScreen(admin: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      OverviewTab(admin: widget.user),
      InternsTab(admin: widget.user),
      StreamBuilder<List<TaskModel>>(
        stream: TaskService().allTasks(),
        builder: (context, tasksSnap) => StreamBuilder<List<UserModel>>(
          stream: UserService().interns(),
          builder: (context, internsSnap) =>
              ReportsTab(tasksSnap: tasksSnap, internsSnap: internsSnap),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: _selectedIndex == 2
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add_task),
              label: const Text('Assign Task'),
              onPressed: _openAssignTask,
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Interns',
          ),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }
}

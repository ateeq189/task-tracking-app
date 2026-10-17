import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/task_form.dart';

/// Intern adds a personal task.
class AddTaskScreen extends StatelessWidget {
  final UserModel user;
  const AddTaskScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.page,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              foregroundColor: AppColors.text,
              elevation: 1,
              shadowColor: const Color(0x1A000000),
              title: const Text(
                'Add Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AppCard(
                radius: 16,
                padding: const EdgeInsets.all(24),
                child: TaskForm(
                  currentUser: user,
                  submitLabel: 'Add Task',
                  onSaved: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

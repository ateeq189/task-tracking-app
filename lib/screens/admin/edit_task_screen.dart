import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/task_form.dart';

/// Admin edits an existing task.
class EditTaskScreen extends StatelessWidget {
  final UserModel admin;
  final TaskModel task;
  final List<UserModel> interns;

  const EditTaskScreen({
    super.key,
    required this.admin,
    required this.task,
    required this.interns,
  });

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
                'Edit Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AppCard(
                radius: 16,
                padding: const EdgeInsets.all(24),
                child: TaskForm(
                  currentUser: admin,
                  interns: interns,
                  task: task,
                  submitLabel: 'Update Task',
                  submitIcon: Icons.save_outlined,
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

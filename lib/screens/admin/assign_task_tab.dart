import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../widgets/common.dart';
import '../../widgets/task_form.dart';

class AssignTaskTab extends StatelessWidget {
  final UserModel admin;
  final AsyncSnapshot<List<UserModel>> internsSnap;

  const AssignTaskTab({
    super.key,
    required this.admin,
    required this.internsSnap,
  });

  @override
  Widget build(BuildContext context) {
    final status = asyncStatusView(internsSnap);
    if (status != null) return status;

    final interns = internsSnap.data!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          radius: 16,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign New Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              if (interns.isEmpty)
                const EmptyState(
                  icon: Icons.group_outlined,
                  title: 'No interns yet',
                  subtitle: 'Interns appear here after they sign up',
                )
              else
                TaskForm(
                  currentUser: admin,
                  interns: interns,
                  submitLabel: 'Assign Task',
                  submitIcon: Icons.add,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

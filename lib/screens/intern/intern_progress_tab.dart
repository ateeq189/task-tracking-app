import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common.dart';

class InternProgressTab extends StatelessWidget {
  final AsyncSnapshot<List<TaskModel>> snap;
  const InternProgressTab({super.key, required this.snap});

  @override
  Widget build(BuildContext context) {
    final status = asyncStatusView(snap);
    if (status != null) return status;

    final tasks = snap.data!;
    final total = tasks.length;
    final completed = tasks.where((t) => t.status == 'completed').toList();
    final pending = tasks.where((t) => t.status == 'pending').length;
    final rate = total == 0 ? 0.0 : completed.length / total;

    // Most recently completed first.
    completed.sort(
      (a, b) => (b.completedAt ?? b.createdAt).compareTo(
        a.completedAt ?? a.createdAt,
      ),
    );

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
                'Overall Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Completion Rate',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  Text(
                    '${(rate * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppProgressBar(value: rate, height: 12),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(
                    value: '$total',
                    label: 'Total Tasks',
                    color: AppColors.text,
                  ),
                  _Stat(
                    value: '${completed.length}',
                    label: 'Completed',
                    color: AppColors.secondary,
                  ),
                  _Stat(
                    value: '$pending',
                    label: 'Pending',
                    color: AppColors.warning,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppCard(
          radius: 16,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Completed Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              if (completed.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 40,
                          color: AppColors.faint,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No completed tasks yet',
                          style: TextStyle(color: AppColors.textSoft),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final t in completed)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Completed on ${formatDate(t.completedAt ?? t.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.secondary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

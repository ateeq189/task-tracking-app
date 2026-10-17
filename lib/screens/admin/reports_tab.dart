import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/report_stats.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common.dart';

/// Reports screen ke exact rang.
class _C {
  static const indigoBg = Color(0xFFEEF2FF);
  static const indigoFg = Color(0xFF4338CA);
  static const mintBg = Color(0xFFECFDF5);
  static const mintFg = Color(0xFF059669);
  static const amberBg = Color(0xFFFFFBEB);
  static const amberFg = Color(0xFFD97706);
  static const roseBg = Color(0xFFFEF2F2);
  static const roseFg = Color(0xFFDC2626);
  static const track = Color(0xFFE2E8F0);
  static const violet = Color(0xFF6366F1);
  static const blue = Color(0xFF3B82F6);
}

const _ringGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_C.violet, _C.blue],
);

class ReportsTab extends StatefulWidget {
  final AsyncSnapshot<List<TaskModel>> tasksSnap;
  final AsyncSnapshot<List<UserModel>> internsSnap;

  const ReportsTab({
    super.key,
    required this.tasksSnap,
    required this.internsSnap,
  });

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  ReportPeriod _period = ReportPeriod.week;

  @override
  Widget build(BuildContext context) {
    final status =
        asyncStatusView(widget.tasksSnap) ??
        asyncStatusView(widget.internsSnap);
    if (status != null) return status;

    final start = _period.startDate;
    final tasks = widget.tasksSnap.data!
        .where((t) => start == null || !t.createdAt.isBefore(start))
        .toList();

    final stats = buildInternStats(widget.internsSnap.data!, tasks)
      ..sort((a, b) => b.score.compareTo(a.score));

    final total = tasks.length;
    final completed = tasks.where((t) => t.status == 'completed').length;
    final inProgress = tasks.where((t) => t.status == 'in_progress').length;
    final pending = tasks.where((t) => t.status == 'pending').length;
    final onTime = tasks.where((t) => t.isDoneOnTime).length;
    final overdue = tasks.where((t) => t.isOverdue).length;

    final completionRate = total == 0 ? 0.0 : completed / total;
    final onTimeRate = completed == 0 ? 0.0 : onTime / completed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        FilterChipsRow(
          options: {for (final p in ReportPeriod.values) p.name: p.label},
          selected: _period.name,
          onChanged: (k) =>
              setState(() => _period = ReportPeriod.values.byName(k)),
        ),
        const SizedBox(height: 20),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Overall Performance'),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Tile(
                    icon: Icons.assignment_outlined,
                    value: '$total',
                    label: 'Total Tasks',
                    fg: _C.indigoFg,
                    bg: _C.indigoBg,
                  ),
                  const SizedBox(width: 12),
                  _Tile(
                    icon: Icons.check_circle_outline_rounded,
                    value: '${(completionRate * 100).round()}%',
                    label: 'Completion Rate',
                    fg: _C.mintFg,
                    bg: _C.mintBg,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Tile(
                    icon: Icons.schedule_rounded,
                    value: '${(onTimeRate * 100).round()}%',
                    label: 'On-time Rate',
                    fg: _C.amberFg,
                    bg: _C.amberBg,
                  ),
                  const SizedBox(width: 12),
                  _Tile(
                    icon: Icons.warning_amber_rounded,
                    value: '$overdue',
                    label: 'Overdue',
                    fg: _C.roseFg,
                    bg: _C.roseBg,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Bar(value: completionRate, gradient: _ringGradient, height: 10),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Task Status'),
              const SizedBox(height: 12),
              if (total == 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      'No tasks in this period',
                      style: TextStyle(color: AppColors.textSoft),
                    ),
                  ),
                )
              else ...[
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 62,
                          startDegreeOffset: -90,
                          borderData: FlBorderData(show: false),
                          sections: [
                            if (completed > 0)
                              _slice(completed, color: _C.mintFg),
                            if (inProgress > 0)
                              _slice(
                                inProgress,
                                color: const Color(0xFFF59E0B),
                              ),
                            if (pending > 0)
                              _slice(pending, gradient: _ringGradient),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const Text(
                            'Tasks',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSoft,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _Legend(
                      label: 'Completed',
                      count: completed,
                      color: _C.mintFg,
                    ),
                    _Legend(
                      label: 'In Progress',
                      count: inProgress,
                      color: const Color(0xFFF59E0B),
                    ),
                    _Legend(
                      label: 'Pending',
                      count: pending,
                      gradient: _ringGradient,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Intern Performance'),
        const SizedBox(height: 14),
        if (stats.isEmpty)
          const EmptyState(
            icon: Icons.group_outlined,
            title: 'No interns yet',
            subtitle: 'Interns appear here after they sign up',
          ),
        for (final s in stats)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _InternCard(stats: s),
          ),
        const SizedBox(height: 4),
        const Text(
          'Score = 60% completion rate + 40% on-time rate. '
          'On-time means completed by 11:59 PM on the due date.',
          style: TextStyle(fontSize: 12, color: AppColors.textSoft),
        ),
      ],
    );
  }

  PieChartSectionData _slice(int value, {Color? color, Gradient? gradient}) {
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      gradient: gradient,
      radius: 26,
      showTitle: false,
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color fg;
  final Color bg;

  const _Tile({
    required this.icon,
    required this.value,
    required this.label,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: fg),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double value;
  final Color? color;
  final Gradient? gradient;
  final double height;

  const _Bar({required this.value, this.color, this.gradient, this.height = 8});

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        width: double.infinity,
        color: _C.track,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(color: color, gradient: gradient),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final int count;
  final Color? color;
  final Gradient? gradient;

  const _Legend({
    required this.label,
    required this.count,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label · $count',
          style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
        ),
      ],
    );
  }
}

class _InternCard extends StatelessWidget {
  final InternStats stats;
  const _InternCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final rate = stats.completionRate;
    final color = rate >= 0.7
        ? _C.mintFg
        : rate >= 0.4
        ? _C.amberFg
        : _C.roseFg;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(
                text: initials(stats.intern.name),
                size: 42,
                background: _C.indigoBg,
                foreground: _C.indigoFg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.intern.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stats.completed}/${stats.total} tasks completed',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(rate * 100).round()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Bar(value: rate, color: color, height: 8),
          const SizedBox(height: 10),
          Text(
            'On-time ${stats.onTime} • Late ${stats.late} • Overdue ${stats.overdue} • Score ${stats.score.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../../utils/auth_errors.dart';
import '../../utils/helpers.dart';
import '../../widgets/notifications.dart';

class InternProfileTab extends StatelessWidget {
  final UserModel user;
  final AsyncSnapshot<List<TaskModel>> snap;
  final List<AppNotification> notifications;

  const InternProfileTab({
    super.key,
    required this.user,
    required this.snap,
    this.notifications = const [],
  });

  Future<void> _changePassword(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService().resetPassword(user.email);
      showToastOn(messenger, 'Password reset link sent to ${user.email}');
    } catch (e) {
      showToastOn(messenger, authErrorMessage(e), error: true);
    }
  }

  void _info(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          body,
          style: const TextStyle(height: 1.5, color: AppColors.textBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = snap.data ?? const <TaskModel>[];
    final done = tasks.where((t) => t.status == 'completed').length;
    final memberSince = DateFormat('MMM yyyy').format(user.createdAt);
    final ini = initials(user.name);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 70),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          ini,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B3A6B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Member since $memberSince',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: -44,
              height: 88,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F312E81),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _StatCell(label: 'Joined', value: '${user.createdAt.year}'),
                    const _VDivider(),
                    _StatCell(label: 'Overall Completed', value: '$done'),
                    const _VDivider(),
                    _StatCell(label: 'Total Tasks', value: '${tasks.length}'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14312E81),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: darkMode,
                builder: (_, dark, _) => _MenuRow(
                  icon: Icons.brightness_4_outlined,
                  label: 'Theme / Dark Mode',
                  onTap: () => darkMode.value = !dark,
                  trailing: Switch(
                    value: dark,
                    thumbColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? Colors.white
                          : AppColors.hint,
                    ),
                    trackColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? AppColors.purple
                          : AppColors.faint,
                    ),
                    onChanged: (v) => darkMode.value = v,
                  ),
                ),
              ),
              const _Line(),
              _MenuRow(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () => showNotificationsSheet(context, notifications),
              ),
              const _Line(),
              _MenuRow(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: () => _changePassword(context),
              ),
              const _Line(),
              _MenuRow(
                icon: Icons.shield_outlined,
                label: 'Privacy Policy',
                onTap: () => _info(
                  context,
                  'Privacy Policy',
                  'We store your name, email and tasks securely in Firebase. '
                      'Only you and the admins can see your tasks. '
                      'Your data is not shared with anyone else.',
                ),
              ),
              const _Line(),
              _MenuRow(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () => _info(
                  context,
                  'Help & Support',
                  'Your tasks are assigned by your admin.\n\n'
                      '• Tap Start when you begin a task, then Complete when it is done.\n'
                      '• Tap Details on a task to read everything about it.\n'
                      '• If a task is missing or wrong, please contact your admin.',
                ),
              ),
              const _Line(),
              _MenuRow(
                icon: Icons.logout_rounded,
                label: 'Log Out',
                color: AppColors.danger,
                showChevron: false,
                onTap: () => AuthService().logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSoft),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 44, color: AppColors.border);
}

class _Line extends StatelessWidget {
  const _Line();
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 1,
    indent: 18,
    endIndent: 18,
    color: AppColors.border,
  );
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool showChevron;
  final Widget? trailing;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.showChevron = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.textSoft;
    final textColor = color ?? AppColors.text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              const Icon(Icons.chevron_right, size: 24, color: AppColors.hint),
          ],
        ),
      ),
    );
  }
}

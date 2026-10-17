import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'common.dart';
import 'notifications.dart';

/// Kitni notifications user dekh chuka hai (bell ka laal dot isi se hide hota hai).
final ValueNotifier<int> seenNotifications = ValueNotifier<int>(0);

class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: const Color(0x33312E81),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 22, color: AppColors.textBody),
              if (badge)
                Positioned(
                  right: 11,
                  top: 10,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationBell extends StatelessWidget {
  final List<AppNotification> items;
  const NotificationBell({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: seenNotifications,
      builder: (context, seen, _) => HeaderIconButton(
        icon: Icons.notifications_none_rounded,
        badge: items.length > seen,
        onTap: () {
          seenNotifications.value = items.length;
          showNotificationsSheet(context, items);
        },
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkMode,
      builder: (_, dark, _) => HeaderIconButton(
        icon: dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        onTap: () => darkMode.value = !dark,
      ),
    );
  }
}

/// Har screen ka apna header: title + (optional) hello/date, avatar, bell, theme, logout.
class PageHeader extends StatelessWidget {
  final String title;
  final String? greetingName;
  final String? avatarText;
  final List<AppNotification>? notifications;
  final bool showThemeToggle;
  final VoidCallback? onLogout;

  const PageHeader({
    super.key,
    required this.title,
    this.greetingName,
    this.avatarText,
    this.notifications,
    this.showThemeToggle = false,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (notifications != null) NotificationBell(items: notifications!),
      if (showThemeToggle) const ThemeToggleButton(),
      if (onLogout != null)
        HeaderIconButton(icon: Icons.logout_rounded, onTap: onLogout!),
      if (avatarText != null)
        InitialsAvatar(
          text: avatarText!,
          size: 42,
          background: AppColors.primary,
        ),
    ];

    final actionRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          actions[i],
        ],
      ],
    );

    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.text,
      ),
    );

    Widget content;
    if (greetingName != null) {
      final date = DateFormat('EEEE, MMM d').format(DateTime.now());
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Hello, ',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textBody,
                        ),
                        children: [
                          TextSpan(
                            text: greetingName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              actionRow,
            ],
          ),
          const SizedBox(height: 12),
          titleText,
        ],
      );
    } else {
      content = Row(
        children: [
          Expanded(child: titleText),
          actionRow,
        ],
      );
    }

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
          child: content,
        ),
      ),
    );
  }
}

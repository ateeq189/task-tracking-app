import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/page_header.dart';

class ShellTab {
  final String label; // bottom nav label
  final IconData icon;
  final Widget header; // is screen ka apna header
  final Widget page;
  final Widget? fab;

  const ShellTab({
    required this.label,
    required this.icon,
    required this.header,
    required this.page,
    this.fab,
  });
}

/// App frame (intern + admin): screen ka header + content + floating bottom bar.
/// Wide screens (web) par phone jaisa centered column.
class MainShell extends StatefulWidget {
  final List<ShellTab> tabs;
  const MainShell({super.key, required this.tabs});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      seenNotifications.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    final current = tabs[_index];

    return Material(
      color: AppColors.page,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Scaffold(
            backgroundColor: AppColors.bg,
            body: Column(
              children: [
                current.header,
                Expanded(
                  child: IndexedStack(
                    index: _index,
                    children: [for (final t in tabs) t.page],
                  ),
                ),
              ],
            ),
            floatingActionButton: current.fab,
            bottomNavigationBar: _BottomNav(
              tabs: tabs,
              index: _index,
              onChanged: (i) => setState(() => _index = i),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final List<ShellTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F312E81),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: tabs[i],
                    active: i == index,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final ShellTab tab;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.purple : AppColors.hint;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: active ? AppColors.purple : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

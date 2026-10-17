import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// White rounded card with a soft shadow (Tailwind: rounded-xl shadow-sm).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final bool bordered;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 12,
    this.color = Colors.white,
    this.bordered = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: br,
        border: bordered ? Border.all(color: AppColors.borderSoft) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: br,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Small rounded action button used inside task cards (Start / Complete / Details).
class SmallButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  const SmallButton({
    super.key,
    required this.label,
    required this.background,
    this.foreground = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill showing the task status (green / amber / gray).
class StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  const StatusBadge({super.key, required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'completed':
        bg = AppColors.green100;
        fg = AppColors.green700;
        break;
      case 'in_progress':
        bg = AppColors.amber100;
        fg = AppColors.amber700;
        break;
      default:
        bg = AppColors.borderSoft;
        fg = AppColors.textBody;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}

/// Horizontal row of filter chips (All / Pending / In Progress / Completed).
class FilterChipsRow extends StatelessWidget {
  final Map<String, String> options; // key -> label
  final String selected;
  final ValueChanged<String> onChanged;

  const FilterChipsRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final e in options.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: e.value,
                active: e.key == selected,
                onTap: () => onChanged(e.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primary : AppColors.indigo50,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.textBody,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped "+ Add Task" button with a purple-to-indigo gradient.
class GradientFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const GradientFab({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x667C3AED),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded progress bar with a smooth animation.
class AppProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0).toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: v),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, animated, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: Container(
            height: height,
            width: double.infinity,
            color: AppColors.border,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: animated,
              child: Container(color: color),
            ),
          ),
        );
      },
    );
  }
}

/// Text label above a field (like the design's `<label>`).
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const LabeledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class PillOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  const PillOption(this.value, this.label, [this.icon]);
}

/// Two/three big toggle buttons (the design's "Select Your Role" buttons).
class PillToggle<T> extends StatelessWidget {
  final List<PillOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const PillToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _pill(options[i])),
        ],
      ],
    );
  }

  Widget _pill(PillOption<T> o) {
    final active = o.value == selected;
    final color = active ? AppColors.primary : AppColors.textMuted;
    return Material(
      color: active ? AppColors.indigo50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: active ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged(o.value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (o.icon != null) ...[
                Icon(o.icon, size: 18, color: color),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  o.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
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

/// Round avatar with initials.
class InitialsAvatar extends StatelessWidget {
  final String text;
  final double size;
  final Color background;
  final Color foreground;

  const InitialsAvatar({
    super.key,
    required this.text,
    this.size = 32,
    this.background = AppColors.primary,
    this.foreground = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}

/// Loading / error view for a Firestore stream. Returns null when data is ready.
Widget? asyncStatusView(AsyncSnapshot<dynamic> snap) {
  if (snap.hasError) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Something went wrong.\n${snap.error}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSoft),
        ),
      ),
    );
  }
  if (!snap.hasData) {
    return const Center(child: CircularProgressIndicator());
  }
  return null;
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppColors.faint),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: AppColors.textSoft),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: AppColors.hint),
          ),
        ],
      ),
    );
  }
}

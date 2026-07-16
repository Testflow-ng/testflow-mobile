import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Borderless surface card: white with a soft layered shadow in light mode,
/// an elevated tonal surface in dark mode.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.space4),
    this.radius = AppDimens.radiusCard,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface =
        color ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final borderRadius = BorderRadius.circular(radius);

    final card = Material(
      color: surface,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            )
          : Padding(padding: padding, child: child),
    );

    if (isDark) return card;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppShadows.card,
      ),
      child: card,
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/models/subject.dart';
import '../../../core/theme/theme.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onLeaderboard;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.isPinned,
    required this.onTap,
    required this.onTogglePin,
    required this.onLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = theme.colorScheme.onSurface.withOpacity(0.5);

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space3,
                      vertical: AppDimens.space1,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusFull),
                    ),
                    child: Text(
                      subject.code,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onLeaderboard,
                    icon: Icon(
                      Icons.leaderboard_outlined,
                      size: AppDimens.iconMd,
                      color: muted,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onTogglePin,
                    icon: Icon(
                      isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      size: AppDimens.iconMd,
                      color: isPinned ? theme.colorScheme.primary : muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.space3),
              Text(
                subject.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimens.space2),
              Row(
                children: [
                  if (subject.level != null) ...[
                    Text('${subject.level} level',
                        style: theme.textTheme.labelMedium),
                    Text('  •  ', style: TextStyle(color: muted)),
                  ],
                  Text(
                    '${subject.questionCount} questions',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

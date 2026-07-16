import 'package:flutter/material.dart';
import '../../../core/models/subject.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class SubjectTile extends StatelessWidget {
  final Subject subject;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const SubjectTile({
    super.key,
    required this.subject,
    required this.isPinned,
    required this.onTap,
    required this.onTogglePin,
  });

  static const _tileColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.info,
    AppColors.success,
    Color(0xFFDB2777),
    Color(0xFFEA580C),
  ];

  Color get _color =>
      _tileColors[subject.code.hashCode.abs() % _tileColors.length];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Text(
                  subject.code.length > 3
                      ? subject.code.substring(0, 3)
                      : subject.code,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (subject.level != null) '${subject.level}L',
                        '${subject.questionCount} questions',
                      ].join('  •  '),
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onTogglePin,
                icon: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  size: AppDimens.iconMd,
                  color: isPinned
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.35),
                ),
              ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';

class VerifyBanner extends StatelessWidget {
  const VerifyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.warning.withOpacity(0.12),
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: InkWell(
        onTap: () => context.push(AppRoutes.verifyEmail),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space4),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: AppDimens.iconMd,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppDimens.space3),
              Expanded(
                child: Text(
                  'Verify your email to take graded exams',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: AppDimens.iconMd,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import 'app_button.dart';

class AsyncView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.space7),
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: onRetry,
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: AppDimens.iconXl,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: AppDimens.space4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimens.space5),
              AppButton(
                label: 'Try again',
                variant: AppButtonVariant.outline,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimens.iconXxl,
              color: theme.colorScheme.onSurface.withOpacity(0.25),
            ),
            const SizedBox(height: AppDimens.space4),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppDimens.space2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            if (action != null) ...[
              const SizedBox(height: AppDimens.space5),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

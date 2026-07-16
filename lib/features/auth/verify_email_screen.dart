import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/api_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/widgets.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  String? _notice;

  Future<void> _resend() async {
    final email = ref.read(authProvider).user?.email;
    if (email == null) return;

    setState(() {
      _isResending = true;
      _notice = null;
    });
    try {
      await ref.read(authRepositoryProvider).resendVerification(email);
      setState(() => _notice = 'Verification email sent. Check your inbox.');
    } on ApiException catch (e) {
      setState(() => _notice = e.message);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerified() async {
    setState(() => _isChecking = true);
    await ref.read(authProvider.notifier).refreshMe();
    if (!mounted) return;
    setState(() => _isChecking = false);

    final auth = ref.read(authProvider);
    if (auth.isVerified) {
      context.go(
        auth.needsUsername ? AppRoutes.usernameSetup : AppRoutes.home,
      );
    } else {
      setState(
        () => _notice =
            'Not verified yet. Tap the link in your email, then try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = ref.watch(authProvider).user?.email ?? 'your email';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    color: theme.colorScheme.primary,
                    size: AppDimens.iconXl,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.space5),
              Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimens.space3),
              Text(
                'We sent a verification link to\n$email',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppDimens.space3),
              Text(
                'You need a verified email to take graded exams.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              if (_notice != null) ...[
                const SizedBox(height: AppDimens.space4),
                Text(
                  _notice!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: AppDimens.space7),
              AppButton(
                label: 'I have verified',
                isFullWidth: true,
                isLoading: _isChecking,
                onPressed: _checkVerified,
              ),
              const SizedBox(height: AppDimens.space3),
              AppButton(
                label: 'Resend email',
                variant: AppButtonVariant.outline,
                isFullWidth: true,
                isLoading: _isResending,
                onPressed: _resend,
              ),
              const SizedBox(height: AppDimens.space3),
              AppButton(
                label: 'Skip for now',
                variant: AppButtonVariant.ghost,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

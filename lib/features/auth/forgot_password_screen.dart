import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/api_providers.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/auth_header.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .forgotPassword(_emailCtrl.text.trim());
    } catch (_) {
      // Same response either way, so account existence is never revealed.
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _sent
              ? _SentView(
                  email: _emailCtrl.text.trim(),
                  onResend: () => setState(() => _sent = false),
                )
              : _RequestView(
                  formKey: _formKey,
                  emailCtrl: _emailCtrl,
                  isLoading: _isLoading,
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

class _RequestView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _RequestView({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppDimens.space4),
            const AuthHeader(
              title: 'Forgot password?',
              subtitle:
                  'Enter the email on your account and we will send you a reset link.',
            ),
            const SizedBox(height: AppDimens.space7),
            AppTextField(
              label: 'Email address',
              hint: 'you@example.com',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              onSubmitted: (_) => onSubmit(),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: AppDimens.space6),
            AppButton(
              label: 'Send Reset Link',
              isFullWidth: true,
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SentView extends StatelessWidget {
  final String email;
  final VoidCallback onResend;

  const _SentView({required this.email, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
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
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.success,
                size: AppDimens.iconXl,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space5),
          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppDimens.space3),
          Text(
            'We sent a password reset link to\n$email',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppDimens.space7),
          AppButton(
            label: 'Back to Sign In',
            isFullWidth: true,
            onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
          ),
          const SizedBox(height: AppDimens.space3),
          AppButton(
            label: 'Resend email',
            variant: AppButtonVariant.text,
            onPressed: onResend,
          ),
        ],
      ),
    );
  }
}

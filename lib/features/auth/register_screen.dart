import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_footer_link.dart';
import 'widgets/auth_header.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _matricCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _agreeTerms = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _matricCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      setState(() => _error = 'Please agree to the Terms and Privacy Policy');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).register(
            fullName: _nameCtrl.text.trim(),
            username: _usernameCtrl.text.trim().toLowerCase(),
            email: _emailCtrl.text.trim(),
            matricNumber: _matricCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      if (mounted) context.go(AppRoutes.verifyEmail);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.welcome),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimens.space4),
                const AuthHeader(
                  title: 'Create your account',
                  subtitle:
                      'Start practicing in minutes. No credit card needed.',
                ),
                const SizedBox(height: AppDimens.space7),
                if (_error != null) ...[
                  AuthErrorBanner(message: _error!),
                  const SizedBox(height: AppDimens.space4),
                ],
                AppTextField(
                  label: 'Full name',
                  hint: 'Your name',
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  prefixIcon:
                      const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.space4),
                AppTextField(
                  label: 'Username',
                  hint: 'e.g. adaeze_o',
                  controller: _usernameCtrl,
                  prefixIcon:
                      const Icon(Icons.alternate_email_rounded, size: 20),
                  validator: (v) {
                    final value = v?.trim().toLowerCase() ?? '';
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (value.length > 20) {
                      return 'Username must be at most 20 characters';
                    }
                    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
                      return 'Only letters, numbers, and underscores';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.space4),
                AppTextField(
                  label: 'Email address',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.space4),
                AppTextField(
                  label: 'Matric number (optional)',
                  hint: 'e.g. CSC/2021/044',
                  controller: _matricCtrl,
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                ),
                const SizedBox(height: AppDimens.space4),
                AppTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  onSubmitted: (_) => _submit(),
                  helperText: 'At least 8 characters with a letter and a number',
                  validator: (v) {
                    if (v == null || v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'[A-Za-z]').hasMatch(v)) {
                      return 'Password must include a letter';
                    }
                    if (!RegExp(r'\d').hasMatch(v)) {
                      return 'Password must include a number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.space4),
                _TermsCheckbox(
                  value: _agreeTerms,
                  onChanged: (v) => setState(() => _agreeTerms = v),
                ),
                const SizedBox(height: AppDimens.space5),
                AppButton(
                  label: 'Create Account',
                  isFullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppDimens.space7),
                AuthFooterLink(
                  text: 'Already have an account?',
                  linkText: 'Sign in',
                  onTap: () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.space3),
        Expanded(
          child: Text(
            'I agree to the Terms of Service and Privacy Policy',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}

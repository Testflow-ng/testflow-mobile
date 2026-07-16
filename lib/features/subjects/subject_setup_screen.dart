import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/subject.dart';
import '../../core/providers/api_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

class SubjectSetupScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const SubjectSetupScreen({super.key, this.isOnboarding = false});

  @override
  ConsumerState<SubjectSetupScreen> createState() =>
      _SubjectSetupScreenState();
}

class _SubjectSetupScreenState extends ConsumerState<SubjectSetupScreen> {
  late final Set<String> _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected = {...?ref.read(authProvider).user?.pinnedSubjects};
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final pinned = ref.read(authProvider).user?.pinnedSubjects ?? const [];
    final repo = ref.read(subjectRepositoryProvider);

    try {
      final changes = {
        ..._selected.where((id) => !pinned.contains(id)),
        ...pinned.where((id) => !_selected.contains(id)),
      };
      for (final id in changes) {
        await repo.togglePin(id);
      }
      await ref.read(authProvider.notifier).refreshMe();
      if (!mounted) return;
      if (widget.isOnboarding) {
        context.go(AppRoutes.verifyEmail);
      } else {
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save your subjects. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isOnboarding,
        title: widget.isOnboarding ? null : const Text('My subjects'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                AppDimens.space2,
                AppDimens.screenPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isOnboarding) ...[
                    Text('Choose your\nsubjects',
                        style: theme.textTheme.displaySmall),
                    const SizedBox(height: AppDimens.space3),
                  ],
                  Text(
                    'Pick the subjects you are preparing for. They stay pinned to the top of your practice list, and you can change them anytime.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space5),
            Expanded(
              child: AsyncView(
                value: subjects,
                onRetry: () => ref.invalidate(subjectsProvider),
                builder: (list) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPadding,
                    0,
                    AppDimens.screenPadding,
                    AppDimens.space4,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimens.space3),
                  itemBuilder: (context, index) {
                    final subject = list[index];
                    return _SelectableSubject(
                      subject: subject,
                      isSelected: _selected.contains(subject.id),
                      onTap: () => setState(() {
                        if (!_selected.remove(subject.id)) {
                          _selected.add(subject.id);
                        }
                      }),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                AppDimens.space3,
                AppDimens.screenPadding,
                AppDimens.space4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    label: _selected.isEmpty
                        ? 'Select at least one subject'
                        : 'Save ${_selected.length} subject${_selected.length == 1 ? '' : 's'}',
                    isFullWidth: true,
                    isLoading: _isSaving,
                    onPressed: _selected.isEmpty ? null : _save,
                  ),
                  if (widget.isOnboarding)
                    AppButton(
                      label: 'Skip for now',
                      variant: AppButtonVariant.ghost,
                      onPressed: () => context.go(AppRoutes.verifyEmail),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectableSubject extends StatelessWidget {
  final Subject subject;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableSubject({
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.code, style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(
                  subject.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? primary : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? primary
                    : theme.colorScheme.onSurface.withOpacity(0.25),
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}

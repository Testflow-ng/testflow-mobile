import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/subject.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

Future<void> showStartExamSheet(BuildContext context, Subject subject) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
    ),
    builder: (context) => StartExamSheet(subject: subject),
  );
}

class StartExamSheet extends ConsumerStatefulWidget {
  final Subject subject;

  const StartExamSheet({super.key, required this.subject});

  @override
  ConsumerState<StartExamSheet> createState() => _StartExamSheetState();
}

class _StartExamSheetState extends ConsumerState<StartExamSheet> {
  static const _countOptions = [10, 20, 30, 40, 50];

  late int _questionCount;
  bool _isStarting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final available = widget.subject.questionCount;
    _questionCount = available >= 20 ? 20 : _clampToAvailable(available);
  }

  int _clampToAvailable(int available) {
    for (final option in _countOptions.reversed) {
      if (option <= available) return option;
    }
    return available;
  }

  int get _durationMinutes => _questionCount;

  Future<void> _start() async {
    setState(() {
      _isStarting = true;
      _error = null;
    });

    try {
      final session = await ref.read(examRepositoryProvider).start(
            subject: widget.subject.code,
            questionCount: _questionCount,
            durationMinutes: _durationMinutes,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push(AppRoutes.exam(session.id));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not start the exam. Please try again.');
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = widget.subject.questionCount;
    final options =
        _countOptions.where((option) => option <= available).toList();
    if (options.isEmpty && available > 0) options.add(available);

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.screenPadding,
        right: AppDimens.screenPadding,
        top: AppDimens.space5,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppDimens.space6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.subject.code,
                        style: theme.textTheme.labelMedium),
                    const SizedBox(height: AppDimens.space1),
                    Text(widget.subject.title,
                        style: theme.textTheme.headlineSmall),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.leaderboard, extra: widget.subject);
                },
                icon: const Icon(Icons.leaderboard_outlined,
                    size: AppDimens.iconSm),
                label: const Text('Top 10'),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space5),
          if (_error != null) ...[
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: AppDimens.space4),
          ],
          Text('Number of questions', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppDimens.space3),
          Wrap(
            spacing: AppDimens.space2,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text('$option'),
                  selected: _questionCount == option,
                  onSelected: (_) => setState(() => _questionCount = option),
                  shape: const StadiumBorder(),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space5),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: AppDimens.iconSm,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: AppDimens.space2),
              Text(
                '$_durationMinutes minutes, one minute per question',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space6),
          AppButton(
            label: 'Start Exam',
            isFullWidth: true,
            isLoading: _isStarting,
            onPressed: available == 0 ? null : _start,
          ),
        ],
      ),
    );
  }
}

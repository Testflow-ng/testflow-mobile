import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/exam.dart';
import '../../core/providers/api_providers.dart';
import '../../core/providers/data_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/calculator_sheet.dart';
import 'widgets/exam_timer.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_palette.dart';

class ExamScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ExamScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen>
    with WidgetsBindingObserver {
  static const _textScales = [1.0, 1.15, 1.3];

  ExamSession? _session;
  List<ExamQuestion> _questions = [];
  int _currentIndex = 0;
  int _secondsLeft = 0;
  int _strikes = 0;
  int _textScaleIndex = 0;
  Timer? _ticker;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !_isSubmitting) {
      _handleFocusLost();
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final session =
          await ref.read(examRepositoryProvider).getSession(widget.sessionId);
      if (!mounted) return;
      if (!session.isInProgress) {
        context.pushReplacement(AppRoutes.examResult(session.id));
        return;
      }
      setState(() {
        _session = session;
        _questions = session.questions;
        _secondsLeft = session.remainingSeconds;
        _isLoading = false;
        _currentIndex = _firstUnanswered(session.questions);
      });
      _startTicker();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.message;
        });
      }
    }
  }

  int _firstUnanswered(List<ExamQuestion> questions) {
    final index = questions.indexWhere((q) => q.selectedOption == null);
    return index == -1 ? 0 : index;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _ticker?.cancel();
        _submit(auto: true);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _handleFocusLost() async {
    try {
      final result =
          await ref.read(examRepositoryProvider).recordStrike(widget.sessionId);
      if (!mounted) return;
      _strikes = result.strikes;
      if (result.status == 'submitted') {
        _goToResult();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Leaving the app during an exam counts as a strike '
              '($_strikes of 3). Three strikes auto-submits.',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (_) {
      // Strike recording is best-effort; the server enforces the rule.
    }
  }

  Future<void> _selectOption(int optionIndex) async {
    HapticFeedback.selectionClick();
    final question = _questions[_currentIndex];
    setState(() {
      _questions[_currentIndex] =
          question.copyWith(selectedOption: optionIndex);
    });
    try {
      await ref.read(examRepositoryProvider).saveAnswer(
            widget.sessionId,
            questionIndex: _currentIndex,
            selectedOption: optionIndex,
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'SESSION_EXPIRED' || e.code == 'SESSION_CLOSED') {
        _goToResult();
        return;
      }
      setState(() {
        _questions[_currentIndex] = question;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save answer. Check your connection.')),
      );
    }
  }

  Future<void> _clearAnswer() async {
    final question = _questions[_currentIndex];
    if (question.selectedOption == null) return;
    setState(() {
      _questions[_currentIndex] = question.copyWith(selectedOption: null);
    });
    try {
      await ref.read(examRepositoryProvider).saveAnswer(
            widget.sessionId,
            questionIndex: _currentIndex,
            clearSelection: true,
          );
    } catch (_) {
      if (mounted) {
        setState(() => _questions[_currentIndex] = question);
      }
    }
  }

  void _cycleTextSize() {
    setState(() {
      _textScaleIndex = (_textScaleIndex + 1) % _textScales.length;
    });
  }

  void _showRules() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exam rules'),
        content: const Text(
          '1. The timer keeps running even if you leave the app.\n\n'
          '2. Leaving the app during the exam counts as a strike. '
          'Three strikes and the exam submits itself.\n\n'
          '3. When time runs out, your answers are submitted automatically.\n\n'
          '4. Every answer saves instantly, so nothing is lost if your '
          'connection drops.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMarked() async {
    final question = _questions[_currentIndex];
    final next = !question.markedForReview;
    setState(() {
      _questions[_currentIndex] = question.copyWith(markedForReview: next);
    });
    try {
      await ref.read(examRepositoryProvider).saveAnswer(
            widget.sessionId,
            questionIndex: _currentIndex,
            markedForReview: next,
          );
    } catch (_) {
      if (mounted) {
        setState(() => _questions[_currentIndex] = question);
      }
    }
  }

  Future<void> _confirmSubmit() async {
    final unanswered =
        _questions.where((q) => q.selectedOption == null).length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit exam?'),
        content: Text(
          unanswered == 0
              ? 'You answered all ${_questions.length} questions.'
              : 'You have $unanswered unanswered '
                  'question${unanswered == 1 ? '' : 's'}. '
                  'Unanswered questions score zero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed == true) _submit();
  }

  Future<void> _submit({bool auto = false}) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _ticker?.cancel();

    try {
      await ref.read(examRepositoryProvider).submit(widget.sessionId);
      if (!mounted) return;
      _goToResult();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (!auto) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } else {
        _goToResult();
      }
    }
  }

  void _goToResult() {
    ref.invalidate(sessionsProvider);
    ref.invalidate(statsProvider);
    context.pushReplacement(AppRoutes.examResult(widget.sessionId));
  }

  void _goTo(int index) {
    if (index < 0 || index >= _questions.length) return;
    setState(() => _currentIndex = index);
  }

  void _showPalette() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      builder: (context) => QuestionPalette(
        questions: _questions,
        currentIndex: _currentIndex,
        onSelect: _goTo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(message: _loadError!, onRetry: _load),
      );
    }

    final question = _questions[_currentIndex];
    final answered = _questions.where((q) => q.selectedOption != null).length;
    final isLast = _currentIndex == _questions.length - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmSubmit();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(_session?.subjectCode ?? ''),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: _showRules,
              tooltip: 'Exam rules',
              icon: const Icon(Icons.info_outline_rounded,
                  size: AppDimens.iconMd),
            ),
            ExamTimer(secondsLeft: _secondsLeft),
            const SizedBox(width: AppDimens.screenPadding),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                ),
                child: Row(
                  children: [
                    Text(
                      'Question ${_currentIndex + 1} of ${_questions.length}',
                      style: theme.textTheme.labelMedium,
                    ),
                    const Spacer(),
                    Text(
                      '$answered answered',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.space2),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    minHeight: 4,
                    backgroundColor:
                        theme.colorScheme.onSurface.withOpacity(0.08),
                  ),
                ),
              ),
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler:
                        TextScaler.linear(_textScales[_textScaleIndex]),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimens.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(question.stem, style: theme.textTheme.titleLarge),
                        const SizedBox(height: AppDimens.space5),
                        for (var i = 0; i < question.options.length; i++) ...[
                          OptionTile(
                            index: i,
                            text: question.options[i],
                            isSelected: question.selectedOption == i,
                            onTap: () => _selectOption(i),
                          ),
                          const SizedBox(height: AppDimens.space3),
                        ],
                        if (question.selectedOption != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _clearAnswer,
                              icon: const Icon(Icons.undo_rounded,
                                  size: AppDimens.iconSm),
                              label: const Text('Clear answer'),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              _BottomBar(
                isMarked: question.markedForReview,
                canGoBack: _currentIndex > 0,
                isLast: isLast,
                isSubmitting: _isSubmitting,
                onPrevious: () => _goTo(_currentIndex - 1),
                onNext: () => _goTo(_currentIndex + 1),
                onMark: _toggleMarked,
                onPalette: _showPalette,
                onCalculator: () => showCalculatorSheet(context),
                onTextSize: _cycleTextSize,
                onSubmit: _confirmSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isMarked;
  final bool canGoBack;
  final bool isLast;
  final bool isSubmitting;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onMark;
  final VoidCallback onPalette;
  final VoidCallback onCalculator;
  final VoidCallback onTextSize;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.isMarked,
    required this.canGoBack,
    required this.isLast,
    required this.isSubmitting,
    required this.onPrevious,
    required this.onNext,
    required this.onMark,
    required this.onPalette,
    required this.onCalculator,
    required this.onTextSize,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedIcon = theme.colorScheme.onSurface.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space3,
        AppDimens.space3,
        AppDimens.space3,
        AppDimens.space3,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onMark,
            tooltip: 'Mark for review',
            icon: Icon(
              isMarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: isMarked ? AppColors.warning : mutedIcon,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onPalette,
            tooltip: 'All questions',
            icon: Icon(Icons.grid_view_rounded, color: mutedIcon),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onCalculator,
            tooltip: 'Calculator',
            icon: Icon(Icons.calculate_outlined, color: mutedIcon),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onTextSize,
            tooltip: 'Text size',
            icon: Icon(Icons.text_fields_rounded, color: mutedIcon),
          ),
          const Spacer(),
          if (canGoBack)
            IconButton(
              onPressed: onPrevious,
              tooltip: 'Previous question',
              icon: Icon(Icons.chevron_left_rounded,
                  size: AppDimens.iconLg, color: mutedIcon),
            ),
          const SizedBox(width: AppDimens.space1),
          AppButton(
            label: isLast ? 'Submit' : 'Next',
            height: AppDimens.buttonMd,
            isLoading: isSubmitting,
            onPressed: isLast ? onSubmit : onNext,
          ),
        ],
      ),
    );
  }
}

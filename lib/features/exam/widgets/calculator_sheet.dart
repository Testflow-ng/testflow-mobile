import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';
import '../utils/calculator_engine.dart';

Future<void> showCalculatorSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
    ),
    builder: (context) => const CalculatorSheet(),
  );
}

class CalculatorSheet extends StatefulWidget {
  const CalculatorSheet({super.key});

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  String _expression = '';
  String? _result;
  bool _justEvaluated = false;

  void _tap(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      switch (key) {
        case 'C':
          _expression = '';
          _result = null;
          _justEvaluated = false;
        case '⌫':
          if (_justEvaluated) {
            _expression = '';
            _result = null;
            _justEvaluated = false;
          } else if (_expression.isNotEmpty) {
            _expression =
                _expression.substring(0, _expression.length - 1);
            _result = null;
          }
        case '=':
          final value = CalculatorEngine.evaluate(_expression);
          _result = value == null ? 'Error' : CalculatorEngine.format(value);
          _justEvaluated = true;
        default:
          if (_justEvaluated) {
            final isOperator = '+-*/%²'.contains(key);
            if (isOperator && _result != null && _result != 'Error') {
              _expression = _result! + key;
            } else {
              _expression = key;
            }
            _result = null;
            _justEvaluated = false;
          } else {
            _expression += key;
          }
      }
    });
  }

  String get _display {
    if (_result != null) return _result!;
    if (_expression.isEmpty) return '0';
    return _expression.replaceAll('*', '×').replaceAll('/', '÷');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPadding,
          AppDimens.space4,
          AppDimens.screenPadding,
          AppDimens.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Calculator', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppDimens.space3),
            Container(
              padding: const EdgeInsets.all(AppDimens.space4),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _display,
                  maxLines: 1,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.space4),
            for (final row in _rows) ...[
              Row(
                children: [
                  for (final key in row)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: _CalcKey(label: key, onTap: () => _tap(key)),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _rows = [
    ['C', '√', '²', '⌫'],
    ['(', ')', '%', '/'],
    ['7', '8', '9', '*'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['00', '0', '.', '='],
  ];
}

class _CalcKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CalcKey({required this.label, required this.onTap});

  static const _displayOverrides = {'*': '×', '/': '÷', '²': 'x²'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEquals = label == '=';
    final isAction = 'C⌫√²%()'.contains(label);
    final isOperator = '+-*/'.contains(label);

    final Color background;
    final Color foreground;
    if (isEquals) {
      background = theme.colorScheme.primary;
      foreground = Colors.white;
    } else if (isOperator || isAction) {
      background = theme.colorScheme.primary.withOpacity(0.08);
      foreground = theme.colorScheme.primary;
    } else {
      background = theme.colorScheme.onSurface.withOpacity(0.05);
      foreground = theme.colorScheme.onSurface;
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              _displayOverrides[label] ?? label,
              style: theme.textTheme.titleLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

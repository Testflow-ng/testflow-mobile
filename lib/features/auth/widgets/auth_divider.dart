import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({super.key, this.label = 'or'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = Divider(color: theme.colorScheme.outline.withOpacity(0.5));

    return Row(
      children: [
        Expanded(child: line),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space4),
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(child: line),
      ],
    );
  }
}

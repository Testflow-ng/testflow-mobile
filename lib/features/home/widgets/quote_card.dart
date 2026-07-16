import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  static const _quotes = [
    ('Success is the sum of small efforts repeated day in and day out.', 'Robert Collier'),
    ('The secret of getting ahead is getting started.', 'Mark Twain'),
    ('The expert in anything was once a beginner.', 'Helen Hayes'),
    ('It always seems impossible until it is done.', 'Nelson Mandela'),
    ('Learning is never done without errors and defeat.', 'Vladimir Lenin'),
    ('The beautiful thing about learning is that no one can take it away from you.', 'B. B. King'),
    ('You do not have to be great to start, but you have to start to be great.', 'Zig Ziglar'),
    ('Practice is the hardest part of learning, and training is the essence of transformation.', 'Ann Voskamp'),
    ('There are no shortcuts to any place worth going.', 'Beverly Sills'),
    ('Push yourself, because no one else is going to do it for you.', 'Unknown'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final (quote, author) = _quotes[dayOfYear % _quotes.length];

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: theme.colorScheme.primary,
            size: AppDimens.iconLg,
          ),
          const SizedBox(width: AppDimens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppDimens.space2),
                Text(author, style: theme.textTheme.labelMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

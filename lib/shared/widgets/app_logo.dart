import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// TestFlow logo widget — shows the PNG logo with optional wordmark.
/// Matches Logo.jsx from the website.
class AppLogo extends StatelessWidget {
  final double size;
  final bool withWordmark;
  final bool light; // use white text for dark backgrounds

  const AppLogo({
    super.key,
    this.size = AppDimens.logoMd,
    this.withWordmark = true,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          filterQuality: FilterQuality.high,
        ),
        if (withWordmark) ...[
          const SizedBox(width: 10),
          Text(
            'TestFlow',
            style: TextStyle(
              fontFamily: 'BricolageGrotesque',
              package: null,
              fontSize: size * 0.5,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

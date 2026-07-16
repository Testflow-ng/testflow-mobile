import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback? onTap;

  const OnboardingSkipButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.space4,
            vertical: AppDimens.space2,
          ),
          child: Text(
            'Skip',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

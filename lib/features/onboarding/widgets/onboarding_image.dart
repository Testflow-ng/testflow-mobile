import 'package:flutter/material.dart';

class OnboardingImage extends StatelessWidget {
  final String image;

  const OnboardingImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.45, 1.0],
              colors: [
                Colors.black.withOpacity(0.25),
                Colors.black.withOpacity(0.15),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

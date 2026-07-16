class OnboardingPageData {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingPageData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

const onboardingPages = [
  OnboardingPageData(
    image: 'assets/images/onboarding/onboarding_practice.webp',
    title: 'Practice like\nthe real exam',
    subtitle:
        'Timed CBT sessions with real past questions and instant scoring, built to feel exactly like exam day.',
  ),
  OnboardingPageData(
    image: 'assets/images/onboarding/onboarding_study.webp',
    title: 'Study smarter,\nnot longer',
    subtitle:
        'Detailed analytics show your strengths and weak topics so every session moves your score forward.',
  ),
  OnboardingPageData(
    image: 'assets/images/onboarding/onboarding_succeed.webp',
    title: 'Walk in ready.\nWalk out proud',
    subtitle:
        'Join thousands of students using TestFlow to pass their exams with confidence.',
  ),
];

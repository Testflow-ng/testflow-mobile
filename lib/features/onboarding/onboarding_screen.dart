import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import 'onboarding_pages.dart';
import 'widgets/onboarding_image.dart';
import 'widgets/onboarding_skip_button.dart';
import 'widgets/onboarding_text_block.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == onboardingPages.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final page in onboardingPages) {
      precacheImage(AssetImage(page.image), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_isLastPage) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finish() {
    ref.read(onboardingProvider.notifier).complete();
    context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray900,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) =>
                OnboardingImage(image: onboardingPages[index].image),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppDimens.space3,
                  right: AppDimens.screenPadding,
                ),
                child: AnimatedOpacity(
                  opacity: _isLastPage ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: OnboardingSkipButton(
                    onTap: _isLastPage ? null : _finish,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPadding,
                  0,
                  AppDimens.screenPadding,
                  AppDimens.space5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OnboardingTextBlock(
                      page: onboardingPages[_currentPage],
                      pageIndex: _currentPage,
                    ),
                    const SizedBox(height: AppDimens.space6),
                    Row(
                      children: [
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: onboardingPages.length,
                          effect: ExpandingDotsEffect(
                            dotColor: Colors.white.withOpacity(0.3),
                            activeDotColor: Colors.white,
                            dotHeight: 7,
                            dotWidth: 7,
                            expansionFactor: 3.5,
                            spacing: 6,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: AppDimens.buttonLg,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.gray900,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.space6,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_isLastPage ? 'Get Started' : 'Next'),
                                const SizedBox(width: AppDimens.space2),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: AppDimens.iconMd,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

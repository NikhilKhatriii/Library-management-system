import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../application/onboarding_provider.dart';
import '../../../../core/utils/responsive_utils.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    const _OnboardingData(
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      icon: Icons.auto_stories_rounded,
      color: AppColors.primary,
    ),
    const _OnboardingData(
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      icon: Icons.search_rounded,
      color: AppColors.secondary,
    ),
    const _OnboardingData(
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      icon: Icons.swap_horizontal_circle_rounded,
      color: AppColors.royalBlue,
    ),
    const _OnboardingData(
      title: AppStrings.onboardingTitle4,
      description: AppStrings.onboardingDesc4,
      icon: Icons.analytics_rounded,
      color: AppColors.accent,
    ),
    const _OnboardingData(
      title: AppStrings.onboardingTitle5,
      description: AppStrings.onboardingDesc5,
      icon: Icons.grid_view_rounded,
      color: AppColors.royalBlue,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _onPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _complete() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    context.goNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: AppBackgrounds.onboarding(
        child: SafeArea(
          child: ResponsiveBuilder(
            builder: (context, screenType, child) {
              final isDesktop = screenType == ScreenType.desktop || screenType == ScreenType.wideDesktop;
              
              final double iconCircleSize = const ResponsiveValue<double>(
                mobile: 120,
                tablet: 200,
                desktop: 260,
                wideDesktop: 300,
              ).resolve(context);
              
              final double iconSize = iconCircleSize * 0.5;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _complete,
                          child: const Text('Skip'),
                        ).animate().fadeIn(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        final data = _pages[index];
                        
                        final iconWidget = Container(
                          width: iconCircleSize,
                          height: iconCircleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: data.color.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            data.icon,
                            size: iconSize,
                            color: data.color,
                          ),
                        ).animate().scale(
                              duration: AppDurations.slow,
                              curve: Curves.easeOutBack,
                            );
                            
                        final textWidget = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                          children: [
                            Text(
                              data.title,
                              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                fontSize: isDesktop ? 42 : null,
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              data.description,
                              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.hintColor,
                                fontSize: isDesktop ? 18 : null,
                              ),
                            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                          ],
                        );

                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 600),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                              child: isDesktop
                                  ? Row(
                                      children: [
                                        Expanded(child: Center(child: iconWidget)),
                                        const SizedBox(width: AppSpacing.xxl),
                                        Expanded(child: textWidget),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        iconWidget,
                                        const SizedBox(height: AppSpacing.xxl),
                                        textWidget,
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: AppDurations.fast,
                              margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4),
                              height: 8,
                              width: _currentPage == index ? (isDesktop ? 32 : 24) : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 600),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (_currentPage > 0)
                                  IconButton.filledTonal(
                                    onPressed: _onPrevious,
                                    icon: const Icon(Icons.chevron_left_rounded),
                                    iconSize: isDesktop ? 28 : null,
                                  ).animate().fadeIn()
                                else
                                  const SizedBox(width: 48),
                                PrimaryButton(
                                  label: isLastPage ? 'Get Started' : 'Next',
                                  expand: false,
                                  onPressed: _onNext,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

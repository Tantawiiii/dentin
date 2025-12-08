import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/widgets/primary_button.dart';
import 'widgets/onboarding_page.dart';
import 'data/onboarding_page_data.dart';
import 'widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: AppTexts.onTitle1,
      description: AppTexts.onDesTitle1,
      icon: Icons.people_alt_rounded,
      gradient: AppColors.primaryGradient,
    ),
    OnboardingPageData(
      title: AppTexts.onTitle2,
      description: AppTexts.onDesTitle2,
      icon: Icons.network_cell_rounded,
      gradient: AppColors.secondaryGradient,
    ),
    OnboardingPageData(
      title: AppTexts.onTitle3,
      description: AppTexts.onDesTitle3,
      icon: Icons.trending_up_rounded,
      gradient: AppColors.accentGradient,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16.h, right: 24.w, left: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    Bounce(
                      onTap: _skipToEnd,
                      duration: const Duration(milliseconds: 120),
                      child: Text(
                        AppTexts.skip,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index], pageIndex: index);
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => PageIndicator(
                    isActive: index == _currentPage,
                    index: index,
                    currentPage: _currentPage,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: Bounce(
                        onTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          height: 56.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            AppTexts.prev,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: 16.w),

                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: PrimaryButton(
                      title: _currentPage == _pages.length - 1
                          ? AppTexts.getStarted
                          : AppTexts.next,
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

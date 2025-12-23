import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/di/inject.dart' as di;
import '../../shared/widgets/shimmer_placeholder.dart';
import 'cubit/stories_cubit.dart';
import 'cubit/stories_state.dart';
import 'widgets/video_story_item.dart';

class ExploreStoriesScreen extends StatefulWidget {
  const ExploreStoriesScreen({super.key});

  @override
  State<ExploreStoriesScreen> createState() => _ExploreStoriesScreenState();
}

class _ExploreStoriesScreenState extends State<ExploreStoriesScreen> {
  late final StoriesCubit _storiesCubit;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _storiesCubit = di.sl<StoriesCubit>();
    _storiesCubit.loadStories();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _storiesCubit.close();
    super.dispose();
  }

  void _refreshStories() {
    _storiesCubit.refreshStories();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    final stories = _storiesCubit.state is StoriesLoaded
        ? (_storiesCubit.state as StoriesLoaded).stories
        : [];
    if (_currentIndex < stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _storiesCubit,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<StoriesCubit, StoriesState>(
          builder: (context, state) {
            if (state is StoriesLoading) {
              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.black,
                    child: const Center(child: _StoriesLoadingShimmer()),
                  );
                },
              );
            }

            if (state is StoriesError) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: _refreshStories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                        ),
                        child: Text(AppTexts.retry),
                      ),
                    ],
                  ),
                ),
              );
            }

            final stories = state is StoriesLoaded ? state.stories : [];

            if (stories.isEmpty) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 64.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppTexts.noStoriesYet,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              onPageChanged: _onPageChanged,
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return VideoStoryItem(
                  post: story,
                  isPlaying: index == _currentIndex,
                  onPrevious: _goToPrevious,
                  onNext: _goToNext,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StoriesLoadingShimmer extends StatelessWidget {
  const _StoriesLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerPlaceholder(
      width: 200.w,
      height: 200.w,
      borderRadius: BorderRadius.circular(24.r),
    );
  }
}

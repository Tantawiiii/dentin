import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/di/inject.dart' as di;
import 'cubit/post_cubit.dart';
import 'cubit/post_state.dart';
import 'widgets/create_post_widget.dart';
import 'widgets/post_item_widget.dart';
import 'widgets/post_item_shimmer.dart';
import 'widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PostCubit _postCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _postCubit = di.sl<PostCubit>();
    _postCubit.loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = _postCubit.state;
      if (state is PostLoaded && state.hasMore) {
        _postCubit.loadMorePosts();
      }
    }
  }

  void _refreshPosts() {
    _postCubit.refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _postCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostLoading) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: CreatePostWidget(postCubit: _postCubit),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return const PostItemShimmer();
                      }, childCount: 5),
                    ),
                  ],
                );
              }

              if (state is PostError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: _refreshPosts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                        ),
                        child: Text(AppTexts.retry),
                      ),
                    ],
                  ),
                );
              }

              final posts = state is PostLoaded ? state.posts : [];
              final isLoadingMore = state is PostLoadingMore;

              return RefreshIndicator(
                onRefresh: () async {
                  _postCubit.refreshPosts();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: CreatePostWidget(postCubit: _postCubit),
                    ),
                    if (posts.isEmpty && !isLoadingMore)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.feed_outlined,
                                size: 64.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                AppTexts.noPostsYet,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final post = posts[index];
                          return PostItemWidget(post: post);
                        }, childCount: posts.length),
                      ),
                      if (isLoadingMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

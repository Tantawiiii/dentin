import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/di/inject.dart' as di;
import 'cubit/post_cubit.dart';
import 'cubit/post_state.dart';
import 'widgets/create_post_widget.dart';
import 'widgets/post_item_widget.dart';
import 'widgets/post_item_shimmer.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/home_drawer.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  final Function(VoidCallback)? onRefreshReady;

  const HomeScreen({super.key, this.onTabChange, this.onRefreshReady});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PostCubit _postCubit;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();

  @override
  void initState() {
    super.initState();
    _postCubit = di.sl<PostCubit>();
    _postCubit.loadPosts();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRefreshReady?.call(_refreshPosts);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
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

  void refresh() {
    _refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _postCubit,
      child: SliderDrawer(
        key: _sliderDrawerKey,
        slider: HomeDrawer(
          sliderDrawerKey: _sliderDrawerKey,
          onTabChange: widget.onTabChange,
        ),
        appBar: CustomAppBar(sliderDrawerKey: _sliderDrawerKey),
        child: Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          extendBody: false,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<PostCubit, PostState>(
              // Important for pagination:
              // we must rebuild when state returns from PostLoadingMore to PostLoaded
              // so the newly fetched items become visible in the list.
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                final posts = _postCubit.posts;
                final isLoading = state is PostLoading && posts.isEmpty;
                
                if (isLoading) {
                  return CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
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

                if (state is PostError && posts.isEmpty) {
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

                return RefreshIndicator(
                  onRefresh: () async {
                    _postCubit.refreshPosts();
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: CreatePostWidget(postCubit: _postCubit),
                      ),
                      if (posts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
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
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final post = posts[index];
                              return RepaintBoundary(
                                key: ValueKey('post_${post.id}'),
                                child: PostItemWidget(
                                  key: ValueKey(post.id),
                                  post: post,
                                  index: index,
                                  onPostUpdated: _refreshPosts,
                                ),
                              );
                            },
                            childCount: posts.length,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: BlocBuilder<PostCubit, PostState>(
                            buildWhen: (p, c) => c is PostLoadingMore || p is PostLoadingMore || c is PostLoaded,
                            builder: (context, state) {
                              if (state is PostLoadingMore) {
                                return Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return SizedBox(height: 20.h);
                            },
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
      ),
    );
  }
}

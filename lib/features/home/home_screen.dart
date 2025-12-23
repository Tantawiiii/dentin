import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/app_colors.dart';
import '../../core/di/inject.dart' as di;
import '../../core/routing/app_routes.dart';
import '../../core/services/storage_service.dart';
import 'cubit/post_cubit.dart';
import 'cubit/post_state.dart';
import 'widgets/create_post_widget.dart';
import 'widgets/post_item_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PostCubit _postCubit;

  @override
  void initState() {
    super.initState();
    _postCubit = di.sl<PostCubit>();
    _postCubit.loadPosts();
  }

  @override
  void dispose() {
    _postCubit.close();
    super.dispose();
  }

  Future<void> _logout() async {
    final storageService = di.sl<StorageService>();
    await storageService.clearAll();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            if (state is PostLoading) {
              return const Center(child: CircularProgressIndicator());
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
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final posts = state is PostLoaded ? state.posts : [];

            return RefreshIndicator(
              onRefresh: () async {
                _postCubit.refreshPosts();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: CreatePostWidget(postCubit: _postCubit),
                  ),
                  if (posts.isEmpty)
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
                              'No posts yet',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final post = posts[index];
                        return PostItemWidget(post: post);
                      }, childCount: posts.length),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

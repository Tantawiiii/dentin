import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/di/inject.dart' as di;
import 'cubit/post_cubit.dart';
import 'cubit/post_state.dart';
import 'data/models/post_models.dart';
import 'widgets/post_item_widget.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  late final PostCubit _postCubit;

  @override
  void initState() {
    super.initState();
    _postCubit = di.sl<PostCubit>();
    _postCubit.loadPosts(refresh: true);
  }

  @override
  void dispose() {
    _postCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _postCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppTexts.savedPosts),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        backgroundColor: AppColors.background,
        body: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            List<Post> savedPosts = [];

            if (state is PostLoaded) {
              savedPosts = state.posts
                  .where((post) => post.isSaved && !post.isHidden)
                  .toList();
            }

            if (state is PostLoading && savedPosts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (savedPosts.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No saved posts yet',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await _postCubit.loadPosts(refresh: true);
              },
              child: ListView.builder(
                padding: EdgeInsets.all(8.w),
                itemCount: savedPosts.length,
                itemBuilder: (context, index) {
                  final post = savedPosts[index];
                  return PostItemWidget(
                    key: ValueKey('saved_post_${post.id}'),
                    post: post,
                    index: index,
                    onPostUpdated: () => _postCubit.loadPosts(refresh: true),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

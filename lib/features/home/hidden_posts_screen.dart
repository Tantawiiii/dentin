import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/di/inject.dart' as di;
import 'data/models/post_models.dart';
import 'data/repo/post_repository.dart';
import 'widgets/post_item_widget.dart';

class HiddenPostsScreen extends StatefulWidget {
  const HiddenPostsScreen({super.key});

  @override
  State<HiddenPostsScreen> createState() => _HiddenPostsScreenState();
}

class _HiddenPostsScreenState extends State<HiddenPostsScreen> {
  final PostRepository _postRepository = di.sl<PostRepository>();
  bool _isLoading = true;
  List<Post> _hiddenPosts = [];

  @override
  void initState() {
    super.initState();
    _loadHiddenPosts();
  }

  Future<void> _loadHiddenPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _postRepository.getPosts(page: 1);
      setState(() {
        _hiddenPosts =
            response.data.where((post) => post.isHidden).toList();
      });
    } catch (_) {
      // keep empty list on error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadHiddenPosts();
  }

  void _handlePostUpdated() {
    _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidden Posts'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading && _hiddenPosts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: _hiddenPosts.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 120.h),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_off_outlined,
                                size: 64.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No hidden posts yet',
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
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8.w),
                      itemCount: _hiddenPosts.length,
                      itemBuilder: (context, index) {
                        final post = _hiddenPosts[index];
                        return PostItemWidget(
                          key: ValueKey('hidden_post_${post.id}'),
                          post: post,
                          index: index,
                          onPostUpdated: _handlePostUpdated,
                        );
                      },
                    ),
            ),
    );
  }
}


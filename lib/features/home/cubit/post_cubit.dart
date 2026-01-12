import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import '../data/repo/post_repository.dart';
import '../data/models/post_models.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository _repository;

  PostCubit(this._repository) : super(PostInitial());

  List<Post> _posts = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<Post> get posts => _posts;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _posts = [];
    }

    if (_currentPage == 1) {
      emit(PostLoading());
    }

    try {
      final response = await _repository.getPosts(page: _currentPage);
      final fetchedPosts = response.data;

      if (refresh || _currentPage == 1) {
        _posts = fetchedPosts.where((post) => !post.isHidden).toList();
      } else {
        _posts.addAll(fetchedPosts.where((post) => !post.isHidden));
      }

      _hasMore = response.meta?.hasMorePages ?? false;
      _currentPage++;

      emit(
        PostLoaded(_posts, hasMore: _hasMore, currentPage: _currentPage - 1),
      );
    } catch (e) {
      emit(PostError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMorePosts() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    emit(PostLoadingMore(_posts, _currentPage));

    try {
      final response = await _repository.getPosts(page: _currentPage);
      final fetchedPosts = response.data;
      _posts.addAll(fetchedPosts.where((post) => !post.isHidden));
      _hasMore = response.meta?.hasMorePages ?? false;
      _currentPage++;

      emit(
        PostLoaded(_posts, hasMore: _hasMore, currentPage: _currentPage - 1),
      );
    } catch (e) {
      emit(
        PostLoaded(_posts, hasMore: _hasMore, currentPage: _currentPage - 1),
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<int?> uploadMedia(File file) async {
    try {
      final response = await _repository.uploadMedia(file);
      return response.data?.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> createPost({
    String? content,
    File? imageFile,
    File? videoFile,
    List<File>? galleryFiles,
    required bool isAdRequest,
  }) async {
    emit(PostCreating());
    try {
      int? imageId;
      int? videoId;
      List<int> galleryIds = [];

      if (imageFile != null) {
        imageId = await uploadMedia(imageFile);
      }

      if (videoFile != null) {
        videoId = await uploadMedia(videoFile);
      }

      if (galleryFiles != null && galleryFiles.isNotEmpty) {
        for (var file in galleryFiles) {
          final id = await uploadMedia(file);
          if (id != null) {
            galleryIds.add(id);
          }
        }
      }

      if (imageId == null &&
          videoId == null &&
          galleryIds.isEmpty &&
          (content == null || content.isEmpty)) {
        emit(PostCreateError('Please add content, image, video, or gallery'));
        return;
      }

      final request = CreatePostRequest(
        content: content,
        image: imageId,
        video: videoId,
        gallery: galleryIds,
        isAdRequest: isAdRequest ? 1 : 0,
      );

      final response = await _repository.createPost(request);
      _posts.insert(0, response.data);
      emit(PostCreated(response.data));
      emit(PostLoaded(_posts, hasMore: _hasMore, currentPage: _currentPage));
    } catch (e) {
      emit(PostCreateError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void refreshPosts() {
    loadPosts(refresh: true);
  }
}

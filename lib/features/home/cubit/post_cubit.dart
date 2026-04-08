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
      _isLoadingMore = false;
      _posts.clear();
    }

    if (_currentPage == 1 && _posts.isEmpty) {
      emit(PostLoading());
    }

    try {
      final response = await _repository.getPosts(
        page: _currentPage,
        perPage: 20,
      );
      final fetchedPosts = response.data;

      if (refresh || _currentPage == 1) {
        _posts = fetchedPosts.where((post) => !post.isHidden).toList();
      } else {
        final existingIds = _posts.map((p) => p.id).toSet();
        final newPosts = fetchedPosts
            .where((post) => !post.isHidden && !existingIds.contains(post.id))
            .toList();
        _posts.addAll(newPosts);
      }

      final hasNextLink =
          response.links?.next != null && response.links!.next!.isNotEmpty;
      final hasMoreFromMeta = response.meta?.hasMorePages ?? false;
      _hasMore = hasNextLink || hasMoreFromMeta;

      if (fetchedPosts.isNotEmpty) {
        _currentPage++;
      }

      emit(
        PostLoaded(
          _posts,
          hasMore: _hasMore,
          currentPage:
              response.meta?.currentPage ??
              (_currentPage > 1 ? _currentPage - 1 : 1),
        ),
      );
    } catch (e) {
      if (_posts.isEmpty) {
        emit(PostError(e.toString().replaceFirst('Exception: ', '')));
      } else {
        emit(
          PostLoaded(
            _posts,
            hasMore: _hasMore,
            currentPage: _currentPage > 1 ? _currentPage - 1 : 1,
          ),
        );
      }
    }
  }

  Future<void> loadMorePosts() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    emit(PostLoadingMore(_posts, _currentPage));

    try {
      final response = await _repository.getPosts(
        page: _currentPage,
        perPage: 20,
      );
      final fetchedPosts = response.data;

      final existingIds = _posts.map((p) => p.id).toSet();
      final newPosts = fetchedPosts
          .where((post) => !post.isHidden && !existingIds.contains(post.id))
          .toList();

      _posts.addAll(newPosts);

      final hasNextLink =
          response.links?.next != null && response.links!.next!.isNotEmpty;
      final hasMoreFromMeta = response.meta?.hasMorePages ?? false;
      _hasMore = hasNextLink || hasMoreFromMeta;

      if (fetchedPosts.isNotEmpty) {
        _currentPage++;
      }

      emit(
        PostLoaded(
          _posts,
          hasMore: _hasMore,
          currentPage:
              response.meta?.currentPage ??
              (_currentPage > 1 ? _currentPage - 1 : 1),
        ),
      );
    } catch (e) {
      _hasMore = false;
      emit(
        PostLoaded(
          _posts,
          hasMore: false,
          currentPage: _currentPage > 1 ? _currentPage - 1 : 1,
        ),
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
        final uploadFutures = galleryFiles.map((file) => uploadMedia(file));
        final ids = await Future.wait(uploadFutures);
        galleryIds.addAll(ids.whereType<int>());
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

      if (!isAdRequest) {
        _posts.insert(0, response.data);
      }

      emit(PostCreated(response.data));

      if (!isAdRequest) {
        emit(PostLoaded(_posts, hasMore: _hasMore, currentPage: _currentPage));
      }
    } catch (e) {
      emit(PostCreateError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void refreshPosts() {
    loadPosts(refresh: true);
  }
}

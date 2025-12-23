import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import '../data/repo/post_repository.dart';
import '../data/models/post_models.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository _repository;

  PostCubit(this._repository) : super(PostInitial());

  List<Post> _posts = [];

  List<Post> get posts => _posts;

  Future<void> loadPosts() async {
    emit(PostLoading());
    try {
      final response = await _repository.getPosts();
      _posts = response.data;
      emit(PostLoaded(_posts));
    } catch (e) {
      emit(PostError(e.toString().replaceFirst('Exception: ', '')));
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

      if (imageId == null && videoId == null && galleryIds.isEmpty && (content == null || content.isEmpty)) {
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
      emit(PostLoaded(_posts));
    } catch (e) {
      emit(PostCreateError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void refreshPosts() {
    loadPosts();
  }
}


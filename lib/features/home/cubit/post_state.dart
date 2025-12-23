import '../data/models/post_models.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final bool hasMore;
  final int currentPage;

  PostLoaded(this.posts, {this.hasMore = false, this.currentPage = 1});
}

class PostLoadingMore extends PostState {
  final List<Post> posts;
  final int currentPage;

  PostLoadingMore(this.posts, this.currentPage);
}

class PostError extends PostState {
  final String message;

  PostError(this.message);
}

class PostCreating extends PostState {}

class PostCreated extends PostState {
  final Post post;

  PostCreated(this.post);
}

class PostCreateError extends PostState {
  final String message;

  PostCreateError(this.message);
}


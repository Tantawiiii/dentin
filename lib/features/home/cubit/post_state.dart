import '../data/models/post_models.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;

  PostLoaded(this.posts);
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


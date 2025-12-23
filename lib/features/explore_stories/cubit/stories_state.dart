import '../../home/data/models/post_models.dart';

abstract class StoriesState {}

class StoriesInitial extends StoriesState {}

class StoriesLoading extends StoriesState {}

class StoriesLoaded extends StoriesState {
  final List<Post> stories;

  StoriesLoaded(this.stories);
}

class StoriesError extends StoriesState {
  final String message;

  StoriesError(this.message);
}


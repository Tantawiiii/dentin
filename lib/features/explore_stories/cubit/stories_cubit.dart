import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repo/stories_repository.dart';
import '../../home/data/models/post_models.dart';
import 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final StoriesRepository _repository;

  StoriesCubit(this._repository) : super(StoriesInitial());

  List<Post> _stories = [];

  List<Post> get stories => _stories;

  Future<void> loadStories() async {
    emit(StoriesLoading());
    try {
      final response = await _repository.getStoriesWithVideo();
      _stories = response.data;
      emit(StoriesLoaded(_stories));
    } catch (e) {
      emit(StoriesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void refreshStories() {
    loadStories();
  }
}


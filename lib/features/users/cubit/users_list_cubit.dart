import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repo/users_repository.dart';
import '../data/models/users_list_response.dart';
import 'users_list_state.dart';

class UsersListCubit extends Cubit<UsersListState> {
  final UsersRepository _repository;

  UsersListCubit(this._repository) : super(UsersListInitial());

  Future<void> loadUsers({
    UsersListFilters? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    emit(UsersListLoading());

    try {
      final response = await _repository.getUsers(
        filters: filters ?? UsersListFilters(),
        page: page,
        perPage: perPage,
      );

      emit(UsersListLoaded(
        users: response.data,
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        totalUsers: response.meta.total,
        perPage: response.meta.perPage,
      ));
    } catch (e) {
      emit(UsersListError(e.toString()));
    }
  }

  Future<void> loadNextPage({
    UsersListFilters? filters,
    int perPage = 10,
  }) async {
    final currentState = state;
    if (currentState is UsersListLoaded) {
      if (currentState.currentPage < currentState.totalPages) {
        await loadUsers(
          filters: filters,
          page: currentState.currentPage + 1,
          perPage: perPage,
        );
      }
    }
  }
}


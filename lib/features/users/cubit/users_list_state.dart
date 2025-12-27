import '../../profile/data/models/profile_response.dart';

abstract class UsersListState {}

class UsersListInitial extends UsersListState {}

class UsersListLoading extends UsersListState {}

class UsersListLoaded extends UsersListState {
  final List<Doctor> users;
  final int currentPage;
  final int totalPages;
  final int totalUsers;
  final int perPage;

  UsersListLoaded({
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.totalUsers,
    required this.perPage,
  });
}

class UsersListError extends UsersListState {
  final String message;

  UsersListError(this.message);
}


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
  final bool isLoadingMore;

  UsersListLoaded({
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.totalUsers,
    required this.perPage,
    this.isLoadingMore = false,
  });

  UsersListLoaded copyWith({
    List<Doctor>? users,
    int? currentPage,
    int? totalPages,
    int? totalUsers,
    int? perPage,
    bool? isLoadingMore,
  }) {
    return UsersListLoaded(
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalUsers: totalUsers ?? this.totalUsers,
      perPage: perPage ?? this.perPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class UsersListError extends UsersListState {
  final String message;

  UsersListError(this.message);
}

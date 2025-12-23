import '../data/models/profile_response.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Doctor doctor;
  final int friendsCount;

  const ProfileLoaded(this.doctor, this.friendsCount);
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}



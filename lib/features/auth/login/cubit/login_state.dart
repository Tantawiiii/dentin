import '../data/models/login_response.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserData userData;

  LoginSuccess(this.userData);
}

class LoginError extends LoginState {
  final String message;

  LoginError(this.message);
}


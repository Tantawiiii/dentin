import '../../login/data/models/login_response.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {
  final String? message;

  RegisterLoading({this.message});
}

class RegisterUploadingFiles extends RegisterState {
  final String currentFile;
  final double progress;
  final int uploadedFiles;
  final int totalFiles;

  RegisterUploadingFiles({
    required this.currentFile,
    required this.progress,
    required this.uploadedFiles,
    required this.totalFiles,
  });
}

class RegisterSubmitting extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final UserData userData;
  final String token;

  RegisterSuccess({
    required this.userData,
    required this.token,
  });
}

class RegisterError extends RegisterState {
  final String message;

  RegisterError(this.message);
}


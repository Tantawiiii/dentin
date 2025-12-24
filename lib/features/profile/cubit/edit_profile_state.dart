import '../data/models/profile_response.dart';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileUploadingFiles extends EditProfileState {
  final String currentFile;
  final double progress;
  final int uploadedFiles;
  final int totalFiles;

  EditProfileUploadingFiles({
    required this.currentFile,
    required this.progress,
    required this.uploadedFiles,
    required this.totalFiles,
  });
}

class EditProfileSubmitting extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final Doctor doctor;

  EditProfileSuccess(this.doctor);
}

class EditProfileError extends EditProfileState {
  final String message;

  EditProfileError(this.message);
}


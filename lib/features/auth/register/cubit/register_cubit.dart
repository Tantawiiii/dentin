import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/available_times_widget.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/storage_service.dart';
import '../data/repo/register_repository.dart';
import '../data/models/register_request.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository _repository;
  final StorageService _storageService;
  final DioClient _dioClient;

  RegisterCubit({
    required RegisterRepository repository,
    required StorageService storageService,
    required DioClient dioClient,
  }) : _repository = repository,
       _storageService = storageService,
       _dioClient = dioClient,
       super(RegisterInitial());

  Future<void> register({
    required String email,
    required String password,
    required String userName,
    required String firstName,
    required String lastName,
    required String phone,
    required String birthDate,
    required int graduationYear,
    required String description,
    required String university,
    required String graduationGrade,
    required String postgraduateDegree,
    required String specialization,
    required int experienceYears,
    String? assistantUniversity,
    required int isWorkAssistantUniversity,
    String? tools,
    required int hasClinic,
    String? clinicName,
    String? clinicAddress,
    required String experience,
    required String whereDidYouWork,
    required String address,
    required List<AvailableTimeSlot> availableTimes,
    required List<String> skills,
    List<String>? fields,
    File? profileImage,
    File? cv,
    File? coverImage,
    File? graduationCertificate,
    List<File>? courseCertificates,
  }) async {
    try {
      // Step 1: Upload files first
      int? profileImageId;
      int? cvId;
      int? coverImageId;
      int? graduationCertificateId;
      List<int>? courseCertificateIds;

      final filesToUpload = <String, File>{};
      if (profileImage != null) filesToUpload['profile_image'] = profileImage;
      if (cv != null) filesToUpload['cv'] = cv;
      if (coverImage != null) filesToUpload['cover_image'] = coverImage;
      if (graduationCertificate != null) {
        filesToUpload['graduation_certificate'] = graduationCertificate;
      }
      if (courseCertificates != null && courseCertificates.isNotEmpty) {
        for (int i = 0; i < courseCertificates.length; i++) {
          filesToUpload['course_certificate_$i'] = courseCertificates[i];
        }
      }

      final totalFiles = filesToUpload.length;
      int uploadedFiles = 0;

      if (totalFiles > 0) {
        emit(
          RegisterUploadingFiles(
            currentFile: 'Preparing files...',
            progress: 0.0,
            uploadedFiles: 0,
            totalFiles: totalFiles,
          ),
        );

        for (final entry in filesToUpload.entries) {
          final fileName = entry.key;
          final file = entry.value;

          emit(
            RegisterUploadingFiles(
              currentFile: 'Uploading $fileName...',
              progress: uploadedFiles / totalFiles,
              uploadedFiles: uploadedFiles,
              totalFiles: totalFiles,
            ),
          );

          final uploadResponse = await _repository.uploadMedia(
            file,
            onSendProgress: (sent, total) {
              final fileProgress = sent / total;
              final overallProgress =
                  (uploadedFiles + fileProgress) / totalFiles;
              emit(
                RegisterUploadingFiles(
                  currentFile: 'Uploading $fileName...',
                  progress: overallProgress,
                  uploadedFiles: uploadedFiles,
                  totalFiles: totalFiles,
                ),
              );
            },
          );

          if (uploadResponse.data != null) {
            final fileId = uploadResponse.data!.id;

            switch (fileName) {
              case 'profile_image':
                profileImageId = fileId;
                break;
              case 'cv':
                cvId = fileId;
                break;
              case 'cover_image':
                coverImageId = fileId;
                break;
              case 'graduation_certificate':
                graduationCertificateId = fileId;
                break;
              default:
                if (fileName.startsWith('course_certificate_')) {
                  courseCertificateIds ??= [];
                  courseCertificateIds.add(fileId);
                }
                break;
            }
          }

          uploadedFiles++;
        }

        emit(
          RegisterUploadingFiles(
            currentFile: 'All files uploaded',
            progress: 1.0,
            uploadedFiles: totalFiles,
            totalFiles: totalFiles,
          ),
        );
      }

      // Step 2: Submit registration
      emit(RegisterSubmitting());

      final request = RegisterRequest(
        email: email,
        password: password,
        userName: userName,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        birthDate: birthDate,
        graduationYear: graduationYear,
        description: description,
        university: university,
        graduationGrade: graduationGrade,
        postgraduateDegree: postgraduateDegree,
        specialization: specialization,
        experienceYears: experienceYears,
        assistantUniversity: assistantUniversity,
        isWorkAssistantUniversity: isWorkAssistantUniversity,
        tools: tools,
        hasClinic: hasClinic,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        experience: experience,
        whereDidYouWork: whereDidYouWork,
        address: address,
        availableTimes: availableTimes,
        skills: skills,
        fields: fields,
        profileImage: profileImageId,
        cv: cvId,
        coverImage: coverImageId,
        graduationCertificateImage: graduationCertificateId,
        courseCertificatesImage: courseCertificateIds,
      );

      final response = await _repository.register(request);

      if (response.status == 200 &&
          response.data != null &&
          response.data!.doctor != null &&
          response.data!.token != null) {
        await _storageService.saveToken(response.data!.token!);
        await _storageService.saveUserData(response.data!.doctor!);

        _dioClient.setAuthToken(response.data!.token!);

        emit(
          RegisterSuccess(
            userData: response.data!.doctor!,
            token: response.data!.token!,
          ),
        );
      } else {
        // Try to extract error message from response
        String errorMessage = 'Registration failed. Please try again.';
        if (response.message is String) {
          errorMessage = response.message as String;
        } else if (response.message is Map) {
          final messageMap = response.message as Map;
          if (messageMap['message'] is String) {
            errorMessage = messageMap['message'] as String;
          }
        }
        emit(RegisterError(errorMessage));
      }
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e is Exception) {
        final exceptionString = e.toString();
        errorMessage = exceptionString
            .replaceFirst(RegExp(r'^Exception:\s*'), '')
            .trim();
        if (errorMessage.isEmpty) {
          errorMessage = 'An error occurred. Please try again.';
        }
      } else {
        errorMessage = e.toString();
      }
      emit(RegisterError(errorMessage));
    }
  }
}

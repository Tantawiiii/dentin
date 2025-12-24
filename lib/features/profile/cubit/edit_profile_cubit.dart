import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/storage_service.dart';
import '../data/repo/profile_repository.dart';
import '../data/models/update_profile_request.dart';
import '../../auth/register/widgets/available_times_widget.dart';
import '../../auth/register/data/repo/register_repository.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final ProfileRepository _profileRepository;
  final RegisterRepository _registerRepository;

  EditProfileCubit({
    required ProfileRepository profileRepository,
    required RegisterRepository registerRepository,
    required StorageService storageService,
    required DioClient dioClient,
  })  : _profileRepository = profileRepository,
        _registerRepository = registerRepository,
        super(EditProfileInitial());

  Future<void> updateProfile({
    required int userId,
    String? email,
    String? password,
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
          EditProfileUploadingFiles(
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
            EditProfileUploadingFiles(
              currentFile: 'Uploading $fileName...',
              progress: uploadedFiles / totalFiles,
              uploadedFiles: uploadedFiles,
              totalFiles: totalFiles,
            ),
          );

          final uploadResponse = await _registerRepository.uploadMedia(
            file,
            onSendProgress: (sent, total) {
              final fileProgress = sent / total;
              final overallProgress =
                  (uploadedFiles + fileProgress) / totalFiles;
              emit(
                EditProfileUploadingFiles(
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
          EditProfileUploadingFiles(
            currentFile: 'All files uploaded',
            progress: 1.0,
            uploadedFiles: totalFiles,
            totalFiles: totalFiles,
          ),
        );
      }

      // Step 2: Submit update
      emit(EditProfileSubmitting());

      String mappedPostgraduateDegree = postgraduateDegree;
      if (mappedPostgraduateDegree.isNotEmpty) {
        switch (mappedPostgraduateDegree.toLowerCase()) {
          case 'bachelor\'s degree':
          case 'bachelor degree':
            mappedPostgraduateDegree = 'bachelor';
            break;
          case 'master\'s degree':
          case 'master degree':
            mappedPostgraduateDegree = 'master';
            break;
          case 'phd':
            mappedPostgraduateDegree = 'phd';
            break;
          case 'diploma':
            mappedPostgraduateDegree = 'diploma';
            break;
          case 'certificate':
            mappedPostgraduateDegree = 'certificate';
            break;
          default:
            break;
        }
      }

      String mappedGraduationGrade = graduationGrade;
      if (mappedGraduationGrade.isNotEmpty) {
        switch (mappedGraduationGrade.toLowerCase()) {
          case 'excellent':
            mappedGraduationGrade = 'excellent';
            break;
          case 'very good':
            mappedGraduationGrade = 'very_good';
            break;
          case 'good':
            mappedGraduationGrade = 'good';
            break;
          case 'pass':
            mappedGraduationGrade = 'pass';
            break;
          default:
            break;
        }
      }

      final request = UpdateProfileRequest(
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
        graduationGrade: mappedGraduationGrade,
        postgraduateDegree: mappedPostgraduateDegree,
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

      final updatedDoctor = await _profileRepository.updateProfile(userId, request);

      // Note: User data will be reloaded when profile screen refreshes
      // We don't update storage here as it expects UserData, not Doctor

      emit(EditProfileSuccess(updatedDoctor));
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
      emit(EditProfileError(errorMessage));
    }
  }
}


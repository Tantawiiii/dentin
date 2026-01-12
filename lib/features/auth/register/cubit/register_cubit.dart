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

  // Cached uploaded file IDs to avoid re-uploading on retry
  int? _cachedProfileImageId;
  int? _cachedCvId;
  int? _cachedCoverImageId;
  int? _cachedGraduationCertificateId;
  List<int>? _cachedCourseCertificateIds;

  // Track which files were uploaded to avoid re-uploading if files haven't changed
  File? _lastProfileImage;
  File? _lastCv;
  File? _lastCoverImage;
  File? _lastGraduationCertificate;
  List<File>? _lastCourseCertificates;

  RegisterCubit({
    required RegisterRepository repository,
    required StorageService storageService,
    required DioClient dioClient,
  }) : _repository = repository,
       _storageService = storageService,
       _dioClient = dioClient,
       super(RegisterInitial());

  // Helper method to check if two file lists are equal
  bool _areListsEqual(List<File>? list1, List<File>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].path != list2[i].path) return false;
    }
    return true;
  }

  // Clear cached file IDs (called on success)
  void _clearCachedFiles() {
    _cachedProfileImageId = null;
    _cachedCvId = null;
    _cachedCoverImageId = null;
    _cachedGraduationCertificateId = null;
    _cachedCourseCertificateIds = null;
    _lastProfileImage = null;
    _lastCv = null;
    _lastCoverImage = null;
    _lastGraduationCertificate = null;
    _lastCourseCertificates = null;
  }

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
      // Step 1: Upload files first (only if files changed or not uploaded before)
      int? profileImageId;
      int? cvId;
      int? coverImageId;
      int? graduationCertificateId;
      List<int>? courseCertificateIds;

      // Check if files changed (compare paths, not objects)
      final profileImageChanged = profileImage?.path != _lastProfileImage?.path;
      final cvChanged = cv?.path != _lastCv?.path;
      final coverImageChanged = coverImage?.path != _lastCoverImage?.path;
      final graduationCertificateChanged =
          graduationCertificate?.path != _lastGraduationCertificate?.path;
      final courseCertificatesChanged = !_areListsEqual(
        courseCertificates,
        _lastCourseCertificates,
      );

      // Use cached IDs if files haven't changed, otherwise upload new files
      if (profileImage != null) {
        if (!profileImageChanged && _cachedProfileImageId != null) {
          profileImageId = _cachedProfileImageId;
        } else {
          profileImageId = null; // Will be uploaded
        }
      }

      if (cv != null) {
        if (!cvChanged && _cachedCvId != null) {
          cvId = _cachedCvId;
        } else {
          cvId = null; // Will be uploaded
        }
      }

      if (coverImage != null) {
        if (!coverImageChanged && _cachedCoverImageId != null) {
          coverImageId = _cachedCoverImageId;
        } else {
          coverImageId = null; // Will be uploaded
        }
      }

      if (graduationCertificate != null) {
        if (!graduationCertificateChanged &&
            _cachedGraduationCertificateId != null) {
          graduationCertificateId = _cachedGraduationCertificateId;
        } else {
          graduationCertificateId = null; // Will be uploaded
        }
      }

      if (courseCertificates != null && courseCertificates.isNotEmpty) {
        if (!courseCertificatesChanged &&
            _cachedCourseCertificateIds != null &&
            _cachedCourseCertificateIds!.isNotEmpty) {
          courseCertificateIds = List.from(_cachedCourseCertificateIds!);
        } else {
          courseCertificateIds = null; // Will be uploaded
        }
      }

      // Prepare files to upload (only new or changed files)
      final filesToUpload = <String, File>{};
      if (profileImage != null && profileImageId == null) {
        filesToUpload['profile_image'] = profileImage;
      }
      if (cv != null && cvId == null) {
        filesToUpload['cv'] = cv;
      }
      if (coverImage != null && coverImageId == null) {
        filesToUpload['cover_image'] = coverImage;
      }
      if (graduationCertificate != null && graduationCertificateId == null) {
        filesToUpload['graduation_certificate'] = graduationCertificate;
      }
      if (courseCertificates != null &&
          courseCertificates.isNotEmpty &&
          courseCertificateIds == null) {
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
                _cachedProfileImageId = fileId;
                _lastProfileImage = profileImage;
                break;
              case 'cv':
                cvId = fileId;
                _cachedCvId = fileId;
                _lastCv = cv;
                break;
              case 'cover_image':
                coverImageId = fileId;
                _cachedCoverImageId = fileId;
                _lastCoverImage = coverImage;
                break;
              case 'graduation_certificate':
                graduationCertificateId = fileId;
                _cachedGraduationCertificateId = fileId;
                _lastGraduationCertificate = graduationCertificate;
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

        // Cache course certificates IDs if uploaded
        if (courseCertificates != null &&
            courseCertificates.isNotEmpty &&
            courseCertificateIds != null) {
          _cachedCourseCertificateIds = List.from(courseCertificateIds);
          _lastCourseCertificates = List.from(courseCertificates);
        }

        emit(
          RegisterUploadingFiles(
            currentFile: 'All files uploaded',
            progress: 1.0,
            uploadedFiles: totalFiles,
            totalFiles: totalFiles,
          ),
        );
      } else {
        // If no files to upload, use cached IDs and update last files
        profileImageId = _cachedProfileImageId;
        cvId = _cachedCvId;
        coverImageId = _cachedCoverImageId;
        graduationCertificateId = _cachedGraduationCertificateId;
        courseCertificateIds = _cachedCourseCertificateIds != null
            ? List.from(_cachedCourseCertificateIds!)
            : null;

        // Update last files even when using cached IDs
        if (profileImage != null) _lastProfileImage = profileImage;
        if (cv != null) _lastCv = cv;
        if (coverImage != null) _lastCoverImage = coverImage;
        if (graduationCertificate != null) {
          _lastGraduationCertificate = graduationCertificate;
        }
        if (courseCertificates != null && courseCertificates.isNotEmpty) {
          _lastCourseCertificates = List.from(courseCertificates);
        }
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

        // Clear cached files on success
        _clearCachedFiles();

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

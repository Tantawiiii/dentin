import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/services/storage_service.dart';
import '../data/repo/login_repository.dart';
import '../data/models/login_request.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository _repository;
  final StorageService _storageService;
  final DioClient _dioClient;
  final FCMService _fcmService;

  LoginCubit({
    required LoginRepository repository,
    required StorageService storageService,
    required DioClient dioClient,
    required FCMService fcmService,
  }) : _repository = repository,
       _storageService = storageService,
       _dioClient = dioClient,
       _fcmService = fcmService,
       super(LoginInitial());

  Future<void> login(String emailOrPhone, String password) async {
    emit(LoginLoading());

    try {
      final request = LoginRequest(
        emailOrPhone: emailOrPhone.trim(),
        password: password,
      );

      final response = await _repository.login(request);

      if (response.status && response.data != null && response.token != null) {
        await _storageService.saveToken(response.token!);
        await _storageService.saveUserData(response.data!);
        _dioClient.setAuthToken(response.token!);

        // Persist the FCM token under this user's ID so the backend / Cloud
        // Functions can look it up when sending push notifications.
        _fcmService.saveTokenForUser(response.data!.id).ignore();

        emit(LoginSuccess(response.data!));
      } else {
        emit(LoginError(response.message));
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
      emit(LoginError(errorMessage));
    }
  }

  void reset() {
    emit(LoginInitial());
  }
}

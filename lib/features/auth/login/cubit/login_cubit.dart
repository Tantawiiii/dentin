import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/storage_service.dart';
import '../data/repo/login_repository.dart';
import '../data/models/login_request.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository _repository;
  final StorageService _storageService;
  final DioClient _dioClient;

  LoginCubit({
    required LoginRepository repository,
    required StorageService storageService,
    required DioClient dioClient,
  }) : _repository = repository,
       _storageService = storageService,
       _dioClient = dioClient,
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
        // Save token
        await _storageService.saveToken(response.token!);

        // Save user data
        await _storageService.saveUserData(response.data!);

        // Set auth token in Dio client
        _dioClient.setAuthToken(response.token!);

        emit(LoginSuccess(response.data!));
      } else {
        emit(LoginError(response.message));
      }
    } catch (e) {
      emit(LoginError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void reset() {
    emit(LoginInitial());
  }
}

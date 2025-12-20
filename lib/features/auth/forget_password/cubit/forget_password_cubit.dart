import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repo/forget_password_repository.dart';
import '../data/models/send_otp_request.dart';
import '../data/models/verify_otp_request.dart';
import '../data/models/reset_password_request.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ForgetPasswordRepository _repository;

  ForgetPasswordCubit({
    required ForgetPasswordRepository repository,
  })  : _repository = repository,
        super(ForgetPasswordInitial());

  Future<void> sendOtp(String email) async {
    emit(ForgetPasswordLoading());

    try {
      final request = SendOtpRequest(email: email.trim());
      final response = await _repository.sendOtp(request);
      emit(SendOtpSuccess(response.message));
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
      emit(SendOtpError(errorMessage));
    }
  }

  Future<void> verifyOtp(String email, int otp) async {
    emit(VerifyOtpLoading());

    try {
      final request = VerifyOtpRequest(email: email.trim(), otp: otp);
      final response = await _repository.verifyOtp(request);
      
      if (response.success) {
        emit(VerifyOtpSuccess(response.message));
      } else {
        emit(VerifyOtpError(response.message));
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
      emit(VerifyOtpError(errorMessage));
    }
  }

  Future<void> resetPassword(
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    emit(ResetPasswordLoading());

    try {
      final request = ResetPasswordRequest(
        email: email.trim(),
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final response = await _repository.resetPassword(request);
      emit(ResetPasswordSuccess(response.message));
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
      emit(ResetPasswordError(errorMessage));
    }
  }
}


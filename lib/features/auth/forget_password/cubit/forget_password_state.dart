abstract class ForgetPasswordState {
  const ForgetPasswordState();
}

class ForgetPasswordInitial extends ForgetPasswordState {}

class ForgetPasswordLoading extends ForgetPasswordState {}

class SendOtpSuccess extends ForgetPasswordState {
  final String message;

  const SendOtpSuccess(this.message);
}

class SendOtpError extends ForgetPasswordState {
  final String message;

  const SendOtpError(this.message);
}

class VerifyOtpLoading extends ForgetPasswordState {}

class VerifyOtpSuccess extends ForgetPasswordState {
  final String message;

  const VerifyOtpSuccess(this.message);
}

class VerifyOtpError extends ForgetPasswordState {
  final String message;

  const VerifyOtpError(this.message);
}

class ResetPasswordLoading extends ForgetPasswordState {}

class ResetPasswordSuccess extends ForgetPasswordState {
  final String message;

  const ResetPasswordSuccess(this.message);
}

class ResetPasswordError extends ForgetPasswordState {
  final String message;

  const ResetPasswordError(this.message);
}


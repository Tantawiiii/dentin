class VerifyOtpRequest {
  final String email;
  final int otp;

  VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}


class VerifyOtpResponse {
  final String message;
  final bool success;

  VerifyOtpResponse({required this.message, required this.success});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] ?? '',
      success: json['message'] != 'Invalid OTP',
    );
  }
}


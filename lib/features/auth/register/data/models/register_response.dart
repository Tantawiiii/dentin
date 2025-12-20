import '../../../login/data/models/login_response.dart';

class RegisterResponse {
  final String result;
  final RegisterData? data;
  final dynamic message;
  final int status;

  RegisterResponse({
    required this.result,
    this.data,
    this.message,
    required this.status,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    // Handle case where data is in message field instead of data field
    RegisterData? registerData;
    if (json['data'] != null) {
      registerData = RegisterData.fromJson(json['data']);
    } else if (json['message'] != null && json['message'] is Map) {
      // If data is null but message is a Map, try to parse it as RegisterData
      registerData = RegisterData.fromJson(json['message'] as Map<String, dynamic>);
    }
    
    return RegisterResponse(
      result: json['result'] ?? '',
      data: registerData,
      message: json['message'],
      status: json['status'] ?? 0,
    );
  }
}

class RegisterData {
  final String? message;
  final UserData? doctor;
  final String? token;

  RegisterData({
    this.message,
    this.doctor,
    this.token,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      message: json['message'],
      doctor: json['doctor'] != null ? UserData.fromJson(json['doctor']) : null,
      token: json['token'],
    );
  }
}

class RegisterErrorResponse {
  final String message;
  final Map<String, List<String>>? errors;

  RegisterErrorResponse({
    required this.message,
    this.errors,
  });

  factory RegisterErrorResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? errorsMap;
    if (json['errors'] != null && json['errors'] is Map) {
      errorsMap = {};
      (json['errors'] as Map).forEach((key, value) {
        if (value is List) {
          errorsMap![key.toString()] = List<String>.from(value);
        } else {
          errorsMap![key.toString()] = [value.toString()];
        }
      });
    }

    return RegisterErrorResponse(
      message: json['message'] ?? 'Registration failed',
      errors: errorsMap,
    );
  }

  String getFormattedErrors() {
    if (errors == null || errors!.isEmpty) {
      return message;
    }

    final errorMessages = <String>[];
    errors!.forEach((field, messages) {
      for (final msg in messages) {
        errorMessages.add('${_formatFieldName(field)}: $msg');
      }
    });

    return errorMessages.join('\n');
  }

  String _formatFieldName(String field) {

    return field
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}


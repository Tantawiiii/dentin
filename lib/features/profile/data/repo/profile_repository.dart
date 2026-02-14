import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';

class ProfileData {
  final Doctor doctor;
  final int friendsCount;

  ProfileData({
    required this.doctor,
    required this.friendsCount,
  });
}

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  Future<ProfileData> getProfile() async {
    final Response<dynamic> response =
        await _apiService.get(ApiConstants.checkAuth);

    final data = response.data as Map<String, dynamic>;
    final profileResponse = ProfileResponse.fromJson(data);

    return ProfileData(
      doctor: profileResponse.message.doctor,
      friendsCount: profileResponse.message.friendsCount,
    );
  }

  Future<Doctor> updateProfile(int userId, UpdateProfileRequest request) async {
    final Response<dynamic> response = await _apiService.patch(
      ApiConstants.updateUser(userId),
      data: request.toJson(),
    );

    final data = response.data as Map<String, dynamic>;
    
    // Parse the response structure
    if (data['status'] == 200 && data['message'] != null) {
      final message = data['message'] as Map<String, dynamic>;
      if (message['data'] != null) {
        return Doctor.fromJson(message['data'] as Map<String, dynamic>);
      }
    }
    
    throw Exception('Failed to update profile');
  }

  Future<bool> togglePhoneVisibility(int userId, int isPhoneHidden) async {
    final Response<dynamic> response = await _apiService.put(
      ApiConstants.togglePhoneVisibility(userId),
      data: {'is_phone_hidden': isPhoneHidden},
    );

    // Check HTTP status code instead of response body status
    if (response.statusCode == 200) {
      return true;
    }
    
    throw Exception('Failed to toggle phone visibility');
  }
}



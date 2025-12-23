import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/profile_response.dart';

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
}



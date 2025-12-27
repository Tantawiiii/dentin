import 'package:dio/dio.dart';

import '../../../../core/network/api_service.dart';
import '../../../profile/data/models/profile_response.dart';
import '../models/users_list_response.dart';

class UsersRepository {
  final ApiService _apiService;

  UsersRepository(this._apiService);

  Future<UsersListResponse> getUsers({
    required UsersListFilters filters,
    required int page,
    required int perPage,
  }) async {
    final payload = {
      'filters': filters.toJson(),
      'orderBy': 'id',
      'orderByDirection': 'asc',
      'perPage': perPage,
      'paginate': true,
      'page': page,
    };

    final Response<dynamic> response = await _apiService.post(
      '/api/user/index-public',
      data: payload,
    );

    final data = response.data as Map<String, dynamic>;
    return UsersListResponse.fromJson(data);
  }

  Future<Doctor> getUserProfile(int userId) async {
    final Response<dynamic> response = await _apiService.get(
      '/api/user/$userId',
    );

    final data = response.data as Map<String, dynamic>;
    
    if (data['data'] != null) {
      return Doctor.fromJson(data['data'] as Map<String, dynamic>);
    }
    
    throw Exception('Failed to load user profile');
  }
}


import '../../../profile/data/models/profile_response.dart';

class UsersListResponse {
  final String result;
  final List<Doctor> data;
  final UsersListMeta meta;

  UsersListResponse({
    required this.result,
    required this.data,
    required this.meta,
  });

  factory UsersListResponse.fromJson(Map<String, dynamic> json) {
    return UsersListResponse(
      result: json['result'] as String? ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: UsersListMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class UsersListMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  UsersListMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory UsersListMeta.fromJson(Map<String, dynamic> json) {
    return UsersListMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }
}

class UsersListFilters {
  final String? userName;
  final String? email;
  final String? phone;
  final String? graduationYear;
  final String? graduationGrade;
  final String? postgraduateDegree;
  final int? experienceYears;

  UsersListFilters({
    this.userName,
    this.email,
    this.phone,
    this.graduationYear,
    this.graduationGrade,
    this.postgraduateDegree,
    this.experienceYears,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (userName != null && userName!.isNotEmpty) {
      json['user_name'] = userName;
    }
    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }
    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }
    if (graduationYear != null && graduationYear!.isNotEmpty) {
      json['graduation_year'] = graduationYear;
    }
    if (graduationGrade != null && graduationGrade!.isNotEmpty) {
      json['graduation_grade'] = graduationGrade;
    }
    if (postgraduateDegree != null && postgraduateDegree!.isNotEmpty) {
      json['postgraduate_degree'] = postgraduateDegree;
    }
    if (experienceYears != null) {
      json['experience_years'] = experienceYears;
    }
    return json;
  }

  UsersListFilters copyWith({
    String? userName,
    String? email,
    String? phone,
    String? graduationYear,
    String? graduationGrade,
    String? postgraduateDegree,
    int? experienceYears,
  }) {
    return UsersListFilters(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      graduationYear: graduationYear ?? this.graduationYear,
      graduationGrade: graduationGrade ?? this.graduationGrade,
      postgraduateDegree: postgraduateDegree ?? this.postgraduateDegree,
      experienceYears: experienceYears ?? this.experienceYears,
    );
  }
}


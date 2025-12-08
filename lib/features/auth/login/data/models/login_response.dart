class LoginResponse {
  final String result;
  final UserData? data;
  final String message;
  final bool status;
  final String? token;

  LoginResponse({
    required this.result,
    this.data,
    required this.message,
    required this.status,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      result: json['result'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      token: json['token'],
    );
  }
}

class UserData {
  final int id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? birthDate;
  final String? graduationYear;
  final String? university;
  final String? graduationGrade;
  final String? postgraduateDegree;
  final String? specialization;
  final int? experienceYears;
  final String? description;
  final String? experience;
  final String? whereDidYouWork;
  final String? address;
  final List<AvailableTime>? availableTimes;
  final List<String>? skills;
  final List<String>? fields;
  final String? profileImage;
  final String? coverImage;
  final String? graduationCertificateImage;
  final String? cv;
  final List<CourseCertificate>? courseCertificatesImage;
  final bool? isWorkAssistantUniversity;
  final String? assistantUniversity;
  final String? tools;
  final bool? active;
  final bool? hasClinic;
  final String? clinicName;
  final String? clinicAddress;
  final String? createdAt;
  final String? updatedAt;

  UserData({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.birthDate,
    this.graduationYear,
    this.university,
    this.graduationGrade,
    this.postgraduateDegree,
    this.specialization,
    this.experienceYears,
    this.description,
    this.experience,
    this.whereDidYouWork,
    this.address,
    this.availableTimes,
    this.skills,
    this.fields,
    this.profileImage,
    this.coverImage,
    this.graduationCertificateImage,
    this.cv,
    this.courseCertificatesImage,
    this.isWorkAssistantUniversity,
    this.assistantUniversity,
    this.tools,
    this.active,
    this.hasClinic,
    this.clinicName,
    this.clinicAddress,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      birthDate: json['birth_date'],
      graduationYear: json['graduation_year'],
      university: json['university'],
      graduationGrade: json['graduation_grade'],
      postgraduateDegree: json['postgraduate_degree'],
      specialization: json['specialization'],
      experienceYears: json['experience_years'],
      description: json['description'],
      experience: json['experience'],
      whereDidYouWork: json['where_did_you_work'],
      address: json['address'],
      availableTimes: json['available_times'] != null
          ? (json['available_times'] as List)
              .map((e) => AvailableTime.fromJson(e))
              .toList()
          : null,
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      fields: json['fields'] != null ? List<String>.from(json['fields']) : null,
      profileImage: json['profile_image'],
      coverImage: json['cover_image'],
      graduationCertificateImage: json['graduation_certificate_image'],
      cv: json['cv'],
      courseCertificatesImage: json['course_certificates_image'] != null
          ? (json['course_certificates_image'] as List)
              .map((e) => CourseCertificate.fromJson(e))
              .toList()
          : null,
      isWorkAssistantUniversity: json['is_work_assistant_university'],
      assistantUniversity: json['assistant_university'],
      tools: json['tools'],
      active: json['active'],
      hasClinic: json['has_clinic'],
      clinicName: json['clinic_name'],
      clinicAddress: json['clinic_address'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'birth_date': birthDate,
      'graduation_year': graduationYear,
      'university': university,
      'graduation_grade': graduationGrade,
      'postgraduate_degree': postgraduateDegree,
      'specialization': specialization,
      'experience_years': experienceYears,
      'description': description,
      'experience': experience,
      'where_did_you_work': whereDidYouWork,
      'address': address,
      'available_times': availableTimes?.map((e) => e.toJson()).toList(),
      'skills': skills,
      'fields': fields,
      'profile_image': profileImage,
      'cover_image': coverImage,
      'graduation_certificate_image': graduationCertificateImage,
      'cv': cv,
      'course_certificates_image':
          courseCertificatesImage?.map((e) => e.toJson()).toList(),
      'is_work_assistant_university': isWorkAssistantUniversity,
      'assistant_university': assistantUniversity,
      'tools': tools,
      'active': active,
      'has_clinic': hasClinic,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class AvailableTime {
  final String day;
  final String from;
  final String to;

  AvailableTime({
    required this.day,
    required this.from,
    required this.to,
  });

  factory AvailableTime.fromJson(Map<String, dynamic> json) {
    return AvailableTime(
      day: json['day'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'from': from,
      'to': to,
    };
  }
}

class CourseCertificate {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  CourseCertificate({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory CourseCertificate.fromJson(Map<String, dynamic> json) {
    return CourseCertificate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
      authorId: json['authorId'],
      previewUrl: json['previewUrl'] ?? '',
      fullUrl: json['fullUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mimeType': mimeType,
      'size': size,
      'authorId': authorId,
      'previewUrl': previewUrl,
      'fullUrl': fullUrl,
      'createdAt': createdAt,
    };
  }
}


class ProfileResponse {
  final String result;
  final ProfileMessage message;
  final int status;

  ProfileResponse({
    required this.result,
    required this.message,
    required this.status,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      result: json['result'] as String? ?? '',
      message: ProfileMessage.fromJson(json['message'] as Map<String, dynamic>),
      status: json['status'] as int? ?? 0,
    );
  }
}

class ProfileMessage {
  final String message;
  final Doctor doctor;
  final int friendsCount;

  ProfileMessage({
    required this.message,
    required this.doctor,
    required this.friendsCount,
  });

  factory ProfileMessage.fromJson(Map<String, dynamic> json) {
    return ProfileMessage(
      message: json['message'] as String? ?? '',
      doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      friendsCount: json['friends_count'] as int? ?? 0,
    );
  }
}

class Doctor {
  final int id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? birthDate;
  final String? description;
  final String? address;
  final String? university;
  final String? graduationYear;
  final String? graduationGrade;
  final String? postgraduateDegree;
  final String? specialization;
  final int? experienceYears;
  final String? experience;
  final String? whereDidYouWork;
  final List<String> availableTimes;
  final List<String> skills;
  final List<Field> fields;
  final String? profileImage;
  final String? coverImage;
  final List<ProfilePost> posts;
  final String? graduationCertificateImage;
  final String? cv;
  final List<CourseCertificate> courseCertificates;
  final String? createdAt;
  final bool? isWorkAssistantUniversity;
  final String? assistantUniversity;
  final String? tools;
  final bool? hasClinic;
  final String? clinicName;
  final String? clinicAddress;

  Doctor({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.birthDate,
    this.description,
    this.address,
    this.university,
    this.graduationYear,
    this.graduationGrade,
    this.postgraduateDegree,
    this.specialization,
    this.experienceYears,
    this.experience,
    this.whereDidYouWork,
    required this.availableTimes,
    required this.skills,
    required this.fields,
    this.profileImage,
    this.coverImage,
    required this.posts,
    this.graduationCertificateImage,
    this.cv,
    required this.courseCertificates,
    this.createdAt,
    this.isWorkAssistantUniversity,
    this.assistantUniversity,
    this.tools,
    this.hasClinic,
    this.clinicName,
    this.clinicAddress,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as int,
      userName: json['user_name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      birthDate: json['birth_date'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      university: json['university'] as String?,
      graduationYear: json['graduation_year'] as String?,
      graduationGrade: json['graduation_grade'] as String?,
      postgraduateDegree: json['postgraduate_degree'] as String?,
      specialization: json['specialization'] as String?,
      experienceYears: json['experience_years'] as int?,
      experience: json['experience'] as String?,
      whereDidYouWork: json['where_did_you_work'] as String?,
      availableTimes: (json['available_times'] as List<dynamic>? ?? [])
          .map((e) {
            if (e is Map) {
              return '${e['day'] ?? ''}|${e['from'] ?? ''}|${e['to'] ?? ''}';
            }
            return e.toString();
          })
          .toList(),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      fields: (json['fields'] as List<dynamic>? ?? [])
          .map((e) => Field.fromJson(e as Map<String, dynamic>))
          .toList(),
      profileImage: json['profile_image'] as String?,
      coverImage: json['cover_image'] as String?,
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((e) => ProfilePost.fromJson(e as Map<String, dynamic>))
          .toList(),
      graduationCertificateImage:
          json['graduation_certificate_image'] as String?,
      cv: json['cv'] as String?,
      courseCertificates:
          (json['course_certificates_image'] as List<dynamic>? ?? [])
              .map((e) => CourseCertificate.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: json['created_at'] as String?,
      isWorkAssistantUniversity: json['is_work_assistant_university'] as bool?,
      assistantUniversity: json['assistant_university'] as String?,
      tools: json['tools'] as String?,
      hasClinic: json['has_clinic'] as bool?,
      clinicName: json['clinic_name'] as String?,
      clinicAddress: json['clinic_address'] as String?,
    );
  }
}

class Field {
  final int id;
  final String name;

  Field({required this.id, required this.name});

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(id: json['id'] as int, name: json['name'] as String? ?? '');
  }
}

class ProfilePost {
  final int id;
  final String? content;
  final String? image;
  final List<ProfilePostGallery> gallery;
  final bool isAdRequest;
  final int likesCount;
  final String? createdAt;

  ProfilePost({
    required this.id,
    this.content,
    this.image,
    required this.gallery,
    required this.isAdRequest,
    required this.likesCount,
    this.createdAt,
  });

  factory ProfilePost.fromJson(Map<String, dynamic> json) {
    return ProfilePost(
      id: json['id'] as int,
      content: json['content'] as String?,
      image: json['image'] as String?,
      gallery: (json['gallery'] as List<dynamic>? ?? [])
          .map((e) => ProfilePostGallery.fromJson(e as Map<String, dynamic>))
          .toList(),
      isAdRequest: json['is_ad_request'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
    );
  }
}

class ProfilePostGallery {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  ProfilePostGallery({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory ProfilePostGallery.fromJson(Map<String, dynamic> json) {
    return ProfilePostGallery(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      authorId: json['authorId'] as int?,
      previewUrl: json['previewUrl'] as String? ?? '',
      fullUrl: json['fullUrl'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class CourseCertificate {
  final int id;
  final String name;
  final String fullUrl;
  final String? createdAt;

  CourseCertificate({
    required this.id,
    required this.name,
    required this.fullUrl,
    this.createdAt,
  });

  factory CourseCertificate.fromJson(Map<String, dynamic> json) {
    return CourseCertificate(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      fullUrl: json['fullUrl'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );
  }
}

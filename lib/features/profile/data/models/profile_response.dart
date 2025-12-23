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
  final List<Post> posts;
  final String? graduationCertificateImage;
  final String? cv;
  final List<CourseCertificate> courseCertificates;
  final String? createdAt;

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
          .map((e) => e.toString())
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
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      graduationCertificateImage:
          json['graduation_certificate_image'] as String?,
      cv: json['cv'] as String?,
      courseCertificates:
          (json['course_certificates_image'] as List<dynamic>? ?? [])
              .map((e) => CourseCertificate.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: json['created_at'] as String?,
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

class Post {
  final int id;
  final String? content;
  final String? image;
  final bool isAdRequest;
  final int likesCount;
  final String? createdAt;

  Post({
    required this.id,
    this.content,
    this.image,
    required this.isAdRequest,
    required this.likesCount,
    this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      content: json['content'] as String?,
      image: json['image'] as String?,
      isAdRequest: json['is_ad_request'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
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

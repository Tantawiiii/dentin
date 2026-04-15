import 'dart:convert';
import '../../../register/widgets/available_times_widget.dart';

class RegisterRequest {
  final String email;
  final String password;
  final String userName;
  final String firstName;
  final String lastName;
  final String phone;
  final String birthDate;
  final int graduationYear;
  final String description;
  final String university;
  final String graduationGrade;
  final String postgraduateDegree;
  final String specialization;
  final int experienceYears;
  final String? assistantUniversity;
  final int isWorkAssistantUniversity;
  final String? tools;
  final int hasClinic;
  final String? clinicName;
  final String? clinicAddress;
  final String experience;
  final String whereDidYouWork;
  final String address;
  final List<AvailableTimeSlot> availableTimes;
  final List<String> skills;
  final List<int>? fields;
  final int? profileImage;
  final int? cv;
  final int? coverImage;
  final int? graduationCertificateImage;
  final List<int>? courseCertificatesImage;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.birthDate,
    required this.graduationYear,
    required this.description,
    required this.university,
    required this.graduationGrade,
    required this.postgraduateDegree,
    required this.specialization,
    required this.experienceYears,
    this.assistantUniversity,
    required this.isWorkAssistantUniversity,
    this.tools,
    required this.hasClinic,
    this.clinicName,
    this.clinicAddress,
    required this.experience,
    required this.whereDidYouWork,
    required this.address,
    required this.availableTimes,
    required this.skills,
    this.fields,
    this.profileImage,
    this.cv,
    this.coverImage,
    this.graduationCertificateImage,
    this.courseCertificatesImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'user_name': userName,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'birth_date': birthDate,
      'graduation_year': graduationYear,
      'description': description,
      'university': university,
      'graduation_grade': graduationGrade,
      'postgraduate_degree': postgraduateDegree,
      'specialization': specialization,
      'experience_years': experienceYears,
      if (assistantUniversity != null) 'assistant_university': assistantUniversity,
      'is_work_assistant_university': isWorkAssistantUniversity,
      if (tools != null && tools!.isNotEmpty) 'tools': tools,
      'has_clinic': hasClinic,
      if (clinicName != null) 'clinic_name': clinicName,
      if (clinicAddress != null) 'clinic_address': clinicAddress,
      'experience': experience,
      'Where_did_you_work': whereDidYouWork,
      'address': address,
      'available_times': availableTimes.isEmpty
          ? '[]'
          : jsonEncode(availableTimes.map((slot) => {
              'day': slot.day,
              'from': slot.from,
              'to': slot.to,
            }).toList()),
      'skills': skills,
      if (fields != null && fields!.isNotEmpty) 'fields': fields,
      if (profileImage != null) 'profile_image': profileImage,
      if (cv != null) 'cv': cv,
      if (coverImage != null) 'cover_image': coverImage,
      if (graduationCertificateImage != null) 'graduation_certificate_image': graduationCertificateImage,
      if (courseCertificatesImage != null && courseCertificatesImage!.isNotEmpty) 
        'course_certificates_image': courseCertificatesImage,
    };
  }
}


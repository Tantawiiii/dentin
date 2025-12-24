import 'dart:convert';
import '../../../auth/register/widgets/available_times_widget.dart';

class UpdateProfileRequest {
  final String? email;
  final String? password;
  final String? userName;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? birthDate;
  final int? graduationYear;
  final String? description;
  final String? university;
  final String? graduationGrade;
  final String? postgraduateDegree;
  final String? specialization;
  final int? experienceYears;
  final String? assistantUniversity;
  final int? isWorkAssistantUniversity;
  final String? tools;
  final int? hasClinic;
  final String? clinicName;
  final String? clinicAddress;
  final String? experience;
  final String? whereDidYouWork;
  final String? address;
  final List<AvailableTimeSlot>? availableTimes;
  final List<String>? skills;
  final List<String>? fields;
  final int? profileImage;
  final int? cv;
  final int? coverImage;
  final int? graduationCertificateImage;
  final List<int>? courseCertificatesImage;

  UpdateProfileRequest({
    this.email,
    this.password,
    this.userName,
    this.firstName,
    this.lastName,
    this.phone,
    this.birthDate,
    this.graduationYear,
    this.description,
    this.university,
    this.graduationGrade,
    this.postgraduateDegree,
    this.specialization,
    this.experienceYears,
    this.assistantUniversity,
    this.isWorkAssistantUniversity,
    this.tools,
    this.hasClinic,
    this.clinicName,
    this.clinicAddress,
    this.experience,
    this.whereDidYouWork,
    this.address,
    this.availableTimes,
    this.skills,
    this.fields,
    this.profileImage,
    this.cv,
    this.coverImage,
    this.graduationCertificateImage,
    this.courseCertificatesImage,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (email != null) json['email'] = email;
    if (password != null) json['password'] = password;
    if (userName != null) json['user_name'] = userName;
    if (firstName != null) json['first_name'] = firstName;
    if (lastName != null) json['last_name'] = lastName;
    if (phone != null) json['phone'] = phone;
    if (birthDate != null) json['birth_date'] = birthDate;
    if (graduationYear != null) json['graduation_year'] = graduationYear;
    if (description != null) json['description'] = description;
    if (university != null) json['university'] = university;
    if (graduationGrade != null) json['graduation_grade'] = graduationGrade;
    if (postgraduateDegree != null) json['postgraduate_degree'] = postgraduateDegree;
    if (specialization != null) json['specialization'] = specialization;
    if (experienceYears != null) json['experience_years'] = experienceYears;
    if (assistantUniversity != null) json['assistant_university'] = assistantUniversity;
    if (isWorkAssistantUniversity != null) json['is_work_assistant_university'] = isWorkAssistantUniversity;
    if (tools != null && tools!.isNotEmpty) json['tools'] = tools;
    if (hasClinic != null) json['has_clinic'] = hasClinic;
    if (clinicName != null) json['clinic_name'] = clinicName;
    if (clinicAddress != null) json['clinic_address'] = clinicAddress;
    if (experience != null) json['experience'] = experience;
    if (whereDidYouWork != null) json['Where_did_you_work'] = whereDidYouWork;
    if (address != null) json['address'] = address;
    if (availableTimes != null && availableTimes!.isNotEmpty) {
      json['available_times'] = jsonEncode(availableTimes!.map((slot) => {
        'day': slot.day,
        'from': slot.from,
        'to': slot.to,
      }).toList());
    }
    if (skills != null && skills!.isNotEmpty) json['skills'] = skills;
    if (fields != null && fields!.isNotEmpty) json['fields'] = fields;
    if (profileImage != null) json['profile_image'] = profileImage;
    if (cv != null) json['cv'] = cv;
    if (coverImage != null) json['cover_image'] = coverImage;
    if (graduationCertificateImage != null) json['graduation_certificate_image'] = graduationCertificateImage;
    if (courseCertificatesImage != null && courseCertificatesImage!.isNotEmpty) {
      json['course_certificates_image'] = courseCertificatesImage;
    }
    
    return json;
  }
}


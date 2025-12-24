import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/di/inject.dart' as di;
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../auth/register/data/egyptian_universities.dart';
import '../../auth/register/data/grades.dart';
import '../../auth/register/data/degrees.dart';
import '../../auth/register/data/specialties.dart';
import '../../auth/register/widgets/basic_info_step.dart';
import '../../auth/register/widgets/education_step.dart';
import '../../auth/register/widgets/experience_step.dart';
import '../../auth/register/widgets/documents_step.dart';
import '../../auth/register/widgets/available_times_widget.dart';
import '../../auth/register/data/repo/register_repository.dart';
import '../data/repo/profile_repository.dart';
import '../data/models/profile_response.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final Doctor doctor;

  const EditProfileScreen({super.key, required this.doctor});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _basicInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _educationFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _experienceFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _documentsFormKey = GlobalKey<FormState>();
  final GlobalKey<AvailableTimesWidgetState> _availableTimesWidgetKey =
      GlobalKey<AvailableTimesWidgetState>();
  final GlobalKey<DocumentsStepState> _documentsStepKey =
      GlobalKey<DocumentsStepState>();
  late final EditProfileCubit _editProfileCubit;

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthDateController = TextEditingController();

  final _graduationYearController = TextEditingController();
  String? _selectedUniversity;
  String? _selectedGrade;
  String? _selectedDegree;
  List<String> _selectedSpecialties = [];

  final _yearsOfExperienceController = TextEditingController();
  final _professionalDescriptionController = TextEditingController();
  final _previousExperienceController = TextEditingController();
  final _workAddressController = TextEditingController();
  String? _isUniversityAssistant;
  String? _hasClinic;
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _universityNameController = TextEditingController();
  List<AvailableTimeSlot> _availableTimeSlots = [];
  List<String> _tools = [];
  List<String> _skills = [];

  // Documents
  File? _profileImage;
  File? _coverImage;
  File? _graduationCertificate;
  File? _cv;
  List<File> _courseCertificates = [];

  @override
  void initState() {
    super.initState();
    _editProfileCubit = EditProfileCubit(
      profileRepository: di.sl<ProfileRepository>(),
      registerRepository: di.sl<RegisterRepository>(),
      storageService: di.sl(),
      dioClient: di.sl(),
    );
    _initializeFormData();
  }

  void _initializeFormData() {
    final doctor = widget.doctor;

    // Basic Info
    _emailController.text = doctor.email;
    _usernameController.text = doctor.userName;
    _firstNameController.text = doctor.firstName;
    _lastNameController.text = doctor.lastName;
    _phoneController.text = doctor.phone;
    _addressController.text = doctor.address ?? '';

    // Parse birth date (format: YYYY-MM-DD to DD/MM/YYYY)
    if (doctor.birthDate != null && doctor.birthDate!.isNotEmpty) {
      try {
        final parts = doctor.birthDate!.split('-');
        if (parts.length == 3) {
          _birthDateController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
        } else {
          _birthDateController.text = doctor.birthDate!;
        }
      } catch (e) {
        _birthDateController.text = doctor.birthDate!;
      }
    }

    _graduationYearController.text = doctor.graduationYear ?? '';
    _selectedUniversity = null;
    if (doctor.university != null && doctor.university!.isNotEmpty) {
      final universityList = EgyptianUniversities.universities;
      if (universityList.contains(doctor.university)) {
        final count = universityList
            .where((u) => u == doctor.university)
            .length;
        if (count == 1) {
          _selectedUniversity = doctor.university;
        }
      }
    }

    String? mappedGrade = doctor.graduationGrade;
    if (mappedGrade != null) {
      switch (mappedGrade.toLowerCase()) {
        case 'excellent':
          mappedGrade = 'Excellent';
          break;
        case 'very_good':
        case 'very good':
          mappedGrade = 'Very Good';
          break;
        case 'good':
          mappedGrade = 'Good';
          break;
        case 'pass':
          mappedGrade = 'Pass';
          break;
        default:
          mappedGrade = null;
      }
    }
    _selectedGrade = mappedGrade != null && Grades.grades.contains(mappedGrade)
        ? mappedGrade
        : null;

    String? mappedDegree = doctor.postgraduateDegree;
    if (mappedDegree != null) {
      switch (mappedDegree.toLowerCase()) {
        case 'bachelor':
        case 'bachelor\'s degree':
        case 'bachelor degree':
          mappedDegree = 'Bachelor\'s Degree';
          break;
        case 'master':
        case 'master\'s degree':
        case 'master degree':
          mappedDegree = 'Master\'s Degree';
          break;
        case 'phd':
          mappedDegree = 'PhD';
          break;
        case 'diploma':
          mappedDegree = 'Diploma';
          break;
        case 'certificate':
          mappedDegree = 'Certificate';
          break;
        default:
          mappedDegree = null;
      }
    }
    _selectedDegree =
        mappedDegree != null && Degrees.degrees.contains(mappedDegree)
        ? mappedDegree
        : null;

    _selectedSpecialties = [];
    if (doctor.fields.isNotEmpty) {
      final fieldNames = doctor.fields.map((f) => f.name).toList();

      _selectedSpecialties = Specialties.specialties
          .where(
            (spec) => fieldNames.any(
              (fieldName) =>
                  fieldName.toLowerCase() == spec.toLowerCase() ||
                  spec.toLowerCase().contains(fieldName.toLowerCase()) ||
                  fieldName.toLowerCase().contains(spec.toLowerCase()),
            ),
          )
          .toList();
    }

    if (_selectedSpecialties.isEmpty &&
        doctor.specialization != null &&
        doctor.specialization!.isNotEmpty) {
      _selectedSpecialties = [doctor.specialization!];
    }

    // Experience
    _yearsOfExperienceController.text =
        doctor.experienceYears?.toString() ?? '';
    _professionalDescriptionController.text = doctor.description ?? '';
    _previousExperienceController.text = doctor.experience ?? '';
    _workAddressController.text = doctor.whereDidYouWork ?? '';
    _skills = List<String>.from(doctor.skills);

    _tools = [];
    if (doctor.tools != null && doctor.tools!.isNotEmpty) {
      try {
        final toolsStr = doctor.tools!.trim();
        if (toolsStr.startsWith('[') && toolsStr.endsWith(']')) {
          final decoded = jsonDecode(toolsStr) as List;
          _tools = decoded
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else {
          _tools = toolsStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (e) {
        // If JSON parsing fails, treat as comma-separated string
        _tools = doctor.tools!
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    _availableTimeSlots = _parseAvailableTimes(doctor.availableTimes);

    _hasClinic = doctor.hasClinic == true ? AppTexts.yes : AppTexts.no;
    _isUniversityAssistant = doctor.isWorkAssistantUniversity == true
        ? AppTexts.yes
        : AppTexts.no;
    _clinicNameController.text = doctor.clinicName ?? '';
    _clinicAddressController.text = doctor.clinicAddress ?? '';
    _universityNameController.text = doctor.assistantUniversity ?? '';

    if (doctor.fields.isNotEmpty) {
      final fieldNames = doctor.fields.map((f) => f.name).toList();

      _selectedSpecialties = Specialties.specialties
          .where((spec) => fieldNames.contains(spec))
          .toList();
    } else if (doctor.specialization != null &&
        doctor.specialization!.isNotEmpty) {
      _selectedSpecialties = [doctor.specialization!];
    } else {
      _selectedSpecialties = [];
    }
  }

  List<AvailableTimeSlot> _parseAvailableTimes(List<String> availableTimes) {
    final List<AvailableTimeSlot> slots = [];
    if (availableTimes.isEmpty) {
      return slots;
    }

    for (final timeStr in availableTimes) {
      if (timeStr.contains('|')) {
        final parts = timeStr.split('|');
        if (parts.length == 3 &&
            parts[0].isNotEmpty &&
            parts[1].isNotEmpty &&
            parts[2].isNotEmpty) {
          slots.add(
            AvailableTimeSlot(
              day: parts[0].trim(),
              from: parts[1].trim(),
              to: parts[2].trim(),
            ),
          );
        }
      }
    }
    return slots;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    _graduationYearController.dispose();
    _yearsOfExperienceController.dispose();
    _professionalDescriptionController.dispose();
    _previousExperienceController.dispose();
    _workAddressController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _universityNameController.dispose();
    _editProfileCubit.close();
    super.dispose();
  }

  void _nextStep() {
    bool isValid = true;

    if (_currentStep == 0) {
      isValid = _basicInfoFormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 1) {
      isValid = _educationFormKey.currentState?.validate() ?? false;
      if (isValid && _selectedSpecialties.isEmpty) {
        isValid = false;
        AppToast.showError(AppTexts.specialtiesRequired, context: context);
      }
    } else if (_currentStep == 2) {
      isValid = _experienceFormKey.currentState?.validate() ?? false;

      if (isValid && _tools.isEmpty) {
        isValid = false;
        AppToast.showError(AppTexts.toolsRequired, context: context);
      } else if (isValid && _skills.isEmpty) {
        isValid = false;
        AppToast.showError(AppTexts.skillsRequired, context: context);
      } else if (isValid && _hasClinic == AppTexts.yes) {
        final timeSlotsError = _availableTimesWidgetKey.currentState
            ?.validate();
        if (timeSlotsError != null) {
          isValid = false;
          AppToast.showError(timeSlotsError, context: context);
        }
      }
    } else if (_currentStep == 3) {
      isValid = _documentsFormKey.currentState?.validate() ?? false;
      if (isValid) {
        final documentsValid =
            _documentsStepKey.currentState?.validate() ?? false;
        if (!documentsValid) {
          isValid = false;
        }
      }

      if (isValid) {
        _submitUpdate();
      }
      return;
    }

    if (isValid && _currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitUpdate() {
    final availableTimes = _availableTimeSlots.map((slot) => slot).toList();

    final isWorkAssistantUniversity = _isUniversityAssistant == AppTexts.yes
        ? 1
        : 0;
    final hasClinicInt = _hasClinic == AppTexts.yes ? 1 : 0;

    String formattedBirthDate = _birthDateController.text.trim();
    try {
      final parts = formattedBirthDate.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        formattedBirthDate = '$year-$month-$day';
      }
    } catch (e) {}

    String mappedPostgraduateDegree = _selectedDegree ?? '';
    if (mappedPostgraduateDegree.isNotEmpty) {
      switch (mappedPostgraduateDegree.toLowerCase()) {
        case 'bachelor\'s degree':
        case 'bachelor degree':
          mappedPostgraduateDegree = 'bachelor';
          break;
        case 'master\'s degree':
        case 'master degree':
          mappedPostgraduateDegree = 'master';
          break;
        case 'phd':
          mappedPostgraduateDegree = 'phd';
          break;
        case 'diploma':
          mappedPostgraduateDegree = 'diploma';
          break;
        case 'certificate':
          mappedPostgraduateDegree = 'certificate';
          break;
        default:
          break;
      }
    }

    String mappedGraduationGrade = _selectedGrade ?? '';
    if (mappedGraduationGrade.isNotEmpty) {
      switch (mappedGraduationGrade.toLowerCase()) {
        case 'excellent':
          mappedGraduationGrade = 'excellent';
          break;
        case 'very good':
          mappedGraduationGrade = 'very_good';
          break;
        case 'good':
          mappedGraduationGrade = 'good';
          break;
        case 'pass':
          mappedGraduationGrade = 'pass';
          break;
        default:
          break;
      }
    }

    _editProfileCubit.updateProfile(
      userId: widget.doctor.id,
      email: _emailController.text.trim(),
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text
          : null,
      userName: _usernameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      birthDate: formattedBirthDate,
      graduationYear: int.tryParse(_graduationYearController.text) ?? 2025,
      description: _professionalDescriptionController.text.trim(),
      university: _selectedUniversity ?? '',
      graduationGrade: mappedGraduationGrade,
      postgraduateDegree: mappedPostgraduateDegree,
      specialization: _selectedSpecialties.isNotEmpty
          ? _selectedSpecialties.first
          : '',
      experienceYears: int.tryParse(_yearsOfExperienceController.text) ?? 0,
      assistantUniversity: _universityNameController.text.trim().isEmpty
          ? null
          : _universityNameController.text.trim(),
      isWorkAssistantUniversity: isWorkAssistantUniversity,
      tools: _tools.isEmpty ? null : _tools.join(', '),
      hasClinic: hasClinicInt,
      clinicName: _clinicNameController.text.trim().isEmpty
          ? null
          : _clinicNameController.text.trim(),
      clinicAddress: _clinicAddressController.text.trim().isEmpty
          ? null
          : _clinicAddressController.text.trim(),
      experience: _previousExperienceController.text.trim(),
      whereDidYouWork: _workAddressController.text.trim(),
      address: _addressController.text.trim(),
      availableTimes: availableTimes,
      skills: _skills,
      fields: [],
      profileImage: _profileImage,
      cv: _cv,
      coverImage: _coverImage,
      graduationCertificate: _graduationCertificate,
      courseCertificates: _courseCertificates.isEmpty
          ? null
          : _courseCertificates,
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          children: List.generate(4, (index) {
            final isActive = index <= _currentStep;
            final isCompleted = index < _currentStep;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppColors.primary : AppColors.border,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: AppColors.textOnPrimary,
                              size: 20.sp,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.textOnPrimary
                                    : AppColors.textSecondary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  if (index < 3)
                    Expanded(
                      child: Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: index < _currentStep
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStepLabel(AppTexts.basicInfo, 0),
            _buildStepLabel(AppTexts.education, 1),
            _buildStepLabel(AppTexts.experience, 2),
            _buildStepLabel(AppTexts.documents, 3),
          ],
        ),
      ],
    );
  }

  Widget _buildStepLabel(String label, int index) {
    final isActive = index == _currentStep;
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _editProfileCubit,
      child: BlocConsumer<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            AppToast.showSuccess(
              AppTexts.profileUpdatedSuccessfully,
              context: context,
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else if (state is EditProfileError) {
            AppToast.showError(state.message, context: context);
          }
        },
        builder: (context, state) {
          final isLoading =
              state is EditProfileUploadingFiles ||
              state is EditProfileSubmitting;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                AppTexts.editProfileTitle,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        Text(
                          AppTexts.editProfileSubtitle,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        _buildProgressIndicator(),
                        SizedBox(height: 32.h),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              BasicInfoStep(
                                formKey: _basicInfoFormKey,
                                firstNameController: _firstNameController,
                                lastNameController: _lastNameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                usernameController: _usernameController,
                                phoneController: _phoneController,
                                addressController: _addressController,
                                birthDateController: _birthDateController,
                              ),
                              EducationStep(
                                formKey: _educationFormKey,
                                graduationYearController:
                                    _graduationYearController,
                                selectedUniversity: _selectedUniversity,
                                selectedGrade: _selectedGrade,
                                selectedDegree: _selectedDegree,
                                selectedSpecialties: _selectedSpecialties,
                                egyptianUniversities:
                                    EgyptianUniversities.universities,
                                grades: Grades.grades,
                                degrees: Degrees.degrees,
                                specialties: Specialties.specialties,
                                onUniversityChanged: (value) {
                                  setState(() {
                                    _selectedUniversity = value;
                                  });
                                },
                                onGradeChanged: (value) {
                                  setState(() {
                                    _selectedGrade = value;
                                  });
                                },
                                onDegreeChanged: (value) {
                                  setState(() {
                                    _selectedDegree = value;
                                  });
                                },
                                onSpecialtiesChanged: (value) {
                                  setState(() {
                                    _selectedSpecialties = value;
                                  });
                                },
                              ),
                              ExperienceStep(
                                formKey: _experienceFormKey,
                                yearsOfExperienceController:
                                    _yearsOfExperienceController,
                                professionalDescriptionController:
                                    _professionalDescriptionController,
                                previousExperienceController:
                                    _previousExperienceController,
                                workAddressController: _workAddressController,
                                isUniversityAssistant: _isUniversityAssistant,
                                hasClinic: _hasClinic,
                                clinicNameController: _clinicNameController,
                                clinicAddressController:
                                    _clinicAddressController,
                                universityNameController:
                                    _universityNameController,
                                availableTimeSlots: _availableTimeSlots,
                                onAvailableTimeSlotsChanged: (value) {
                                  setState(() {
                                    _availableTimeSlots = value;
                                  });
                                },
                                availableTimesWidgetKey:
                                    _availableTimesWidgetKey,
                                tools: _tools,
                                skills: _skills,
                                onUniversityAssistantChanged: (value) {
                                  setState(() {
                                    _isUniversityAssistant = value;
                                  });
                                },
                                onHasClinicChanged: (value) {
                                  setState(() {
                                    _hasClinic = value;
                                  });
                                },
                                onToolsChanged: (value) {
                                  setState(() {
                                    _tools = value;
                                  });
                                },
                                onSkillsChanged: (value) {
                                  setState(() {
                                    _skills = value;
                                  });
                                },
                              ),
                              DocumentsStep(
                                key: _documentsStepKey,
                                formKey: _documentsFormKey,
                                profileImage: _profileImage,
                                coverImage: _coverImage,
                                graduationCertificate: _graduationCertificate,
                                cv: _cv,
                                courseCertificates: _courseCertificates,
                                profileImageUrl: widget.doctor.profileImage,
                                coverImageUrl: widget.doctor.coverImage,
                                graduationCertificateUrl:
                                    widget.doctor.graduationCertificateImage,
                                cvUrl: widget.doctor.cv,
                                courseCertificatesUrls: widget
                                    .doctor
                                    .courseCertificates
                                    .map((cert) => cert.fullUrl)
                                    .toList(),
                                onProfileImageChanged: (file) {
                                  setState(() {
                                    _profileImage = file;
                                  });
                                },
                                onCoverImageChanged: (file) {
                                  setState(() {
                                    _coverImage = file;
                                  });
                                },
                                onGraduationCertificateChanged: (file) {
                                  setState(() {
                                    _graduationCertificate = file;
                                  });
                                },
                                onCvChanged: (file) {
                                  setState(() {
                                    _cv = file;
                                  });
                                },
                                onCourseCertificatesChanged: (files) {
                                  setState(() {
                                    _courseCertificates = files;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state is EditProfileUploadingFiles) ...[
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(24.w),
                          margin: EdgeInsets.symmetric(horizontal: 32.w),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                value: state.progress,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                state.currentFile,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '${state.uploadedFiles} ${AppTexts.of} ${state.totalFiles} ${AppTexts.filesUploaded}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '${(state.progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
                ? null
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: SecondaryButton(
                                title: AppTexts.prev,
                                onPressed: _previousStep,
                                icon: Icons.arrow_back,
                              ),
                            ),
                          if (_currentStep > 0) SizedBox(width: 12.w),
                          Expanded(
                            flex: _currentStep == 3 ? 2 : 1,
                            child: PrimaryButton(
                              title: _currentStep == 3
                                  ? AppTexts.updateProfile
                                  : AppTexts.next,
                              onPressed: isLoading ? null : _nextStep,
                              isLoading: isLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

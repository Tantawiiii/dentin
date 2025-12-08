import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import 'widgets/basic_info_step.dart';
import 'widgets/education_step.dart';
import 'widgets/experience_step.dart';
import 'widgets/documents_step.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _basicInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _educationFormKey = GlobalKey<FormState>();

  // Basic Info Controllers
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthDateController = TextEditingController();

  // Education Controllers
  final _graduationYearController = TextEditingController(text: '2025');
  String? _selectedUniversity;
  String? _selectedGrade;
  String? _selectedDegree;

  // Egyptian Universities
  final List<String> _egyptianUniversities = [
    'Cairo University',
    'Ain Shams University',
    'Alexandria University',
    'Mansoura University',
    'Zagazig University',
    'Assiut University',
    'Tanta University',
    'Suez Canal University',
    'Helwan University',
    'Beni-Suef University',
    'Minia University',
    'South Valley University',
    'Kafrelsheikh University',
    'Damietta University',
    'Sohag University',
    'Aswan University',
    'Luxor University',
    'New Valley University',
    'Port Said University',
    'Suez University',
    'Damanhour University',
    'Fayoum University',
    'Benha University',
    'Menoufia University',
    'American University in Cairo',
    'German University in Cairo',
    'British University in Egypt',
    'Misr University for Science and Technology',
    'Modern Academy',
    'Ahram Canadian University',
  ];

  final List<String> _grades = ['Excellent', 'Very Good', 'Good', 'Pass'];

  final List<String> _degrees = [
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Diploma',
    'Certificate',
  ];

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
    super.dispose();
  }

  void _nextStep() {
    bool isValid = true;

    if (_currentStep == 0) {
      isValid = _basicInfoFormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 1) {
      isValid = _educationFormKey.currentState?.validate() ?? false;
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Text(
                AppTexts.createYourAccount,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppTexts.joinOurPlatform,
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
                      graduationYearController: _graduationYearController,
                      selectedUniversity: _selectedUniversity,
                      selectedGrade: _selectedGrade,
                      selectedDegree: _selectedDegree,
                      egyptianUniversities: _egyptianUniversities,
                      grades: _grades,
                      degrees: _degrees,
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
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const ExperienceStep(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const DocumentsStep(),
                    ),
                  ],
                ),
              ),
              Row(
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
                    child: PrimaryButton(
                      title: _currentStep == 3
                          ? AppTexts.submit
                          : AppTexts.next,
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),
              8.verticalSpace,
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppTexts.alreadyHaveAccount,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppTexts.loginHere,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

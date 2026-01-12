import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/extensions/image_picker_extension.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/primary_button.dart';
import '../auth/register/data/specialties.dart';
import '../auth/register/widgets/image_source_dialog.dart';
import '../home/data/repo/post_repository.dart';
import 'data/models/job_models.dart';
import 'data/repo/job_repository.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobRepository = di.sl<JobRepository>();
  final _postRepository = di.sl<PostRepository>();
  final _imagePicker = ImagePicker();

  // final _companyNameController = TextEditingController();
  // final _companySizeController = TextEditingController();
  // final _companyIndustryController = TextEditingController();
  // final _companyFoundedController = TextEditingController();
  // final _companyWebsiteController = TextEditingController();
  // final _companyLocationController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _benefitsController = TextEditingController();

  String _selectedJobType = AppTexts.jobsFullTime;
  String? _selectedSpecialization;
  File? _imageFile;
  bool _isSubmitting = false;

  final List<String> _jobTypes = [
    AppTexts.jobsFullTime,
    AppTexts.jobsPartTime,
    AppTexts.jobsRemote,
  ];

  @override
  void dispose() {
    // _companyNameController.dispose();
    // _companySizeController.dispose();
    // _companyIndustryController.dispose();
    // _companyFoundedController.dispose();
    // _companyWebsiteController.dispose();
    // _companyLocationController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _responsibilitiesController.dispose();
    _requirementsController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      int? imageId;

      if (_imageFile != null) {
        final mediaResponse = await _postRepository.uploadMedia(_imageFile!);
        imageId = mediaResponse.data?.id;

        if (imageId == null || imageId == 0) {
          final errorMsg = mediaResponse.data == null
              ? AppTexts.jobsImageUploadFailedNoData
              : AppTexts.jobsImageUploadFailedInvalidId;
          throw Exception(errorMsg);
        }
      }

      final request = CreateJobRequest(
        // companyName: _companyNameController.text.trim(),
        // companySize: _companySizeController.text.trim().isEmpty
        //     ? null
        //     : _companySizeController.text.trim(),
        // companyIndustry: _companyIndustryController.text.trim().isEmpty
        //     ? null
        //     : _companyIndustryController.text.trim(),
        // companyFounded: _companyFoundedController.text.trim().isEmpty
        //     ? null
        //     : _companyFoundedController.text.trim(),
        // companyWebsite: _companyWebsiteController.text.trim().isEmpty
        //     ? null
        //     : _companyWebsiteController.text.trim(),
        // companyLocation: _companyLocationController.text.trim().isEmpty
        //     ? null
        //     : _companyLocationController.text.trim(),
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        type: _selectedJobType,
        salary: _salaryController.text.trim(),
        image: imageId,
        available: true,
        description: _descriptionController.text.trim(),
        responsibilities: _responsibilitiesController.text.trim().isEmpty
            ? null
            : _responsibilitiesController.text.trim(),
        requirements: _requirementsController.text.trim().isEmpty
            ? null
            : _requirementsController.text.trim(),
        benefits: _benefitsController.text.trim().isEmpty
            ? null
            : _benefitsController.text.trim(),
        specialization: _selectedSpecialization,
      );

      await _jobRepository.createJob(request);

      if (!mounted) return;

      AppToast.showSuccess(
        AppTexts.jobsJobCreatedSuccessfully,
        context: context,
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        e.toString().replaceFirst('Exception: ', ''),
        context: context,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.jobsPostNewJob,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            Text(
              AppTexts.jobsPostNewJobDescription,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bounce(
              //   onTap: _pickImage,
              //   child: Container(
              //     height: 120.h,
              //     width: double.infinity,
              //     decoration: BoxDecoration(
              //       color: AppColors.surfaceVariant,
              //       borderRadius: BorderRadius.circular(12.r),
              //       border: Border.all(color: AppColors.border, width: 1.5),
              //     ),
              //     child: _imageFile != null
              //         ? ClipRRect(
              //             borderRadius: BorderRadius.circular(12.r),
              //             child: Image.file(_imageFile!, fit: BoxFit.cover),
              //           )
              //         : Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Icon(
              //                 Icons.add_photo_alternate_outlined,
              //                 size: 32.sp,
              //                 color: AppColors.textSecondary,
              //               ),
              //               SizedBox(height: 8.h),
              //               Text(
              //                 AppTexts.jobsTapToAddCompanyLogo,
              //                 style: TextStyle(
              //                   fontSize: 12.sp,
              //                   color: AppColors.textSecondary,
              //                 ),
              //               ),
              //             ],
              //           ),
              //   ),
              // ),
           //   SizedBox(height: 24.h),

              // Text(
              //   AppTexts.jobsCompanyInformation,
              //   style: TextStyle(
              //     fontSize: 18.sp,
              //     fontWeight: FontWeight.w700,
              //     color: AppColors.textPrimary,
              //   ),
              // ),
              // SizedBox(height: 16.h),
              // TextFormField(
              //   controller: _companyNameController,
              //   decoration: InputDecoration(
              //     labelText: '${AppTexts.jobsCompanyName} *',
              //     hintText: AppTexts.jobsCompanyName,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.r),
              //     ),
              //     filled: true,
              //     fillColor: AppColors.surfaceVariant,
              //   ),
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return AppTexts.jobsCompanyNameRequired;
              //     }
              //     return null;
              //   },
              // ),
              // SizedBox(height: 16.h),
              //
              // TextFormField(
              //   controller: _companySizeController,
              //   decoration: InputDecoration(
              //     labelText: AppTexts.jobsCompanySize,
              //     hintText: AppTexts.jobsCompanySize,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.r),
              //     ),
              //     filled: true,
              //     fillColor: AppColors.surfaceVariant,
              //   ),
              // ),
              // SizedBox(height: 16.w),
              // TextFormField(
              //   controller: _companyIndustryController,
              //   decoration: InputDecoration(
              //     labelText: AppTexts.jobsCompanyIndustry,
              //     hintText: AppTexts.jobsCompanyIndustry,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.r),
              //     ),
              //     filled: true,
              //     fillColor: AppColors.surfaceVariant,
              //   ),
              // ),
              // SizedBox(height: 16.h),
              // TextFormField(
              //   controller: _companyFoundedController,
              //   decoration: InputDecoration(
              //     labelText: AppTexts.jobsCompanyFounded,
              //     hintText: AppTexts.jobsCompanyFounded,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.r),
              //     ),
              //     filled: true,
              //     fillColor: AppColors.surfaceVariant,
              //   ),
              // ),
              // SizedBox(height: 16.h),
              // TextFormField(
              //   controller: _companyWebsiteController,
              //   decoration: InputDecoration(
              //     labelText: AppTexts.jobsCompanyWebsite,
              //     hintText: AppTexts.jobsCompanyWebsite,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.r),
              //     ),
              //     filled: true,
              //     fillColor: AppColors.surfaceVariant,
              //   ),
              // ),
              // SizedBox(height: 16.w),
              // TextFormField(
              //   controller: _companyLocationController,
              //   decoration: InputDecoration(
              //     labelText: AppTexts.jobsCompanyLocation,
              //     hintText: AppTexts.jobsCompanyLocation,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.r),
              //     ),
              //     filled: true,
              //     fillColor: AppColors.surfaceVariant,
              //   ),
              // ),
              // SizedBox(height: 24.h),
              Text(
                AppTexts.jobsJobInformation,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '${AppTexts.jobsJobTitle} *',
                  hintText: AppTexts.jobsJobTitle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.jobsJobTitleRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.w),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: '${AppTexts.jobsJobLocation} *',
                  hintText: AppTexts.jobsJobLocation,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.jobsJobLocationRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedJobType,
                      decoration: InputDecoration(
                        labelText: AppTexts.jobsJobType,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                      ),
                      items: _jobTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedJobType = value;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: _salaryController,
                      decoration: InputDecoration(
                        labelText: '${AppTexts.jobsSalary} *',
                        hintText: AppTexts.jobsSalary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppTexts.jobsSalaryRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedSpecialization,
                decoration: InputDecoration(
                  labelText: AppTexts.jobsSpecialization,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(AppTexts.jobsSelectSpecializationOptional),
                  ),
                  ...Specialties.specialties.map((specialty) {
                    return DropdownMenuItem<String>(
                      value: specialty,
                      child: Text(specialty),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialization = value;
                  });
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppTexts.jobsJobDetails,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: '${AppTexts.jobsJobDescription} *',
                  hintText: AppTexts.jobsJobDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.jobsJobDescriptionRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _responsibilitiesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppTexts.jobsResponsibilities,
                  hintText: AppTexts.jobsResponsibilities,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),

              // Requirements
              TextFormField(
                controller: _requirementsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppTexts.jobsRequirements,
                  hintText: AppTexts.jobsRequirements,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),

              TextFormField(
                controller: _benefitsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppTexts.jobsBenefits,
                  hintText: AppTexts.jobsBenefits,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
              SizedBox(height: 24.h),

              PrimaryButton(
                title: AppTexts.jobsPostJob,
                onPressed: _isSubmitting ? null : _submit,
                isLoading: _isSubmitting,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

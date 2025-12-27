import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/models/job_models.dart';
import '../data/repo/job_repository.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobRepository = di.sl<JobRepository>();

  // Job fields
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _benefitsController = TextEditingController();

  String _selectedJobType = 'Full-time';
  bool _isSubmitting = false;

  final List<String> _jobTypes = ['Full-time', 'Part-time', 'Remote'];

  @override
  void dispose() {
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
      final request = CreateJobRequest(
        companyName: '',
        companySize: null,
        companyIndustry: null,
        companyFounded: null,
        companyWebsite: null,
        companyLocation: null,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        type: _selectedJobType,
        salary: _salaryController.text.trim(),
        image: null,
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
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
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
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Information
              Text(
                'Job Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),

              // Job Title and Location
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
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
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
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
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Job Type and Salary
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
              SizedBox(height: 24.h),

              // Job Details Section
              Text(
                AppTexts.jobsJobDetails,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),

              // Job Description (Required)
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

              // Responsibilities
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

              // Benefits
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

              // Submit Button
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

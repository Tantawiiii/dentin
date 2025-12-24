import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/di/inject.dart' as di;
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import 'data/models/job_models.dart';
import 'data/repo/job_repository.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;
  final Job? initialJob;

  const JobDetailsScreen({super.key, required this.jobId, this.initialJob});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final JobRepository _jobRepository = di.sl<JobRepository>();

  Job? _job;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _job = widget.initialJob;
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _jobRepository.getJobDetails(widget.jobId);
      setState(() {
        _job = response.data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showApplyDialog() async {
    final controller = TextEditingController(
      text: AppTexts.jobsDefaultCoverLetter,
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isSubmitting = false;

        Future<void> submit() async {
          final text = controller.text.trim();
          if (text.isEmpty) {
            AppToast.showWarning(
              AppTexts.jobsCoverLetterRequired,
              context: context,
            );
            return;
          }

          if (isSubmitting) return;
          isSubmitting = true;

          try {
            final job = _job;
            if (job == null) {
              AppToast.showError(
                AppTexts.jobsDetailsNotLoaded,
                context: context,
              );
              return;
            }

            final response = await _jobRepository.applyToJob(
              jobId: job.id,
              coverLetter: text,
            );

            if (response.status == 200) {
              AppToast.showSuccess(
                response.message.isNotEmpty
                    ? response.message
                    : AppTexts.jobsApplicationSuccessDefault,
                context: context,
              );
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            } else {
              AppToast.showError(
                response.message.isNotEmpty
                    ? response.message
                    : AppTexts.jobsApplicationFailedDefault,
                context: context,
              );
            }
          } catch (e) {
            AppToast.showError(
              e.toString().replaceFirst('Exception: ', ''),
              context: context,
            );
          } finally {
            isSubmitting = false;
          }
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppTexts.jobsApplyForPrefix}${_job?.title ?? AppTexts.jobsJobFallback}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    AppTexts.jobsApplyDialogInfo,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  AppTexts.jobsCoverLetter,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: controller,
                  hint: AppTexts.jobsCoverLetterHint,
                  maxLines: 5,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SecondaryButton(
                        title: AppTexts.cancel,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        title: AppTexts.jobsSubmitApplication,
                        onPressed: submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _canApply => _job?.available == true && _job?.active == true;

  @override
  Widget build(BuildContext context) {
    final job = _job;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(job?.title ?? AppTexts.jobsDetailsTitleFallback),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _job == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _job == null) {
      return Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.error),
            ),
            SizedBox(height: 16.h),
            PrimaryButton(
              title: AppTexts.jobsErrorRetry,
              onPressed: _loadJobDetails,
            ),
          ],
        ),
      );
    }

    final job = _job;
    if (job == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(job),
          SizedBox(height: 16.h),
          _buildInfoChips(job),
          SizedBox(height: 24.h),
          if (job.description.isNotEmpty) ...[
            _buildSectionTitle(AppTexts.jobsDescription),
            SizedBox(height: 8.h),
            _buildSectionText(job.description),
            SizedBox(height: 20.h),
          ],
          if (job.responsibilities.isNotEmpty) ...[
            _buildSectionTitle(AppTexts.jobsResponsibilities),
            SizedBox(height: 8.h),
            _buildSectionText(job.responsibilities),
            SizedBox(height: 20.h),
          ],
          if (job.requirements.isNotEmpty) ...[
            _buildSectionTitle(AppTexts.jobsRequirements),
            SizedBox(height: 8.h),
            _buildSectionText(job.requirements),
            SizedBox(height: 20.h),
          ],
          if (job.benefits.isNotEmpty) ...[
            _buildSectionTitle(AppTexts.jobsBenefits),
            SizedBox(height: 8.h),
            _buildSectionText(job.benefits),
          ],
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildHeader(Job job) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Text(
              job.title.isNotEmpty ? job.title[0].toUpperCase() : 'D',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                job.company.name?.isNotEmpty == true
                    ? job.company.name!
                    : AppTexts.jobsUnknownCompany,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      job.location,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChips(Job job) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _chip(icon: Icons.work_outline, label: job.type),
        _chip(
          icon: Icons.payments_outlined,
          label: job.salary.isNotEmpty
              ? '\$${job.salary}'
              : AppTexts.jobsSalaryNotSpecified,
        ),
        _chip(icon: Icons.access_time, label: job.createdAt),
        if (job.applicationsCount > 0)
          _chip(
            icon: Icons.group_outlined,
            label: '${job.applicationsCount} ${AppTexts.jobsApplicationsLabel}',
          ),
      ],
    );
  }

  Widget _chip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        height: 1.5,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildBottomBar() {
    final job = _job;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (job != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      job.salary.isNotEmpty
                          ? '\$${job.salary}'
                          : AppTexts.jobsSalaryNotSpecified,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.type,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(width: 16.w),
            Expanded(
              child: PrimaryButton(
                title: _canApply
                    ? AppTexts.jobsApplyNow
                    : AppTexts.jobsNotAvailable,
                onPressed: _canApply ? _showApplyDialog : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

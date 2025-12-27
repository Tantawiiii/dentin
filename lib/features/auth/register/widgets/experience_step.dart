import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'build_dropdown_menu.dart';
import 'chip_input_field.dart';
import 'available_times_widget.dart';

class ExperienceStep extends StatelessWidget {
  const ExperienceStep({
    super.key,
    required this.formKey,
    required this.yearsOfExperienceController,
    required this.professionalDescriptionController,
    required this.previousExperienceController,
    required this.workAddressController,
    required this.isUniversityAssistant,
    required this.hasClinic,
    required this.clinicNameController,
    required this.clinicAddressController,
    required this.universityNameController,
    required this.availableTimeSlots,
    required this.onAvailableTimeSlotsChanged,
    this.availableTimesWidgetKey,
    required this.tools,
    required this.skills,
    required this.onUniversityAssistantChanged,
    required this.onHasClinicChanged,
    required this.onToolsChanged,
    required this.onSkillsChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController yearsOfExperienceController;
  final TextEditingController professionalDescriptionController;
  final TextEditingController previousExperienceController;
  final TextEditingController workAddressController;
  final String? isUniversityAssistant;
  final String? hasClinic;
  final TextEditingController clinicNameController;
  final TextEditingController clinicAddressController;
  final TextEditingController universityNameController;
  final List<AvailableTimeSlot> availableTimeSlots;
  final Function(List<AvailableTimeSlot>) onAvailableTimeSlotsChanged;
  final GlobalKey<AvailableTimesWidgetState>? availableTimesWidgetKey;
  final List<String> tools;
  final List<String> skills;
  final Function(String?) onUniversityAssistantChanged;
  final Function(String?) onHasClinicChanged;
  final Function(List<String>) onToolsChanged;
  final Function(List<String>) onSkillsChanged;

  static final List<String> _yesNoOptions = [AppTexts.yes, AppTexts.no];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  AppTexts.professionalExperience,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            AppTextField(
              controller: yearsOfExperienceController,
              hint: AppTexts.enterYearsOfExperience,
              leadingIcon: Icons.work_outline,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.yearsOfExperienceRequired;
                }
                return null;
              },
            ),
            AppTextField(
              controller: professionalDescriptionController,
              hint: AppTexts.enterProfessionalDescription,
              leadingIcon: Icons.description_outlined,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.professionalDescriptionRequired;
                }
                return null;
              },
            ),
            AppTextField(
              controller: previousExperienceController,
              hint: AppTexts.enterPreviousExperience,
              leadingIcon: Icons.history_outlined,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.previousExperienceRequired;
                }
                return null;
              },
            ),
            AppTextField(
              controller: workAddressController,
              hint: AppTexts.enterWorkAddress,
              leadingIcon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.workAddressRequired;
                }
                return null;
              },
            ),

            BuildDropdownField(
              label: AppTexts.universityAssistant,
              value: isUniversityAssistant,
              items: _yesNoOptions,
              hint: AppTexts.selectUniversityAssistant,
              icon: Icons.school_outlined,
              onChanged: onUniversityAssistantChanged,
              title: AppTexts.universityAssistant,
            ),

            if (isUniversityAssistant == AppTexts.yes)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppTexts.teacherAssistantAtUniversity} *',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: universityNameController,
                    hint: AppTexts.enterUniversityName,
                    leadingIcon: Icons.school_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTexts.universityNameRequired;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            BuildDropdownField(
              label: AppTexts.haveClinic,
              value: hasClinic,
              items: _yesNoOptions,
              hint: AppTexts.selectHaveClinic,
              icon: Icons.local_hospital_outlined,
              onChanged: onHasClinicChanged,
              title: AppTexts.haveClinic,
            ),

            if (hasClinic == AppTexts.yes) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppTexts.clinicName} *',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: clinicNameController,
                    hint: AppTexts.enterClinicName,
                    leadingIcon: Icons.local_hospital_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTexts.clinicNameRequired;
                      }
                      return null;
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppTexts.clinicAddress} *',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: clinicAddressController,
                    hint: AppTexts.enterClinicAddress,
                    leadingIcon: Icons.location_on_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTexts.clinicAddressRequired;
                      }
                      return null;
                    },
                  ),
                ],
              ),
              AvailableTimesWidget(
                key: availableTimesWidgetKey,
                timeSlots: availableTimeSlots,
                onTimeSlotsChanged: onAvailableTimeSlotsChanged,
              ),
            ],
            ChipInputField(
              label: AppTexts.toolsYouHave,
              chips: tools,
              onChipsChanged: onToolsChanged,
              hint: AppTexts.addTool,
              addButtonText: AppTexts.addToolButton,
              icon: Icons.build_outlined,
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return AppTexts.toolsRequired;
              //   }
              //   return null;
              // },
            ),
            ChipInputField(
              label: AppTexts.skills,
              chips: skills,
              onChipsChanged: onSkillsChanged,
              hint: AppTexts.addSkill,
              addButtonText: AppTexts.addSkillButton,
              icon: Icons.stars_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.skillsRequired;
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

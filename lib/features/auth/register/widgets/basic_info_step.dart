import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/app_text_field.dart';

class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    required this.phoneController,
    required this.addressController,
    required this.birthDateController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController birthDateController;

  Widget _buildSectionHeader(String title) {
    return Row(
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
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(AppTexts.personalInformation),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: firstNameController,
                    hint: AppTexts.enterYourFirstName,
                    leadingIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTexts.firstNameRequired;
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AppTextField(
                    controller: lastNameController,
                    hint: AppTexts.enterYourLastName,
                    leadingIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTexts.lastNameRequired;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: usernameController,
              hint: AppTexts.enterYourUsername,
              leadingIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.usernameRequired;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: emailController,
              hint: AppTexts.enterYourEmailAddress,
              leadingIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.emailRequired;
                }
                if (!value.contains('@')) {
                  return AppTexts.emailInvalid;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: passwordController,
              hint: AppTexts.enterYourPassword,
              leadingIcon: Icons.lock_outline,
              obscure: true,
              obscurable: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.passwordRequired;
                }
                if (value.length < 6) {
                  return AppTexts.shortPassword;
                }
                return null;
              },
            ),

            SizedBox(height: 16.h),
            AppTextField(
              controller: phoneController,
              hint: AppTexts.enterYourPhoneNumber,
              leadingIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.phoneNumberRequired;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: addressController,
              hint: AppTexts.enterYourAddress,
              leadingIcon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.addressRequired;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: birthDateController,
              hint: AppTexts.birthDatePlaceholder,
              leadingIcon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  birthDateController.text =
                      '${date.day}/${date.month}/${date.year}';
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppTexts.birthDateRequired;
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




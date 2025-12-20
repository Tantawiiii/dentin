import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/di/inject.dart' as di;
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../cubit/forget_password_cubit.dart';
import '../cubit/forget_password_state.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final ForgetPasswordCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = di.sl<ForgetPasswordCubit>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _handleSendOtp() {
    if (_formKey.currentState!.validate()) {
      _cubit.sendOtp(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
          if (state is SendOtpSuccess) {
            Navigator.of(context).pushNamed(
              AppRoutes.forgetPasswordOtp,
              arguments: _emailController.text,
            );
          } else if (state is SendOtpError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ForgetPasswordLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        AppTexts.forgotPassword,
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Enter your email address and we\'ll send you a 6-digit OTP code to reset your password.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      AppTextField(
                        controller: _emailController,
                        hint: AppTexts.emailAddress,
                        keyboardType: TextInputType.emailAddress,
                        leadingIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTexts.pleaseEnterEmail;
                          }
                          if (!value.contains('@')) {
                            return AppTexts.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32.h),
                      PrimaryButton(
                        title: 'Send OTP',
                        onPressed: isLoading ? null : _handleSendOtp,
                        isLoading: isLoading,
                      ),
                      SizedBox(height: 16.h),
                      SecondaryButton(
                        title: AppTexts.backToLogin,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icons.arrow_back,
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


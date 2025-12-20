import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/di/inject.dart' as di;
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../cubit/forget_password_cubit.dart';
import '../cubit/forget_password_state.dart';

class ForgetPasswordResetScreen extends StatefulWidget {
  final String email;

  const ForgetPasswordResetScreen({super.key, required this.email});

  @override
  State<ForgetPasswordResetScreen> createState() => _ForgetPasswordResetScreenState();
}

class _ForgetPasswordResetScreenState extends State<ForgetPasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final ForgetPasswordCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = di.sl<ForgetPasswordCubit>();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      _cubit.resetPassword(
        widget.email,
        _passwordController.text,
        _confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            AppToast.showSuccess(state.message);
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          } else if (state is ResetPasswordError) {
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
          final isLoading = state is ResetPasswordLoading;

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
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Enter your new password below.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      AppTextField(
                        controller: _passwordController,
                        hint: 'New Password',
                        obscure: true,
                        obscurable: true,
                        leadingIcon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTexts.pleaseEnterPassword;
                          }
                          if (value.length < 6) {
                            return AppTexts.shortPassword;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      AppTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm New Password',
                        obscure: true,
                        obscurable: true,
                        leadingIcon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32.h),
                      PrimaryButton(
                        title: 'Reset Password',
                        onPressed: isLoading ? null : _handleResetPassword,
                        isLoading: isLoading,
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


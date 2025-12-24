import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_assets.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/di/inject.dart' as di;
import '../../../../shared/widgets/app_toast.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import 'widgets/login_segmented_control.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginCubit _loginCubit;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loginCubit = di.sl<LoginCubit>();
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _loginCubit.close();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _loginCubit.login(_emailOrPhoneController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _loginCubit,
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else if (state is LoginError) {
            print("Login Error: ${state.message}");

            AppToast.showError(state.message, context: context);
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Image.asset(
                        AppAssets.appLogoBlueHeaderImg,
                        height: 180.h,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: 20.h),
                      LoginSegmentedControl(
                        selectedIndex: _selectedIndex,
                        onIndexChanged: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),

                      SizedBox(height: 32.h),

                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.background.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: _emailOrPhoneController,
                              hint: _selectedIndex == 0
                                  ? AppTexts.emailAddress
                                  : AppTexts.phoneNumber,
                              keyboardType: _selectedIndex == 0
                                  ? TextInputType.emailAddress
                                  : TextInputType.phone,
                              leadingIcon: _selectedIndex == 0
                                  ? Icons.email_outlined
                                  : Icons.phone_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _selectedIndex == 0
                                      ? AppTexts.pleaseEnterEmail
                                      : AppTexts.pleaseEnterPhoneNumber;
                                }
                                if (_selectedIndex == 0 &&
                                    !value.contains('@')) {
                                  return AppTexts.invalidEmail;
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 20.h),
                            AppTextField(
                              controller: _passwordController,
                              hint: AppTexts.password,
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
                            16.verticalSpace,
                            Bounce(
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.forgetPassword);
                              },
                              child: Text(
                                AppTexts.forgotPassword,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      PrimaryButton(
                        title: AppTexts.login,
                        onPressed: isLoading ? null : _handleLogin,
                        isLoading: isLoading,
                      ),

                      SizedBox(height: 24.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppTexts.newHere,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Bounce(
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.signup);
                            },
                            child: Text(
                              AppTexts.register,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
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

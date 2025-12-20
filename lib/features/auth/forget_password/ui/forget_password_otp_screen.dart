import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/di/inject.dart' as di;
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../cubit/forget_password_cubit.dart';
import '../cubit/forget_password_state.dart';
import '../widgets/otp_input_widget.dart';

class ForgetPasswordOtpScreen extends StatefulWidget {
  final String email;

  const ForgetPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgetPasswordOtpScreen> createState() => _ForgetPasswordOtpScreenState();
}

class _ForgetPasswordOtpScreenState extends State<ForgetPasswordOtpScreen> {
  late final ForgetPasswordCubit _cubit;
  int? _otp;

  @override
  void initState() {
    super.initState();
    _cubit = di.sl<ForgetPasswordCubit>();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _handleVerifyOtp() {
    if (_otp != null) {
      _cubit.verifyOtp(widget.email, _otp!);
    }
  }

  void _handleResendOtp() {
    _cubit.sendOtp(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
          if (state is VerifyOtpSuccess) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.forgetPasswordReset,
              arguments: widget.email,
            );
          } else if (state is VerifyOtpError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is SendOtpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
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
          final isLoading = state is VerifyOtpLoading;
          final isResending = state is ForgetPasswordLoading;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter the 6-digit code sent to ${widget.email}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    OtpInputWidget(
                      onCompleted: (otp) {
                        setState(() {
                          _otp = otp;
                        });
                        _handleVerifyOtp();
                      },
                      onChanged: (value) {
                        if (value.length == 6) {
                          setState(() {
                            _otp = int.parse(value);
                          });
                        } else {
                          setState(() {
                            _otp = null;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 32.h),
                    PrimaryButton(
                      title: 'Verify OTP',
                      onPressed: (isLoading || _otp == null) ? null : _handleVerifyOtp,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code? ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: isResending ? null : _handleResendOtp,
                          child: isResending
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Resend',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SecondaryButton(
                      title: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icons.arrow_back,
                    ),
                    SizedBox(height: 32.h),
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


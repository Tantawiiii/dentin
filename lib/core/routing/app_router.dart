import 'package:dentin/features/auth/login/ui/login_screen.dart';
import 'package:dentin/features/auth/register/register_screen.dart';
import 'package:dentin/features/auth/register/verification_screen.dart';
import 'package:dentin/features/auth/forget_password/ui/forget_password_screen.dart';
import 'package:dentin/features/auth/forget_password/ui/forget_password_otp_screen.dart';
import 'package:dentin/features/auth/forget_password/ui/forget_password_reset_screen.dart';
import 'package:dentin/features/home/main_navigation_screen.dart';
import 'package:dentin/features/onboarding/onboarding_screen.dart';
import 'package:dentin/features/onboarding/splash_screen.dart';
import 'package:dentin/features/profile/ui/profile_screen.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';

Route<dynamic> onGenerateAppRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());

    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());

    case AppRoutes.signup:
      return MaterialPageRoute(builder: (_) => const RegisterScreen());

    case AppRoutes.verification:
      final email = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (_) => VerificationScreen(email: email),
      );

    case AppRoutes.forgetPassword:
      return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());

    case AppRoutes.forgetPasswordOtp:
      final email = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (_) => ForgetPasswordOtpScreen(email: email),
      );

    case AppRoutes.forgetPasswordReset:
      final email = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (_) => ForgetPasswordResetScreen(email: email),
      );

    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const MainNavigationScreen());

    case AppRoutes.profile:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());

    default:
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Route not found'))),
      );
  }
}

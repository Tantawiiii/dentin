import 'package:dentin/features/auth/login/ui/login_screen.dart';
import 'package:dentin/features/auth/register/register_screen.dart';
import 'package:dentin/features/onboarding/onboarding_screen.dart';
import 'package:dentin/features/onboarding/splash_screen.dart';
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

    default:
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Route not found'))),
      );
  }
}


import 'package:flutter/material.dart';

final class AppColors {

  static const Color primary = Color(0xFF039fb3);
  static const Color primaryDark = Color(0xFF0891B2);
  static const Color primaryLight = Color(0xFF22D3EE);
  static const Color primaryTeal = Color(0xFF14B8A6);
  

  static const Color secondary = Color(0xFFFCD34D);
  static const Color secondaryOrange = Color(0xFFF97316);
  static const Color secondaryRed = Color(0xFFEF4444);
  

  static const Color accent = Color(0xFFEC4899);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentPink = Color(0xFFF472B6);
  

  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color surfaceElevated = Color(0xFFE9ECEF);
  

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFF1A1A1A);
  

  static const Color border = Color(0xFFDEE2E6);
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFE9ECEF);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  
  // Shadow Colors - Light Theme (lighter shadows)
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  static const Color shadowGlow = Color(0x2006B6D4); // Light Cyan glow
  
  // Overlay Colors - Light Theme
  static const Color overlay = Color(0x40000000);
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x20000000);
  
  // Splash & Onboarding - Light Theme
  static const Color splashBackground = Color(0xFFFFFFFF);
  
  // Legacy Support (for gradual migration)
  static const Color primaryColor = primary;
  static const Color blackTextColor = textPrimary;
  static const Color greyTextColor = textSecondary;
  static const Color shadowColor = shadowMedium;
  static const Color errorBorderColor = error;
  static const Color textFieldBorderColor = border;
  static const Color whiteBackground = background; // White background
  static Color warningColor = warning.withAlpha(100);
  static Color overlayColor = overlay;
  static Color white = background; // White
  
  // Premium Gradient Helpers - Based on Logo Colors
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryTeal],
    stops: [0.0, 1.0],
  );
  
  static LinearGradient get secondaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryOrange],
    stops: [0.0, 1.0],
  );
  
  static LinearGradient get accentGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentPink],
    stops: [0.0, 1.0],
  );
  
  static LinearGradient get purpleGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPurple, accent],
    stops: [0.0, 1.0],
  );
  
  // Multi-color gradient (I-A-M inspired)
  static LinearGradient get brandGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondaryOrange, accent],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Horizontal gradient (Software Publishing text style)
  static LinearGradient get horizontalGradient => const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, accentPink],
    stops: [0.0, 1.0],
  );
  
  // Shimmer gradient for loading states
  static LinearGradient get shimmerGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      surfaceVariant,
      surfaceElevated,
      surfaceVariant,
    ],
    stops: const [0.0, 0.5, 1.0],
  );
  
  // Glass morphism gradient
  static LinearGradient get glassGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      surface.withOpacity(0.8),
      surfaceVariant.withOpacity(0.6),
    ],
  );
}
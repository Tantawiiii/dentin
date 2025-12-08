import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';

class DocumentsStep extends StatelessWidget {
  const DocumentsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppTexts.documentsStepComingSoon,
        style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
      ),
    );
  }
}



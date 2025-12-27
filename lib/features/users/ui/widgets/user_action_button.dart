import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isDisabled;

  const UserActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDisabled) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12.sp, color: Colors.white),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12.sp, color: Colors.white),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


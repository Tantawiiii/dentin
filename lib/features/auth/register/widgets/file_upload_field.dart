import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/constant/app_font_sizes.dart';

class FileUploadField extends StatelessWidget {
  const FileUploadField({
    super.key,
    required this.label,
    this.file,
    this.imageUrl,
    this.error,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final File? file;
  final String? imageUrl; // URL for existing image/document
  final String? error;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
            fontSize: AppFontSizes.titleMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          AppTexts.uploadFile,
          style: TextStyle(
            fontSize: AppFontSizes.bodySmall,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: error != null ? AppColors.error : AppColors.border,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: (file != null || imageUrl != null)
                ? Stack(
                    children: [
                      _buildImageOrFile(file, imageUrl),
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColors.textOnPrimary,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppTexts.clickToUpload,
                          style: TextStyle(
                            fontSize: AppFontSizes.bodySmall,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (error != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              error!,
              style: TextStyle(
                fontSize: AppFontSizes.bodySmall,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _isImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  IconData _getFileIcon(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  Widget _buildImageOrFile(File? file, String? imageUrl) {
    // If there's a new file, use it; otherwise use the URL
    if (file != null) {
      if (_isImageFile(file)) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Image.file(
            file,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFileIcon(file.path),
                size: 48.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 8.h),
              Text(
                _getFileName(file.path),
                style: TextStyle(
                  fontSize: AppFontSizes.bodySmall,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }
    } else if (imageUrl != null) {
      // Display image from URL
      final isImage = _isImageUrl(imageUrl);
      if (isImage) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.surfaceVariant,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surfaceVariant,
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48.sp,
              ),
            ),
          ),
        );
      } else {
        // Document file from URL
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFileIconFromUrl(imageUrl),
                size: 48.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 8.h),
              Text(
                _getFileNameFromUrl(imageUrl),
                style: TextStyle(
                  fontSize: AppFontSizes.bodySmall,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  bool _isImageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.png') ||
        lowerUrl.contains('.gif') ||
        lowerUrl.contains('.bmp') ||
        lowerUrl.contains('.webp');
  }

  IconData _getFileIconFromUrl(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (lowerUrl.contains('.doc') || lowerUrl.contains('.docx')) {
      return Icons.description;
    } else if (lowerUrl.contains('.xls') || lowerUrl.contains('.xlsx')) {
      return Icons.table_chart;
    } else if (lowerUrl.contains('.ppt') || lowerUrl.contains('.pptx')) {
      return Icons.slideshow;
    }
    return Icons.insert_drive_file;
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      return path.split('/').last;
    } catch (e) {
      return url.split('/').last;
    }
  }
}


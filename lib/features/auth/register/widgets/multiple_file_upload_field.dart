import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';

class MultipleFileUploadField extends StatelessWidget {
  const MultipleFileUploadField({
    super.key,
    required this.label,
    required this.files,
    this.imageUrls,
    this.error,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final List<File> files;
  final List<String>? imageUrls; // URLs for existing images/documents
  final String? error;
  final VoidCallback onTap;
  final Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (error != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              error!,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 8.h),
        Text(
          AppTexts.uploadFile,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: error != null ? AppColors.error : AppColors.border,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: files.isEmpty && (imageUrls == null || imageUrls!.isEmpty)
                ? Center(
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
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(8.w),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: files.length + (imageUrls?.length ?? 0),
                      itemBuilder: (context, index) {
                        // Show files first, then URLs
                        if (index < files.length) {
                          final file = files[index];
                          final isImage = _isImageFile(file);
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: isImage
                                    ? Image.file(
                                        file,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: AppColors.surfaceVariant,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _getFileIcon(file.path),
                                              size: 24.sp,
                                              color: AppColors.primary,
                                            ),
                                            SizedBox(height: 4.h),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4.w,
                                              ),
                                              child: Text(
                                                _getFileName(file.path),
                                                style: TextStyle(
                                                  fontSize: 8.sp,
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              Positioned(
                                top: 4.h,
                                right: 4.w,
                                child: GestureDetector(
                                  onTap: () => onRemove(index),
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.textOnPrimary,
                                      size: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Show URL images
                          final urlIndex = index - files.length;
                          final url = imageUrls![urlIndex];
                          final isImage = _isImageUrl(url);
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: isImage
                                    ? CachedNetworkImage(
                                        imageUrl: url,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: AppColors.surfaceVariant,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primary,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: AppColors.surfaceVariant,
                                          child: Icon(
                                            Icons.error_outline,
                                            color: AppColors.error,
                                            size: 24.sp,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: AppColors.surfaceVariant,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _getFileIconFromUrl(url),
                                              size: 24.sp,
                                              color: AppColors.primary,
                                            ),
                                            SizedBox(height: 4.h),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4.w,
                                              ),
                                              child: Text(
                                                _getFileNameFromUrl(url),
                                                style: TextStyle(
                                                  fontSize: 8.sp,
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              Positioned(
                                top: 4.h,
                                right: 4.w,
                                child: GestureDetector(
                                  onTap: () => onRemove(index),
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.textOnPrimary,
                                      size: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
          ),
        ),
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


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/extensions/image_picker_extension.dart';
import '../../../../core/extensions/file_picker_extension.dart';
import 'file_upload_field.dart';
import 'multiple_file_upload_field.dart';
import 'image_source_dialog.dart';

class DocumentsStep extends StatefulWidget {
  const DocumentsStep({
    super.key,
    required this.formKey,
    this.profileImage,
    this.coverImage,
    this.graduationCertificate,
    this.cv,
    this.courseCertificates,
    this.onProfileImageChanged,
    this.onCoverImageChanged,
    this.onGraduationCertificateChanged,
    this.onCvChanged,
    this.onCourseCertificatesChanged,
    // URLs for existing images/documents
    this.profileImageUrl,
    this.coverImageUrl,
    this.graduationCertificateUrl,
    this.cvUrl,
    this.courseCertificatesUrls,
  });

  final GlobalKey<FormState> formKey;
  final File? profileImage;
  final File? coverImage;
  final File? graduationCertificate;
  final File? cv;
  final List<File>? courseCertificates;
  final Function(File?)? onProfileImageChanged;
  final Function(File?)? onCoverImageChanged;
  final Function(File?)? onGraduationCertificateChanged;
  final Function(File?)? onCvChanged;
  final Function(List<File>)? onCourseCertificatesChanged;
  // URLs for existing images/documents
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String? graduationCertificateUrl;
  final String? cvUrl;
  final List<String>? courseCertificatesUrls;

  @override
  State<DocumentsStep> createState() => DocumentsStepState();
}

class DocumentsStepState extends State<DocumentsStep> {
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.platform;
  String? _profileImageError;
  String? _coverImageError;
  String? _graduationCertificateError;
  String? _cvError;
  String? _courseCertificatesError;

  Future<void> _pickImage(ImageSource source, Function(File?) onChanged) async {
    final file = await _imagePicker.pickImageFile(source: source);
    if (file != null) {
      onChanged(file);
      _clearErrors();
    }
  }

  Future<void> _pickFile(
    Function(File?) onChanged, {
    List<String>? allowedExtensions,
  }) async {
    final file = await _filePicker.pickFile(
      allowedExtensions: allowedExtensions,
    );
    if (file != null) {
      onChanged(file);
      _clearErrors();
    }
  }

  Future<void> _pickMultipleFiles(
    Function(List<File>) onChanged, {
    List<String>? allowedExtensions,
  }) async {
    final files = await _filePicker.pickMultipleFiles(
      allowedExtensions: allowedExtensions,
    );
    if (files.isNotEmpty) {
      onChanged(files);
      _clearErrors();
    }
  }

  void _clearErrors() {
    setState(() {
      _profileImageError = null;
      _coverImageError = null;
      _graduationCertificateError = null;
      _cvError = null;
      _courseCertificatesError = null;
    });
  }

  String? _validateProfileImage() {
    if (widget.profileImage == null && widget.profileImageUrl == null) {
      setState(() {
        _profileImageError = AppTexts.profileImageRequired;
      });
      return AppTexts.profileImageRequired;
    }
    return null;
  }

  String? _validateCoverImage() {
    if (widget.coverImage == null && widget.coverImageUrl == null) {
      setState(() {
        _coverImageError = AppTexts.coverImageRequired;
      });
      return AppTexts.coverImageRequired;
    }
    return null;
  }

  String? _validateGraduationCertificate() {
    if (widget.graduationCertificate == null &&
        widget.graduationCertificateUrl == null) {
      setState(() {
        _graduationCertificateError = AppTexts.graduationCertificateRequired;
      });
      return AppTexts.graduationCertificateRequired;
    }
    return null;
  }

  String? _validateCv() {
    if (widget.cv == null && widget.cvUrl == null) {
      setState(() {
        _cvError = AppTexts.cvRequired;
      });
      return AppTexts.cvRequired;
    }
    return null;
  }

  String? _validateCourseCertificates() {
    final hasFiles = widget.courseCertificates != null &&
        widget.courseCertificates!.isNotEmpty;
    final hasUrls = widget.courseCertificatesUrls != null &&
        widget.courseCertificatesUrls!.isNotEmpty;
    if (!hasFiles && !hasUrls) {
      setState(() {
        _courseCertificatesError = AppTexts.courseCertificatesRequired;
      });
      return AppTexts.courseCertificatesRequired;
    }
    return null;
  }

  bool validate() {
    bool isValid = true;
    if (_validateProfileImage() != null) isValid = false;
    if (_validateCoverImage() != null) isValid = false;
    if (_validateGraduationCertificate() != null) isValid = false;
    if (_validateCv() != null) isValid = false;
    if (_validateCourseCertificates() != null) isValid = false;
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  AppTexts.documentsAndCertificates,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            FileUploadField(
              label: AppTexts.profileImage,
              file: widget.profileImage,
              imageUrl: widget.profileImageUrl,
              error: _profileImageError,
              onTap: () => ImageSourceDialog.show(
                context,
                onCameraSelected: () => _pickImage(
                  ImageSource.camera,
                  (file) => widget.onProfileImageChanged?.call(file),
                ),
                onGallerySelected: () => _pickImage(
                  ImageSource.gallery,
                  (file) => widget.onProfileImageChanged?.call(file),
                ),
              ),
              onRemove: () {
                widget.onProfileImageChanged?.call(null);
                _clearErrors();
              },
            ),
            SizedBox(height: 20.h),
            FileUploadField(
              label: AppTexts.coverImage,
              file: widget.coverImage,
              imageUrl: widget.coverImageUrl,
              error: _coverImageError,
              onTap: () => ImageSourceDialog.show(
                context,
                onCameraSelected: () => _pickImage(
                  ImageSource.camera,
                  (file) => widget.onCoverImageChanged?.call(file),
                ),
                onGallerySelected: () => _pickImage(
                  ImageSource.gallery,
                  (file) => widget.onCoverImageChanged?.call(file),
                ),
              ),
              onRemove: () {
                widget.onCoverImageChanged?.call(null);
                _clearErrors();
              },
            ),
            SizedBox(height: 20.h),
            FileUploadField(
              label: AppTexts.graduationCertificate,
              file: widget.graduationCertificate,
              imageUrl: widget.graduationCertificateUrl,
              error: _graduationCertificateError,
              onTap: () => _pickFile(
                (file) => widget.onGraduationCertificateChanged?.call(file),
                allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
              ),
              onRemove: () {
                widget.onGraduationCertificateChanged?.call(null);
                _clearErrors();
              },
            ),
            SizedBox(height: 20.h),
            FileUploadField(
              label: AppTexts.cv,
              file: widget.cv,
              imageUrl: widget.cvUrl,
              error: _cvError,
              onTap: () => _pickFile(
                (file) => widget.onCvChanged?.call(file),
                allowedExtensions: ['pdf', 'doc', 'docx'],
              ),
              onRemove: () {
                widget.onCvChanged?.call(null);
                _clearErrors();
              },
            ),
            SizedBox(height: 20.h),

            MultipleFileUploadField(
              label: AppTexts.courseCertificates,
              files: widget.courseCertificates ?? [],
              imageUrls: widget.courseCertificatesUrls,
              error: _courseCertificatesError,
              onTap: () => _pickMultipleFiles(
                (files) => widget.onCourseCertificatesChanged?.call(files),
                allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
              ),
              onRemove: (index) {
                final updated = List<File>.from(
                  widget.courseCertificates ?? [],
                );
                updated.removeAt(index);
                widget.onCourseCertificatesChanged?.call(updated);
                _clearErrors();
              },
            ),
          ],
        ),
      ),
    );
  }
}

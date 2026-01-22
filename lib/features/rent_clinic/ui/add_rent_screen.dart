import 'dart:io';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/register/data/repo/register_repository.dart';
import '../cubit/rent_cubit.dart';
import '../cubit/rent_state.dart';
import '../data/models/rent_models.dart';

class AddRentScreen extends StatefulWidget {
  const AddRentScreen({super.key});

  @override
  State<AddRentScreen> createState() => _AddRentScreenState();
}

class _AddRentScreenState extends State<AddRentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  final List<File> _selectedImages = [];
  final List<int> _uploadedImageIds = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  late final RegisterRepository _registerRepository;

  @override
  void initState() {
    super.initState();
    _registerRepository = di.sl<RegisterRepository>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _isPicking = false;

  Future<void> _pickImages() async {
    if (_isPicking) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            images.map((xFile) => File(xFile.path)).toList(),
          );
        });
      }
    } catch (e) {
      if (kDebugMode && e is! PlatformException) {
        print('Error picking images: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    _uploadedImageIds.clear();
    final totalImages = _selectedImages.length;

    for (int i = 0; i < _selectedImages.length; i++) {
      try {
        final response = await _registerRepository.uploadMedia(
          _selectedImages[i],
          onSendProgress: (sent, total) {
            final imageProgress = sent / total;
            final overallProgress = (i + imageProgress) / totalImages;
            setState(() {
              _uploadProgress = overallProgress;
            });
          },
        );

        if (response.data != null) {
          _uploadedImageIds.add(response.data!.id);
        }
      } catch (e) {
        AppToast.showError(
          '${AppTexts.failedToUploadImage} ${i + 1}',
          context: context,
        );
      }
    }

    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      AppToast.showError(AppTexts.rentGalleryRequired, context: context);
      return;
    }

    await _uploadImages();

    if (_uploadedImageIds.isEmpty) {
      AppToast.showError(AppTexts.failedToUploadImages, context: context);
      return;
    }

    final request = CreateRentRequest(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      des: _descriptionController.text.trim(),
      gallery: _uploadedImageIds,
      type: 'rent',
      duration: _durationController.text.trim(),
      startDate: _startDateController.text.trim().isEmpty
          ? null
          : _startDateController.text.trim(),
      endDate: _endDateController.text.trim().isEmpty
          ? null
          : _endDateController.text.trim(),
      governorate: _governorateController.text.trim().isEmpty
          ? null
          : _governorateController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
    );

    context.read<RentCubit>().createRent(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RentCubit, RentState>(
      listener: (context, state) {
        if (state is RentCreated) {
          AppToast.showSuccess(
            AppTexts.rentCreatedSuccessfully,
            context: context,
          );
          Navigator.of(context).pop();
        } else if (state is RentCreateError) {
          print("RentCreateError${state.message}");
          AppToast.showError(state.message, context: context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            AppTexts.addNewRent,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppTexts.rentName} *',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _nameController,
                  hint: AppTexts.enterRentName,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppTexts.rentNameRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  '${AppTexts.rentPrice} *',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _priceController,
                  hint: AppTexts.enterPrice,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppTexts.rentPriceRequired;
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return AppTexts.rentPriceInvalid;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  '${AppTexts.rentDescription} *',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _descriptionController,
                  hint: AppTexts.enterDescription,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppTexts.rentDescriptionRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  '${AppTexts.rentDuration} *',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _durationController,
                  hint: AppTexts.enterDurationInDays,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppTexts.rentDurationRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.rentStartDate,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          AppTextField(
                            controller: _startDateController,
                            hint: AppTexts.dateFormatPlaceholder,
                            readOnly: true,
                            onTap: _selectStartDate,
                            leadingIcon: Icons.calendar_today,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.rentEndDate,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          AppTextField(
                            controller: _endDateController,
                            hint: AppTexts.dateFormatPlaceholder,
                            readOnly: true,
                            onTap: _selectEndDate,
                            leadingIcon: Icons.calendar_today,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.rentGovernorate,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          AppTextField(
                            controller: _governorateController,
                            hint: AppTexts.governoratePlaceholder,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.rentCity,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          AppTextField(
                            controller: _cityController,
                            hint: AppTexts.cityPlaceholder,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  AppTexts.rentAddress,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _addressController,
                  hint: AppTexts.enterAddress,
                ),
                SizedBox(height: 24.h),
                Text(
                  '${AppTexts.rentGallery} *',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Bounce(
                  onTap: _pickImages,
                  child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: _selectedImages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40.sp,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  AppTexts.selectImages,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.all(8.w),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8.w,
                                  mainAxisSpacing: 8.h,
                                ),
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.file(
                                      _selectedImages[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4.h,
                                    right: 4.w,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4.w),
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16.sp,
                                          color: AppColors.textOnPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
                if (_isUploading) ...[
                  SizedBox(height: 16.h),
                  LinearProgressIndicator(value: _uploadProgress),
                  SizedBox(height: 8.h),
                  Text(
                    '${AppTexts.uploadingImages} ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                SizedBox(height: 32.h),
                BlocBuilder<RentCubit, RentState>(
                  builder: (context, state) {
                    final isCreating = state is RentCreating;
                    return PrimaryButton(
                      title: AppTexts.submit,
                      onPressed: isCreating ? null : _submitForm,
                      isLoading: isCreating,
                    );
                  },
                ),
                60.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

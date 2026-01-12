import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/extensions/image_picker_extension.dart';
import '../../core/di/inject.dart' as di;
import '../../shared/widgets/app_toast.dart';
import 'data/models/product_models.dart';
import 'data/repo/product_repository.dart';
import '../auth/register/widgets/image_source_dialog.dart';
import '../auth/register/data/repo/register_repository.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  final ProductRepository _productRepository = di.sl<ProductRepository>();
  final RegisterRepository _registerRepository = di.sl<RegisterRepository>();

  List<File> _imageFiles = [];
  Map<int, double> _uploadProgress = {};
  bool _isNew = true;
  bool _isSubmitting = false;
  String? _selectedType;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    ImageSourceDialog.show(
      context,
      onCameraSelected: () async {
        final file = await _imagePicker.pickImageFile(
          source: ImageSource.camera,
        );
        if (file != null) {
          setState(() {
            _imageFiles.add(file);
          });
        }
      },
      onGallerySelected: () async {
        final files = await _imagePicker.pickMultipleImageFiles();
        if (files.isNotEmpty) {
          setState(() {
            _imageFiles.addAll(files);
          });
        }
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    if (_imageFiles.isEmpty) {
      AppToast.showError(AppTexts.productImageRequired, context: context);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final List<int> galleryIds = [];
      _uploadProgress.clear();

      for (int index = 0; index < _imageFiles.length; index++) {
        if (!mounted) return;
        setState(() {
          _uploadProgress[index] = 0.1;
        });

        final imageFile = _imageFiles[index];

        final mediaResponse = await _registerRepository.uploadMedia(imageFile);

        if (mounted) {
          setState(() {
            _uploadProgress[index] = 0.9;
          });
        }

        final imageId = mediaResponse.data?.id;

        if (imageId == null) {
          throw Exception('Failed to upload image ${index + 1}');
        }

        galleryIds.add(imageId);

        if (mounted) {
          setState(() {
            _uploadProgress[index] = 1.0;
          });
        }
      }

      if (galleryIds.isEmpty) {
        throw Exception('No images were uploaded');
      }

      // Clear progress after all uploads complete
      if (mounted) {
        setState(() {
          _uploadProgress.clear();
        });
      }

      final price = num.tryParse(_priceController.text.trim()) ?? 0;
      final discount = num.tryParse(_discountController.text.trim()) ?? 0;

      if (_selectedType == null) {
        AppToast.showError(AppTexts.productTypeRequired, context: context);
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final request = CreateProductRequest(
        name: _nameController.text.trim(),
        type: _selectedType!,
        price: price,
        discount: discount,
        description: _descriptionController.text.trim(),
        gallery: galleryIds,
        isNew: _isNew,
      );

      await _productRepository.createProduct(request);

      if (!mounted) return;

      AppToast.showSuccess(
        AppTexts.productCreatedSuccessfully,
        context: context,
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      print("Error: $e");
      // Clear progress on error
      setState(() {
        _uploadProgress.clear();
      });
      AppToast.showError(
        e.toString().replaceFirst('Exception: ', ''),
        context: context,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadProgress.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppTexts.addProduct , style: TextStyle(
          fontSize: 18.sp
        ),),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_imageFiles.isNotEmpty)
                SizedBox(
                  height: 160.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, index) {
                      final progress = _uploadProgress[index] ?? 0.0;
                      final isUploading = _isSubmitting && progress < 1.0;

                      return Container(
                        margin: EdgeInsets.only(right: 8.w),
                        width: 160.w,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Image.file(
                                _imageFiles[index],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Upload progress overlay
                            if (isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: progress > 0 ? progress : null,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.primary,
                                            ),
                                        strokeWidth: 3,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        '${(progress * 100).toInt()}%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
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
                                onTap: isUploading
                                    ? null
                                    : () => _removeImage(index),
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: isUploading
                                        ? AppColors.textSecondary
                                        : AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              if (_imageFiles.isNotEmpty) SizedBox(height: 12.h),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 160.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 40.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppTexts.productImageTapToAdd,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_imageFiles.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          '(${_imageFiles.length} ${_imageFiles.length == 1 ? 'image' : 'images'})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppTexts.productName,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.productNameRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: AppTexts.productPrice,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.productPriceRequired;
                  }
                  if (num.tryParse(value.trim()) == null) {
                    return AppTexts.productPriceInvalid;
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: AppTexts.productDiscount,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.productDiscountRequired;
                  }
                  if (num.tryParse(value.trim()) == null) {
                    return AppTexts.productDiscountInvalid;
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: AppTexts.productDescriptionLabel,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.productDescriptionRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: AppTexts.productType,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'person',
                    child: Text(AppTexts.productTypePerson),
                  ),
                  DropdownMenuItem(
                    value: 'company',
                    child: Text(AppTexts.productTypeCompany),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppTexts.productTypeRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Switch(
                    value: _isNew,
                    onChanged: (v) {
                      setState(() {
                        _isNew = v;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppTexts.productIsNewLabel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          AppTexts.submit,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 44.h),
            ],
          ),
        ),
      ),
    );
  }
}

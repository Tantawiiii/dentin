import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/extensions/image_picker_extension.dart';
import '../../core/di/inject.dart' as di;
import '../../shared/widgets/app_toast.dart';
import '../../features/home/data/repo/post_repository.dart';
import 'data/models/product_models.dart';
import 'data/repo/product_repository.dart';
import '../auth/register/widgets/image_source_dialog.dart';

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
  final PostRepository _postRepository = di.sl<PostRepository>();

  File? _imageFile;
  bool _isNew = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    ImageSourceDialog.show(
      context,
      onCameraSelected: () async {
        final file = await _imagePicker.pickImageFile(
          source: ImageSource.camera,
        );
        if (file != null) {
          setState(() {
            _imageFile = file;
          });
        }
      },
      onGallerySelected: () async {
        final file = await _imagePicker.pickImageFile(
          source: ImageSource.gallery,
        );
        if (file != null) {
          setState(() {
            _imageFile = file;
          });
        }
      },
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      AppToast.showError(AppTexts.productImageRequired, context: context);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final mediaResponse = await _postRepository.uploadMedia(_imageFile!);
      final imageId = mediaResponse.data?.id;

      if (imageId == null) {
        throw Exception('Failed to upload image');
      }

      final price = num.tryParse(_priceController.text.trim()) ?? 0;
      final discount = num.tryParse(_discountController.text.trim()) ?? 0;

      final request = CreateProductRequest(
        name: _nameController.text.trim(),
        price: price,
        discount: discount,
        description: _descriptionController.text.trim(),
        image: imageId,
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
      AppToast.showError(
        e.toString().replaceFirst('Exception: ', ''),
        context: context,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.addProduct),
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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
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
            ],
          ),
        ),
      ),
    );
  }
}

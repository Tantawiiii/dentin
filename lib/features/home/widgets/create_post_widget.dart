import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/app_toast.dart';
import '../../../core/services/storage_service.dart';
import '../../../features/auth/login/data/models/login_response.dart';
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../cubit/post_cubit.dart';
import '../cubit/post_state.dart';

class CreatePostWidget extends StatefulWidget {
  final PostCubit postCubit;

  const CreatePostWidget({super.key, required this.postCubit});

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final FocusNode _contentFocusNode = FocusNode();

  File? _selectedImage;
  File? _selectedVideo;
  List<File> _selectedGallery = [];
  bool _isAdRequest = false;
  bool _isCreating = false;

  UserData? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final storageService = di.sl<StorageService>();
    setState(() {
      _userData = storageService.getUserData();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedVideo = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        _selectedImage = null;
      });
    }
  }

  void _clearMedia() {
    setState(() {
      _selectedImage = null;
      _selectedVideo = null;
      _selectedGallery = [];
    });
  }

  Future<void> _createPost() async {
    if (_selectedImage == null &&
        _selectedVideo == null &&
        _selectedGallery.isEmpty &&
        (_contentController.text.trim().isEmpty)) {
      AppToast.showError(AppTexts.pleaseAddContentOrMedia, context: context);
      return;
    }

    if (_isCreating) return;

    _contentFocusNode.unfocus();

    setState(() {
      _isCreating = true;
    });

    widget.postCubit.createPost(
      content: _contentController.text.trim().isNotEmpty
          ? _contentController.text.trim()
          : null,
      imageFile: _selectedImage,
      videoFile: _selectedVideo,
      galleryFiles: _selectedGallery.isNotEmpty ? _selectedGallery : null,
      isAdRequest: _isAdRequest,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostCubit, PostState>(
      bloc: widget.postCubit,
      listener: (context, state) {
        if (!mounted) return;

        if (state is PostCreating) {
          setState(() {
            _isCreating = true;
          });
        } else if (state is PostCreated) {
          final wasAdRequest = _isAdRequest;
          _contentController.clear();
          _clearMedia();
          _isAdRequest = false;
          setState(() {
            _isCreating = false;
          });
          AppToast.showSuccess(
            wasAdRequest
                ? AppTexts.postAdWaitingApproval
                : AppTexts.postCreatedSuccessfully,
            context: context,
          );
        } else if (state is PostCreateError) {
          setState(() {
            _isCreating = false;
          });
          AppToast.showError(state.message, context: context);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: _userData?.profileImage != null
                      ? CachedNetworkImage(
                          imageUrl: _userData!.profileImage!,
                          width: 40.w,
                          height: 40.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => ShimmerPlaceholder(
                            width: 40.w,
                            height: 40.w,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 40.w,
                            height: 40.w,
                            color: AppColors.surface,
                            child: Icon(
                              Icons.person,
                              size: 24.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : Container(
                          width: 40.w,
                          height: 40.w,
                          color: AppColors.surface,
                          child: Icon(
                            Icons.person,
                            size: 24.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    decoration: InputDecoration(
                      hintText: AppTexts.whatsOnYourMind,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: null,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 12.h),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppTexts.promoteAsAd,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppTexts.requestToPromotePost,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Switch(
                    value: _isAdRequest,
                    onChanged: (value) {
                      setState(() {
                        _isAdRequest = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 20.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppTexts.photo,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: _pickVideo,
                  child: Row(
                    children: [
                      Icon(
                        Icons.videocam,
                        size: 20.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppTexts.video,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
                ElevatedButton(
                  onPressed: _isCreating ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: _isCreating
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: ShimmerPlaceholder(
                            width: 16.w,
                            height: 16.w,
                            shape: BoxShape.circle,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 16.sp),
                            SizedBox(width: 4.w),
                            Text(
                              AppTexts.createPost,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            if (_selectedImage != null ||
                _selectedVideo != null ||
                _selectedGallery.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 12.h),
                height: 200.h,
                child: Stack(
                  children: [
                    _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _selectedVideo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black,
                                  child: Center(
                                    child: Icon(
                                      Icons.play_circle_filled,
                                      size: 64.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8.h,
                                  right: 8.w,
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.videocam,
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _selectedGallery.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedGallery.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 8.w),
                                width: 200.w,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.file(
                                    _selectedGallery[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          )
                        : const SizedBox(),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: _clearMedia,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
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
              ),
          ],
        ),
      ),
    );
  }
}

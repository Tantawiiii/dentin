import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../messages/data/models/chat_user_model.dart';
import '../../messages/data/models/send_message_request.dart';
import '../../messages/data/repo/chat_repository.dart';
import '../../messages/ui/chat_detail_screen.dart';
import '../data/models/rent_models.dart';

class ContactSellerScreen extends StatefulWidget {
  final RentItem rent;

  const ContactSellerScreen({super.key, required this.rent});

  @override
  State<ContactSellerScreen> createState() => _ContactSellerScreenState();
}

class _ContactSellerScreenState extends State<ContactSellerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final ChatRepository _chatRepository = di.sl<ChatRepository>();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final preFilledMessage =
        "Hello! I'm interested in your \"${widget.rent.name}\" for \$${widget.rent.price}";
    _messageController.text = preFilledMessage;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      final storageService = di.sl<StorageService>();
      final currentUser = storageService.getUserData();

      if (currentUser == null) {
        if (mounted) {
          AppToast.showError(
            AppTexts.pleaseLoginToSendMessage,
            context: context,
          );
        }
        return;
      }

      final request = SendMessageRequest(
        body: message,
        receiverId: widget.rent.user.id,
      );

      await _chatRepository.sendMessage(request);

      if (mounted) {
        Navigator.of(context).pop();

        // Navigate to chat screen
        final chatUser = ChatUser(
          id: widget.rent.user.id,
          userName: widget.rent.user.userName,
          profileImage: widget.rent.user.profileImage,
          createdAt: widget.rent.user.createdAt,
          updatedAt: widget.rent.user.updatedAt,
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(receiverUser: chatUser),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          e.toString().replaceFirst('Exception: ', ''),
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppTexts.contactSeller,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundImage: widget.rent.user.profileImage != null
                          ? NetworkImage(widget.rent.user.profileImage!)
                          : null,
                      backgroundColor: AppColors.surfaceVariant,
                      child: widget.rent.user.profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 30.sp,
                              color: AppColors.textSecondary,
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.rent.user.userName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${AppTexts.aboutTheRental} ${widget.rent.name}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                AppTexts.yourMessage,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              AppTextField(
                controller: _messageController,
                hint: AppTexts.typeYourMessage,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.pleaseEnterMessage;
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              // Product Details
              Text(
                AppTexts.productDetails,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductDetailRow(AppTexts.rentName, widget.rent.name),
                    SizedBox(height: 8.h),
                    _buildProductDetailRow(
                      AppTexts.rentPrice,
                      '\$${widget.rent.price}',
                    ),
                    SizedBox(height: 8.h),
                    _buildProductDetailRow(
                      AppTexts.rentDuration,
                      '${widget.rent.duration} ${AppTexts.rentDays}',
                    ),
                    SizedBox(height: 8.h),
                    _buildProductDetailRow(AppTexts.rentType, AppTexts.rental),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56.h,
                      child: SecondaryButton(
                        title: AppTexts.cancel,
                        onPressed: _isSending
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56.h,
                      child: PrimaryButton(
                        title: AppTexts.sendMessage,
                        onPressed: _isSending ? null : _sendMessage,
                        isLoading: _isSending,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

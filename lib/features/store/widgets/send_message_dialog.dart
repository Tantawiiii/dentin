import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/app_toast.dart';
import '../../../core/services/storage_service.dart';
import '../../messages/data/models/chat_user_model.dart';
import '../../messages/data/models/send_message_request.dart';
import '../../messages/data/repo/chat_repository.dart';
import '../../messages/ui/chat_detail_screen.dart';
import '../data/models/product_models.dart';

class SendMessageDialog extends StatefulWidget {
  final Product product;

  const SendMessageDialog({super.key, required this.product});

  @override
  State<SendMessageDialog> createState() => _SendMessageDialogState();
}

class _SendMessageDialogState extends State<SendMessageDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ChatRepository _chatRepository = di.sl<ChatRepository>();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    _messageController.text =
        "Hello, I'm interested in your product: ${widget.product.name}\nPrice: ${widget.product.priceAfterDiscount} EGP\nCan you tell me more about it?";
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
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
        receiverId: widget.product.user.id,
      );

      await _chatRepository.sendMessage(request);

      if (mounted) {
        Navigator.of(context).pop();

        // Navigate to chat screen
        final chatUser = ChatUser(
          id: widget.product.user.id,
          userName: widget.product.user.userName,
          profileImage: widget.product.user.profileImage.isNotEmpty
              ? widget.product.user.profileImage
              : null,
          createdAt: widget.product.user.createdAt,
          updatedAt: widget.product.user.updatedAt,
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
    final seller = widget.product.user;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                AppTexts.sendMessageToSeller,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),

              // Seller Info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: seller.profileImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: seller.profileImage,
                            width: 40.w,
                            height: 40.w,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 40.w,
                              height: 40.w,
                              color: AppColors.surfaceVariant,
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
                            color: AppColors.surfaceVariant,
                            child: Icon(
                              Icons.person,
                              size: 24.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      seller.userName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Divider
              Divider(color: AppColors.border),
              SizedBox(height: 16.h),

              // Product Info
              Text(
                AppTexts.aboutTheProduct,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '${widget.product.priceAfterDiscount} EGP - ${widget.product.name}',
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              ),
              SizedBox(height: 20.h),

              // Message Input
              TextField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: AppTexts.typeYourMessage,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(16.w),
                ),
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              ),
              SizedBox(height: 24.h),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: _isSending ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: _isSending
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            AppTexts.sendMessage,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
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
}

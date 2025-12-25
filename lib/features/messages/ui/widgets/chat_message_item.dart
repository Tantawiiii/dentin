import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/chat_message_model.dart';
import 'chat_file_message_widget.dart';
import 'chat_image_message_widget.dart';
import 'chat_product_info_widget.dart';
import 'chat_text_message_bubble.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  final int? currentUserId;
  final String Function(String?) formatTime;
  final String Function(int) formatFileSize;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.formatTime,
    required this.formatFileSize,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender.id == currentUserId;
    final isImage = message.type == MessageType.image;
    final isFile = message.type == MessageType.file;
    final isProduct = message.type == MessageType.product;

    return RepaintBoundary(
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (isProduct && message.productInfo != null)
                ChatProductInfoWidget(productInfo: message.productInfo!),
              if (isImage && message.fileUrl != null)
                ChatImageMessageWidget(imageUrl: message.fileUrl!),
              if (isFile && message.fileUrl != null)
                ChatFileMessageWidget(
                  fileName: message.fileName ?? 'File',
                  fileSize: message.fileSize,
                  formatFileSize: formatFileSize,
                ),
              ChatTextMessageBubble(
                message: message,
                isMe: isMe,
                formatTime: formatTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'chat_message_shimmer.dart';

class ChatMessagesShimmer extends StatelessWidget {
  final int messageCount;

  const ChatMessagesShimmer({super.key, this.messageCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: messageCount,
      itemBuilder: (context, index) {
        // Alternate between left and right aligned messages
        final isMe = index % 3 == 0 || index % 3 == 2;
        return ChatMessageShimmer(isMe: isMe);
      },
    );
  }
}

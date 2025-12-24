import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'conversation_item_shimmer.dart';

class ConversationListShimmer extends StatelessWidget {
  final int itemCount;

  const ConversationListShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemBuilder: (context, index) {
        return const ConversationItemShimmer();
      },
    );
  }
}

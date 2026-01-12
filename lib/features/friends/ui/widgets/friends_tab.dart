import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../cubit/friend_requests_cubit.dart';
import '../../data/models/friend_request_model.dart';
import 'friend_item.dart';

class FriendsTab extends StatelessWidget {
  final List<FriendRequest> friends;
  final bool isLoading;
  final int? currentUserId;
  final TextEditingController searchController;
  final String searchTerm;
  final void Function(int, String, String?) onChatTap;
  final FriendRequestsCubit friendRequestsCubit;

  const FriendsTab({
    super.key,
    required this.friends,
    required this.isLoading,
    required this.currentUserId,
    required this.searchController,
    required this.searchTerm,
    required this.onChatTap,
    required this.friendRequestsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final filteredFriends = searchTerm.isEmpty
        ? friends
        : friends.where((friend) {
            final otherUserName = friend.getOtherUserName(currentUserId!);
            return otherUserName.toLowerCase().contains(
              searchTerm.toLowerCase(),
            );
          }).toList();

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          color: AppColors.surface,
          child: AppTextField(
            controller: searchController,
            hint: AppTexts.searchFriends,
            leadingIcon: Icons.search,
          ),
        ),
        if (filteredFriends.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: AppColors.surface,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${filteredFriends.length} ${AppTexts.friendsCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (filteredFriends.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    searchTerm.isEmpty
                        ? Icons.people_outline
                        : Icons.search_off,
                    size: 80.sp,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    searchTerm.isEmpty
                        ? AppTexts.noFriendsYet
                        : AppTexts.noFriendsFound,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (searchTerm.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        AppTexts.tryDifferentSearchTerm,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              physics: const BouncingScrollPhysics(),
              cacheExtent: 500,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                return FriendItem(
                  key: ValueKey('friend_${friend.friendshipId}'),
                  friend: friend,
                  isLoading: isLoading,
                  currentUserId: currentUserId!,
                  onChatTap: onChatTap,
                  friendRequestsCubit: friendRequestsCubit,
                );
              },
            ),
          ),
      ],
    );
  }
}


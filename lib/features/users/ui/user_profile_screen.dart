import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/shimmer_placeholder.dart';
import '../../friends/cubit/friend_requests_cubit.dart';
import '../../friends/cubit/friend_requests_state.dart';
import '../../friends/data/models/friend_request_model.dart';
import '../../profile/data/models/profile_response.dart';
import '../../profile/ui/widgets/profile_about_tab.dart';
import '../../profile/ui/widgets/profile_posts_tab.dart';
import '../../profile/ui/widgets/profile_stat_item.dart';
import '../../messages/ui/chat_detail_screen.dart';
import '../../messages/data/models/chat_user_model.dart';
import '../data/repo/users_repository.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late FriendRequestsCubit _friendRequestsCubit;
  Doctor? _doctor;
  bool _isLoading = true;
  int? _currentUserId;
  FriendRequestStatus _friendStatus = FriendRequestStatus.none;
  StreamSubscription? _friendshipSubscription;

  @override
  void initState() {
    super.initState();
    _friendRequestsCubit = di.sl<FriendRequestsCubit>();

    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();
    _currentUserId = userData?.id;

    _loadProfile();
    _loadFriendStatus();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);
      final doctor = await di.sl<UsersRepository>().getUserProfile(
        widget.userId,
      );
      setState(() {
        _doctor = doctor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppToast.showError('Failed to load profile: $e', context: context);
      }
    }
  }

  void _loadFriendStatus() {
    if (_currentUserId == null) return;

    _friendRequestsCubit.loadFriendRequests();

    _friendshipSubscription = _friendRequestsCubit.stream.listen((state) {
      if (state is FriendRequestsLoaded) {
        setState(() {
          _friendStatus =
              state.friendStatusMap[widget.userId] ?? FriendRequestStatus.none;
        });
      }
    });
  }

  bool get _isOwnProfile => _currentUserId == widget.userId;

  void _handleFriendAction() {
    if (_isOwnProfile) return;

    switch (_friendStatus) {
      case FriendRequestStatus.none:
        _sendFriendRequest();
        break;
      case FriendRequestStatus.pending:
        final friendshipId = _getFriendshipId();
        if (friendshipId != null) {
          _cancelFriendRequest(friendshipId);
        }
        break;
      case FriendRequestStatus.friends:
        _removeFriend();
        break;
      default:
        _sendFriendRequest();
    }
  }

  void _sendFriendRequest() {
    _friendRequestsCubit.sendFriendRequest(widget.userId);
    AppToast.showSuccess('Friend request sent!', context: context);
  }

  void _cancelFriendRequest(String friendshipId) {
    _friendRequestsCubit.cancelFriendRequest(friendshipId);
    AppToast.showSuccess('Friend request cancelled', context: context);
  }

  void _removeFriend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.removeFriend),
        content: Text(
          '${AppTexts.removeFriendConfirmation} ${_doctor?.firstName ?? ''} ${AppTexts.removeFriendFromFriends}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final friendshipId = _getFriendshipId();
              if (friendshipId != null) {
                final removed = await _friendRequestsCubit.removeFriend(
                  friendshipId,
                  widget.userId,
                );

                if (!mounted) return;

                if (removed) {
                  setState(() => _friendStatus = FriendRequestStatus.none);
                  AppToast.showSuccess('Friend removed', context: context);
                } else {
                  AppToast.showError(
                    'Failed to remove friend. Please try again.',
                    context: context,
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppTexts.removeFriendButton),
          ),
        ],
      ),
    );
  }

  String? _getFriendshipId() {
    if (_currentUserId == null) return null;
    final sortedIds = [_currentUserId!, widget.userId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  void _openChat() {
    if (_doctor == null) return;

    final receiverUser = ChatUser(
      id: _doctor!.id,
      userName: _doctor!.userName,
      profileImage: _doctor!.profileImage,
      createdAt: '',
      updatedAt: '',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(receiverUser: receiverUser),
      ),
    );
  }

  @override
  void dispose() {
    _friendshipSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _friendRequestsCubit)],
      child: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _doctor == null
              ? Center(
                  child: Text(
                    'User not found',
                    style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                  ),
                )
              : _buildProfileContent(),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final doctor = _doctor!;
    final friendsCount = 0;
    final totalPosts = doctor.posts.length;
    final sponsoredPosts = doctor.posts.where((p) => p.isAdRequest).length;
    final regularPosts = totalPosts - sponsoredPosts;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 260.h,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (!_isOwnProfile)
                Padding(
                  padding: EdgeInsets.only(right: 16.w, top: 8.h),
                  child: _buildFriendButton(),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'profile-cover-${doctor.id}',
                    child: doctor.coverImage != null
                        ? CachedNetworkImage(
                            imageUrl: doctor.coverImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => ShimmerPlaceholder(
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : Container(color: AppColors.primary),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w, bottom: 16.h),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'profile-avatar-${doctor.id}',
                            child: Container(
                              width: 68.w,
                              height: 68.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: doctor.profileImage != null
                                    ? CachedNetworkImage(
                                        imageUrl: doctor.profileImage!,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            ShimmerPlaceholder(
                                              width: 80.w,
                                              height: 80.w,
                                              shape: BoxShape.circle,
                                            ),
                                        errorWidget: (_, __, ___) =>
                                            const Icon(Icons.person),
                                      )
                                    : const Icon(Icons.person),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${doctor.firstName} ${doctor.lastName}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                _buildFriendStatusBadge(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 144.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ProfileStatItem(
                            label: AppTexts.profileRegularPosts,
                            value: regularPosts.toString(),
                            valueColor: Colors.green,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: ProfileStatItem(
                            label: AppTexts.profileSponsoredPosts,
                            value: sponsoredPosts.toString(),
                            valueColor: Colors.teal,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: ProfileStatItem(
                            label: AppTexts.profileFriends,
                            value: friendsCount.toString(),
                            valueColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      bottom: 4.h,
                    ),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: [
                        Tab(text: '${AppTexts.profilePostsTab} ($totalPosts)'),
                        const Tab(text: AppTexts.profileAboutTab),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        children: [
          ProfilePostsTab(doctor: doctor),
          ProfileAboutTab(
            doctor: doctor,
            isOwnProfile: _isOwnProfile,
            onProfileUpdated: _isOwnProfile ? _loadProfile : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendStatusBadge() {
    if (_isOwnProfile) return const SizedBox.shrink();

    switch (_friendStatus) {
      case FriendRequestStatus.pending:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 12.sp, color: AppColors.warning),
              SizedBox(width: 4.w),
              Text(
                'Request Pending',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case FriendRequestStatus.friends:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, size: 12.sp, color: AppColors.success),
              SizedBox(width: 4.w),
              Text(
                'Friend',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFriendButton() {
    if (_isOwnProfile) return const SizedBox.shrink();

    return BlocBuilder<FriendRequestsCubit, dynamic>(
      bloc: _friendRequestsCubit,
      builder: (context, state) {
        final isLoading = state is FriendRequestActionLoading;

        switch (_friendStatus) {
          case FriendRequestStatus.none:
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.18),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              onPressed: isLoading ? null : _handleFriendAction,
              icon: const Icon(Icons.person_add, size: 16),
              label: Text('Add Friend', style: TextStyle(fontSize: 11.sp)),
            );
          case FriendRequestStatus.pending:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: isLoading ? null : _openChat,
                  icon: const Icon(Icons.message, size: 16),
                  label: Text('Message', style: TextStyle(fontSize: 11.sp)),
                ),
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: isLoading ? null : _handleFriendAction,
                  icon: const Icon(Icons.close, size: 16),
                  label: Text('Cancel', style: TextStyle(fontSize: 11.sp)),
                ),
              ],
            );
          case FriendRequestStatus.friends:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: isLoading ? null : _openChat,
                  icon: const Icon(Icons.message, size: 16),
                  label: Text('Message', style: TextStyle(fontSize: 11.sp)),
                ),
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: isLoading ? null : _handleFriendAction,
                  icon: const Icon(Icons.person_remove, size: 16),
                  label: Text('Remove', style: TextStyle(fontSize: 11.sp)),
                ),
              ],
            );
          default:
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.18),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              onPressed: isLoading ? null : _handleFriendAction,
              icon: const Icon(Icons.person_add, size: 16),
              label: Text('Add Friend', style: TextStyle(fontSize: 11.sp)),
            );
        }
      },
    );
  }
}

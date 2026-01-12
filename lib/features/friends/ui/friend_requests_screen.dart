import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../cubit/friend_requests_cubit.dart';
import '../cubit/friend_requests_state.dart';
import '../data/models/friend_request_model.dart';
import '../../messages/ui/chat_detail_screen.dart';
import '../../messages/data/models/chat_user_model.dart';
import 'utils/time_formatter.dart';
import 'widgets/friends_tab.dart';
import 'widgets/incoming_requests_tab.dart';
import 'widgets/incoming_tab_badge.dart';
import 'widgets/outgoing_requests_tab.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late FriendRequestsCubit _friendRequestsCubit;
  late TabController _tabController;
  int? _currentUserId;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _friendRequestsCubit = di.sl<FriendRequestsCubit>();
    _tabController = TabController(length: 3, vsync: this);
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();
    _currentUserId = userData?.id;

    if (_currentUserId != null) {
      _friendRequestsCubit.loadFriendRequests();
    }

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchTerm = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(int userId, String userName, String? profileImage) {
    final receiverUser = ChatUser(
      id: userId,
      userName: userName,
      profileImage: profileImage,
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
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _friendRequestsCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppTexts.friendRequests),
          backgroundColor: AppColors.surface,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: AppTexts.friends),
                Tab(
                  child: IncomingTabBadge(
                    friendRequestsCubit: _friendRequestsCubit,
                  ),
                ),
                Tab(text: AppTexts.outgoing),
              ],
            ),
          ),
        ),
        body: BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state is FriendRequestsLoading ||
                state is FriendRequestsInitial) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is FriendRequestsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentUserId != null) {
                          _friendRequestsCubit.loadFriendRequests();
                        }
                      },
                      child: Text(AppTexts.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is FriendRequestsLoaded ||
                state is FriendRequestActionLoading) {
              final isLoading = state is FriendRequestActionLoading;
              List<FriendRequest> incomingRequests;
              List<FriendRequest> outgoingRequests;
              List<FriendRequest> friends;

              if (state is FriendRequestsLoaded) {
                incomingRequests = state.incomingRequests;
                outgoingRequests = state.outgoingRequests;
                friends = state.friends;
              } else {
                final loadingState = state as FriendRequestActionLoading;
                incomingRequests = loadingState.incomingRequests;
                outgoingRequests = loadingState.outgoingRequests;
                friends = loadingState.friends;
              }

              return TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  FriendsTab(
                    friends: friends,
                    isLoading: isLoading,
                    currentUserId: _currentUserId,
                    searchController: _searchController,
                    searchTerm: _searchTerm,
                    onChatTap: _openChat,
                    friendRequestsCubit: _friendRequestsCubit,
                  ),
                  IncomingRequestsTab(
                    requests: incomingRequests,
                    isLoading: isLoading,
                    currentUserId: _currentUserId,
                    formatTime: TimeFormatter.formatTime,
                    friendRequestsCubit: _friendRequestsCubit,
                  ),
                  OutgoingRequestsTab(
                    requests: outgoingRequests,
                    isLoading: isLoading,
                    currentUserId: _currentUserId,
                    formatTime: TimeFormatter.formatTime,
                    friendRequestsCubit: _friendRequestsCubit,
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
